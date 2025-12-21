# LeanSearch Results: Automated Theorem Proving

**Query**: "automated theorem proving"
**Date**: December 21, 2025
**Results Found**: 25
**Scope**: Mathlib, Std, Core LEAN 4

## Executive Summary

This LeanSearch semantic search query for "automated theorem proving" returned 25 highly relevant results from Mathlib4. The results span several categories of automated proof techniques:

**Key Findings:**
1. **SAT Solver Integration**: LRAT proof format support for SAT solving (`lrat_proof`, `from_lrat`)
2. **Propositional Tautology Provers**: Multiple tactics for propositional logic (`tauto`, `itauto`, `itauto!`)
3. **Decision Procedures**: Intuitionistic and classical propositional logic decision procedures
4. **Proof Search Utilities**: Various helper tactics and configuration structures
5. **Function Property Reasoning**: `funProp` framework for automated reasoning about function properties

**Relevance to Modal/Temporal Logic:**
The propositional tautology provers (`tauto`, `itauto`) are highly relevant for modal/temporal logic automation, as they can handle the propositional fragment of modal formulas. The SAT solver integration could potentially be extended to handle modal satisfiability checking. The proof search patterns and decision procedures provide excellent templates for building custom modal/temporal proof automation.

## Top Results

### Result 1: Mathlib.Tactic.Sat.commandLrat_proof_Example____

- **Type**: definition
- **Module**: `Mathlib.Tactic.Sat.FromLRAT`
- **Relevance Score**: 0.9550 (distance: 0.0450)
- **Informal Name**: LRAT Proof Macro for SAT Solving

**Type Signature:**
```lean
Lean.ParserDescr
```

**Documentation:**
A macro for producing SAT proofs from CNF / LRAT files.
These files are commonly used in the SAT community for writing proofs.

The input to the `lrat_proof` command is the name of the theorem to define,
and the statement (written in CNF format) and the proof (in LRAT format).
For example:
```
lrat_proof foo
  ""p cnf 2 4  1 2 0  -1 2 0  1 -2 0  -1 -2 0""
  ""5 -2 0 4 3 0  5 d 3 4 0  6 1 0 5 1 0  6 d 1 0  7 0 5 2 6 0""
```
produces a theorem:
```
foo : ∀ (a a_1 : Prop), (¬a ∧ ¬a_1 ∨ a ∧ ¬a_1) ∨ ¬a ∧ a_1 ∨ a ∧ a_1
```

* You can see the theorem statement by hovering over the word `foo`.
* You can use the `example` keyword in place of `foo` to avoid generating a theorem.
* You can use the `include_str` macro in place of the two strings
  to load CNF / LRAT files from disk.


**Description:**
The `lrat_proof` command is a macro that generates a SAT proof from input files in CNF (Conjunctive Normal Form) and LRAT (Linear time verification of Resolution Asymmetric Tautologies) formats. It takes a theorem name (or uses `example` to avoid generating a theorem), a CNF string representing the propositional formula, and an LRAT string representing the proof. The command then produces a theorem stating the validity of the formula.

For example, given:
```
lrat_proof foo
  "p cnf 2 4  1 2 0  -1 2 0  1 -2 0  -1 -2 0"
  "5 -2 0 4 3 0  5 d 3 4 0  6 1 0 5 1 0  6 d 1 0  7 0 5 2 6 0"
```
it generates a theorem:
```
foo : ∀ (a a_1 : Prop), (¬a ∧ ¬a_1 ∨ a ∧ ¬a_1) ∨ ¬a ∧ a_1 ∨ a ∧ a_1
```

The CNF string describes the formula in DIMACS format, and the LRAT string provides a proof that the formula is unsatisfiable (or valid, depending on context). The command can also load these strings from files using `include_str`.

---

### Result 2: Mathlib.Tactic.Tauto.DistribNotState.recOn

- **Type**: N/A
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 0.9421 (distance: 0.0579)
- **Informal Name**: Tactic for Propositional Tautologies (`tauto`)

**Type Signature:**
```lean
{motive : Mathlib.Tactic.Tauto.DistribNotState → Sort u} →
  (t : Mathlib.Tactic.Tauto.DistribNotState) →
    ((fvars : List Lean.Expr) → (currentGoal : Lean.MVarId) → motive { fvars := fvars, currentGoal := currentGoal }) →
      motive t
```

**Description:**
This is a Lean tactic for propositional logic, not a mathematical theorem. The `tauto` tactic automatically proves propositional tautologies using a truth table approach. It handles logical connectives such as `∧`, `∨`, `→`, `¬`, `↔`, and the constants `True` and `False`.  

**Informal name**  
Tactic for Propositional Tautologies (`tauto`)

---

### Result 3: Mathlib.Tactic.ITauto.itauto

- **Type**: definition
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 0.9381 (distance: 0.0619)
- **Informal Name**: Intuitionistic tautology prover (`itauto`)

**Type Signature:**
```lean
Lean.ParserDescr
```

**Documentation:**
A decision procedure for intuitionistic propositional logic. Unlike `finish` and `tauto!` this
tactic never uses the law of excluded middle (without the `!` option), and the proof search is
tailored for this use case. (`itauto!` will work as a classical SAT solver, but the algorithm is
not very good in this situation.)

```lean
example (p : Prop) : ¬ (p ↔ ¬ p) := by itauto
```

`itauto [a, b]` will additionally attempt case analysis on `a` and `b` assuming that it can derive
`Decidable a` and `Decidable b`. `itauto *` will case on all decidable propositions that it can
find among the atomic propositions, and `itauto! *` will case on all propositional atoms.
*Warning:* This can blow up the proof search, so it should be used sparingly.


**Description:**
The `itauto` tactic is a decision procedure for intuitionistic propositional logic. It proves intuitionistic tautologies without using the law of excluded middle (unless the `!` variant is used). The tactic supports all built-in propositional connectives (`True`, `False`, `And`, `Or`, `→`, `Not`, `Iff`, `Xor'`) as well as equality and inequality on propositions (`Eq` and `Ne`). Definitions and quantifiers (`∀`, `∃`) are not supported and must be simplified or instantiated before using the tactic.

The tactic can optionally perform case analysis on specified decidable propositions (via `itauto [a, b]`) or all decidable propositions (via `itauto *`). The `itauto!` variant enables classical reasoning by allowing case splitting on arbitrary propositions.

---

### Result 4: Mathlib.Tactic.Tauto.tauto

- **Type**: definition
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 0.9325 (distance: 0.0675)
- **Informal Name**: Tautology tactic (`tauto`)

**Type Signature:**
```lean
Lean.ParserDescr
```

**Documentation:**
`tauto` breaks down assumptions of the form `_ ∧ _`, `_ ∨ _`, `_ ↔ _` and `∃ _, _`
and splits a goal of the form `_ ∧ _`, `_ ↔ _` or `∃ _, _` until it can be discharged
using `reflexivity` or `solve_by_elim`.
This is a finishing tactic: it either closes the goal or raises an error.

The Lean 3 version of this tactic by default attempted to avoid classical reasoning
where possible. This Lean 4 version makes no such attempt. The `itauto` tactic
is designed for that purpose.


**Description:**
The `tauto` tactic is a finishing tactic that decomposes assumptions and goals involving logical connectives (`∧`, `∨`, `↔`, `∃`) until the goal can be resolved using `reflexivity` or `solve_by_elim`. Unlike its Lean 3 counterpart, it does not avoid classical reasoning by default.

---

### Result 5: Mathlib.Tactic.ITauto.Proof

- **Type**: inductive
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 0.9258 (distance: 0.0742)
- **Informal Name**: Intuitionistic Propositional Proof

**Type Signature:**
```lean
Type
```

**Documentation:**
A reified inductive proof type for intuitionistic propositional logic. 

**Description:**
The inductive type `Proof` represents reified proofs in intuitionistic propositional logic, used by the `itauto` decision procedure. It captures valid proof steps according to the G4ip algorithm for intuitionistic tautologies.

---

### Result 6: Mathlib.Tactic.Sat.termFrom_lrat___

- **Type**: definition
- **Module**: `Mathlib.Tactic.Sat.FromLRAT`
- **Relevance Score**: 0.9179 (distance: 0.0821)
- **Informal Name**: SAT Proof Construction from CNF and LRAT Strings

**Type Signature:**
```lean
Lean.ParserDescr
```

**Documentation:**
A macro for producing SAT proofs from CNF / LRAT files.
These files are commonly used in the SAT community for writing proofs.

The input to the `from_lrat` term syntax is two string expressions with
the statement (written in CNF format) and the proof (in LRAT format).
For example:
```
def foo := from_lrat
  ""p cnf 2 4  1 2 0  -1 2 0  1 -2 0  -1 -2 0""
  ""5 -2 0 4 3 0  5 d 3 4 0  6 1 0 5 1 0  6 d 1 0  7 0 5 2 6 0""
```
produces a theorem:
```
foo : ∀ (a a_1 : Prop), (¬a ∧ ¬a_1 ∨ a ∧ ¬a_1) ∨ ¬a ∧ a_1 ∨ a ∧ a_1
```

* You can use this term after `have :=` or in `def foo :=` to produce the term
  without constraining the type.
* You can use it when a specific type is expected, but it currently does not
  pay any attention to the shape of the goal and always produces the same theorem,
  so you can only use this to do alpha renaming.
* You can use the `include_str` macro in place of the two strings
  to load CNF / LRAT files from disk.


**Description:**
The `from_lrat` macro constructs a SAT proof from two strings: one in CNF (Conjunctive Normal Form) format representing a propositional formula, and another in LRAT (Linear time verification of Resolution Asymmetric Tautologies) format representing a proof of the formula's validity. The macro processes these strings to produce a theorem stating the validity of the formula. For example, given the input:
```
def foo := from_lrat
  "p cnf 2 4  1 2 0  -1 2 0  1 -2 0  -1 -2 0"
  "5 -2 0 4 3 0  5 d 3 4 0  6 1 0 5 1 0  6 d 1 0  7 0 5 2 6 0"
```
it generates the theorem:
```
foo : ∀ (a a_1 : Prop), (¬a ∧ ¬a_1 ∨ a ∧ ¬a_1) ∨ ¬a ∧ a_1 ∨ a ∧ a_1
```
The macro can be used in definitions or `have` statements, and supports loading strings from files via `include_str`.

---

### Result 7: Mathlib.Tactic.ITauto.itauto!

- **Type**: definition
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 0.8991 (distance: 0.1009)
- **Informal Name**: Enhanced intuitionistic tautology prover with selective LEM

**Type Signature:**
```lean
Lean.ParserDescr
```

**Description:**
The `itauto!` tactic is a variant of the `itauto` decision procedure for intuitionistic propositional logic that allows selective use of the law of excluded middle (LEM) for case splitting on specified propositions. It implements the `G4ip` algorithm and supports built-in propositional connectives (`True`, `False`, `And`, `Or`, `→`, `Not`, `Iff`, `Xor'`) as well as equality and inequality on propositions (`Eq` and `Ne`).

---

### Result 8: Mathlib.Tactic.Tauto.Config.mk

- **Type**: N/A
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 0.8941 (distance: 0.1059)
- **Informal Name**: Tauto Tactic for Propositional Logic

**Type Signature:**
```lean
Mathlib.Tactic.Tauto.Config
```

**Description:**
The `tauto` tactic is an automated reasoning procedure that proves propositional tautologies and handles basic logical reasoning in Lean.

**Informal name**
Tauto Tactic for Propositional Logic

**Explanation:**
The `tauto` tactic is commonly used in proof assistants to automatically prove tautologies and handle propositional logic reasoning. It typically works on formulas involving logical connectives like ∧, ∨, →, ¬, and ↔, and can handle quantifier-free first-order logic in some implementations. Since this appears to be a configuration structure for the tactic rather than a mathematical theorem, the description focuses on explaining what the tactic does rather than proving a mathematical result.

---

### Result 9: Mathlib.Tactic.ITauto.itautoCore

- **Type**: definition
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 0.8856 (distance: 0.1144)
- **Informal Name**: Core Intuitionistic Tautology Prover

**Type Signature:**
```lean
Lean.MVarId → Bool → Bool → Array Lean.Expr → Lean.Meta.MetaM Unit
```

**Documentation:**
A decision procedure for intuitionistic propositional logic.

* `useDec` will add `a ∨ ¬ a` to the context for every decidable atomic proposition `a`.
* `useClassical` will allow `a ∨ ¬ a` to be added even if the proposition is not decidable,
  using classical logic.
* `extraDec` will add `a ∨ ¬ a` to the context for specified (not necessarily atomic)
  propositions `a`.


**Description:**
The core procedure of the `itauto` tactic for intuitionistic propositional logic. Given a goal `g` and configuration parameters `useDec`, `useClassical`, and `extraDec`, it attempts to prove the goal using the G4ip algorithm. The parameters control whether to use decidability information (`useDec`), allow classical case splitting on arbitrary propositions (`useClassical`), or add specific propositions to the case-splitting set (`extraDec`). The procedure operates in the `MetaM` monad and modifies the goal state if successful.

---

### Result 10: Mathlib.Tactic.Tauto.Config.ctorIdx

- **Type**: N/A
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 0.8706 (distance: 0.1294)
- **Informal Name**: Tauto Tactic for Propositional Logic

**Type Signature:**
```lean
Mathlib.Tactic.Tauto.Config → Nat
```

**Description:**
The `tauto` tactic is a propositional logic solver that automatically proves tautologies in Lean.  

**Informal name**  
Tauto Tactic for Propositional Logic

---

### Result 11: Mathlib.Tactic.Polyrith.tacticPolyrithOnly[_]

- **Type**: definition
- **Module**: `Mathlib.Tactic.Polyrith`
- **Relevance Score**: 0.8568 (distance: 0.1432)
- **Informal Name**: `polyrith` Tactic

**Type Signature:**
```lean
Lean.ParserDescr
```

**Documentation:**
The `polyrith` tactic is no longer supported in Mathlib,
because it relied on a defunct external service.

---

Attempts to prove polynomial equality goals through polynomial arithmetic
on the hypotheses (and additional proof terms if the user specifies them).
It proves the goal by generating an appropriate call to the tactic
`linear_combination`. If this call succeeds, the call to `linear_combination`
is suggested to the user.

* `polyrith` will use all relevant hypotheses in the local context.
* `polyrith [t1, t2, t3]` will add proof terms t1, t2, t3 to the local context.
* `polyrith only [h1, h2, h3, t1, t2, t3]` will use only local hypotheses
  `h1`, `h2`, `h3`, and proofs `t1`, `t2`, `t3`. It will ignore the rest of the local context.

Notes:
* This tactic only works with a working internet connection, since it calls Sage
  using the SageCell web API at <https://sagecell.sagemath.org/>.
  Many thanks to the Sage team and organization for allowing this use.
* This tactic assumes that the user has `curl` available on path.


**Description:**
The `polyrith` tactic is no longer supported in Mathlib, as it relied on a defunct external service.

---

### Result 12: Mathlib.Tactic.Tauto.tautology

- **Type**: definition
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 0.8199 (distance: 0.1801)
- **Informal Name**: Tautology tactic (`tautology`)

**Type Signature:**
```lean
Lean.Elab.Tactic.TacticM Unit
```

**Documentation:**
Implementation of the `tauto` tactic. 

**Description:**
The `tautology` tactic is a finishing tactic that decomposes logical connectives in assumptions and goals, then attempts to solve the goal using reflexivity, automated elimination, or logical constructors. It operates classically and ensures all subgoals are resolved within a focused scope.

---

### Result 13: Mathlib.Tactic.Abel.AbelMode.term

- **Type**: N/A
- **Module**: `Mathlib.Tactic.Abel`
- **Relevance Score**: 0.7892 (distance: 0.2108)
- **Informal Name**: Abel Tactic for Additive Commutative Structures

**Type Signature:**
```lean
Mathlib.Tactic.Abel.AbelMode
```

**Description:**
Unable to provide a mathematical statement translation as the input appears to describe a proof automation tactic (`abel`) rather than a mathematical theorem or definition.

**Informal name**
Abel Tactic for Additive Commutative Structures

**Note:** If you intended to translate a specific mathematical theorem that uses the `abel` tactic or is related to it, please provide the complete formal statement and relevant mathematical context. The current input describes a proof automation tool rather than a mathematical result.

---

### Result 14: commandLibrary_note2____1

- **Type**: N/A
- **Module**: `Mathlib.Tactic.Basic`
- **Relevance Score**: 0.7773 (distance: 0.2227)
- **Informal Name**: Lean 4 Tactic Writing Utilities Documentation

**Type Signature:**
```lean
Lean.ParserDescr
```

**Description:**
This is a library note describing basic utilities and tactics for writing tactics in Lean 4, including:
- A dummy `variables` macro that warns the user to use `variable` instead
- The `introv` tactic for automatically introducing theorem variables and naming non-dependent hypotheses
- An `assumption` macro that applies the `assumption` tactic to all goals
- The `match_target` and `clear_aux_decl` tactics for matching targets and clearing auxiliary declarations

**Informal name**
Lean 4 Tactic Writing Utilities Documentation

---

### Result 15: Mathlib.Meta.FunProp.GeneralTheorem.getProof

- **Type**: definition
- **Module**: `Mathlib.Tactic.FunProp.Theorems`
- **Relevance Score**: 0.7476 (distance: 0.2524)
- **Informal Name**: Proof retrieval for function property theorems

**Type Signature:**
```lean
Mathlib.Meta.FunProp.GeneralTheorem → Lean.Meta.MetaM Lean.Expr
```

**Documentation:**
Get proof of a theorem. 

**Description:**
Given a general theorem `thm` about function properties, this function retrieves its proof as a metaprogram expression.

---

### Result 16: Mathlib.Tactic.Sat._aux_Mathlib_Tactic_Sat_FromLRAT___elabRules_Mathlib_Tactic_Sat_termFrom_lrat____1.unsafe_4

- **Type**: N/A
- **Module**: `Mathlib.Tactic.Sat.FromLRAT`
- **Relevance Score**: 0.7202 (distance: 0.2798)
- **Informal Name**: LRAT Proof Verification Tactic

**Type Signature:**
```lean
Lean.TSyntax (List.cons `term List.nil) → Lean.Elab.Term.TermElabM String
```

**Description:**
The `lrat_proof` command defines a macro that enables the Lean kernel to verify SAT proofs encoded in the LRAT format and extract the proven propositional formula as a theorem statement. Given a CNF-formatted proposition and an LRAT-formatted proof, it produces a Lean theorem asserting the validity of the propositional formula.

**Informal name**
LRAT Proof Verification Tactic

**Explanation:**
- This is not a mathematical theorem but rather a tactic/macro in Lean
- The formal name appears to be an internal implementation detail (an auxiliary function)
- The head statements describe a command for processing SAT proofs in CNF/LRAT formats
- The purpose is to use Lean as a verified checker for SAT proofs and expose the results as propositional theorems
- The example shows it takes CNF input and LRAT proof and produces a theorem statement in Lean

Since this is about tooling/verification infrastructure rather than mathematical content, the informal description focuses on what the command does functionally rather than stating a mathematical result.

---

### Result 17: Mathlib.Tactic.Find.tacticFind

- **Type**: definition
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 0.7186 (distance: 0.2814)
- **Informal Name**: Find tactic for applicable lemmas

**Type Signature:**
```lean
Lean.ParserDescr
```

**Description:**
The `find` tactic searches for lemmas that can be applied to the current goal in a proof context.

---

### Result 18: Mathlib.Meta.FunProp.GeneralTheorems.rec

- **Type**: N/A
- **Module**: `Mathlib.Tactic.FunProp.Types`
- **Relevance Score**: 0.6689 (distance: 0.3311)
- **Informal Name**: N/A (This is a Lean metaprogramming constructor, not a mathematical theorem or definition.)

**Type Signature:**
```lean
{motive : Mathlib.Meta.FunProp.GeneralTheorems → Sort u} →
  ((theorems : Lean.Meta.RefinedDiscrTree Mathlib.Meta.FunProp.GeneralTheorem) → motive { theorems := theorems }) →
    (t : Mathlib.Meta.FunProp.GeneralTheorems) → motive t
```

**Description:**
N/A (This is a Lean metaprogramming structure used for storing theorems in the `funProp` environment extension, not a mathematical statement.)

**Informal name**  
N/A (This is a Lean metaprogramming constructor, not a mathematical theorem or definition.)

---

### Result 19: Mathlib.Tactic.Linarith.Comp

- **Type**: N/A
- **Module**: `Mathlib.Tactic.Linarith.Datatypes`
- **Relevance Score**: 0.6370 (distance: 0.3630)
- **Informal Name**: *Cannot be generated - no mathematical theorem or definition is specified.*

**Type Signature:**
```lean
Type
```

**Description:**
*Cannot be generated - this appears to be an implementation file for tactic data structures rather than a mathematical theorem.*

**Informal name**
*Cannot be generated - no mathematical theorem or definition is specified.*

---

### Result 20: Mathlib.Meta.FunProp.LambdaTheorem.thmName

- **Type**: N/A
- **Module**: `Mathlib.Tactic.FunProp.Theorems`
- **Relevance Score**: 0.5506 (distance: 0.4494)
- **Informal Name**: *Cannot be generated - insufficient mathematical content*

**Type Signature:**
```lean
Mathlib.Meta.FunProp.LambdaTheorem → Lean.Name
```

**Description:**
*Cannot be generated - insufficient mathematical content*

**Informal name**
*Cannot be generated - insufficient mathematical content*

This appears to be an internal Lean metaprogramming construct rather than a mathematical theorem that can be translated into informal mathematical language.

---

### Result 21: Mathlib.Meta.FunProp.LambdaTheorem.getProof

- **Type**: definition
- **Module**: `Mathlib.Tactic.FunProp.Theorems`
- **Relevance Score**: 0.5467 (distance: 0.4533)
- **Informal Name**: Proof retrieval for lambda theorem

**Type Signature:**
```lean
Mathlib.Meta.FunProp.LambdaTheorem → Lean.Meta.MetaM Lean.Expr
```

**Documentation:**
Return proof of lambda theorem 

**Description:**
Given a lambda theorem `thm`, this function returns its proof as a metaprogram expression in the Lean meta-programming context.

---

### Result 22: Mathlib.Meta.FunProp.instInhabitedTheoremForm

- **Type**: N/A
- **Module**: `Mathlib.Tactic.FunProp.Theorems`
- **Relevance Score**: 0.4922 (distance: 0.5078)
- **Informal Name**: Inhabited Theorem Forms

**Type Signature:**
```lean
Inhabited Mathlib.Meta.FunProp.TheoremForm
```

**Description:**
The type `TheoremForm` is inhabited, meaning there exists at least one element of this type.

---

### Result 23: Mathlib.Tactic.generalizeProofsElab

- **Type**: definition
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 0.4766 (distance: 0.5234)
- **Informal Name**: `generalize_proofs` Tactic

**Type Signature:**
```lean
Lean.ParserDescr
```

**Documentation:**
`generalize_proofs ids* [at locs]?` generalizes proofs in the current goal,
turning them into new local hypotheses.

- `generalize_proofs` generalizes proofs in the target.
- `generalize_proofs at h₁ h₂` generalized proofs in hypotheses `h₁` and `h₂`.
- `generalize_proofs at *` generalizes proofs in the entire local context.
- `generalize_proofs pf₁ pf₂ pf₃` uses names `pf₁`, `pf₂`, and `pf₃` for the generalized proofs.
  These can be `_` to not name proofs.

If a proof is already present in the local context, it will use that rather than create a new
local hypothesis.

When doing `generalize_proofs at h`, if `h` is a let binding, its value is cleared,
and furthermore if `h` duplicates a preceding local hypothesis then it is eliminated.

The tactic is able to abstract proofs from under binders, creating universally quantified
proofs in the local context.
To disable this, use `generalize_proofs -abstract`.
The tactic is also set to recursively abstract proofs from the types of the generalized proofs.
This can be controlled with the `maxDepth` configuration option,
with `generalize_proofs (config := { maxDepth := 0 })` turning this feature off.

For example:
```lean
def List.nthLe {α} (l : List α) (n : ℕ) (_h : n < l.length) : α := sorry
example : List.nthLe [1, 2] 1 (by simp) = 2 := by
  -- ⊢ [1, 2].nthLe 1 ⋯ = 2
  generalize_proofs h
  -- h : 1 < [1, 2].length
  -- ⊢ [1, 2].nthLe 1 h = 2
```


**Description:**
The tactic `generalize_proofs` replaces proof terms occurring in the goal or specified hypotheses with new local hypotheses. This is particularly useful for referring to proofs later in a proof (e.g., when dealing with functions like `Classical.choose` that depend on proofs) and for handling dependent type issues.  

- `generalize_proofs` generalizes proofs in the target.  
- `generalize_proofs at h₁ h₂` generalizes proofs in hypotheses `h₁` and `h₂`.  
- `generalize_proofs at *` generalizes proofs in the entire local context.  
- `generalize_proofs pf₁ pf₂ pf₃` uses names `pf₁`, `pf₂`, and `pf₃` for the generalized proofs (use `_` to leave proofs unnamed).  

If a proof already exists in the local context, it is reused. When generalizing at a hypothesis `h` that is a let-binding, the value is cleared, and duplicates are eliminated. The tactic can abstract proofs under binders (producing universally quantified proofs) and recursively abstract proofs from the types of generalized proofs (controlled via `maxDepth`).  

**Example**:  
Given a goal `[1, 2].nthLe 1 (by simp) = 2`, applying `generalize_proofs h` replaces the proof term `(by simp)` with a hypothesis `h : 1 < [1, 2].length`, resulting in the goal `[1, 2].nthLe 1 h = 2`.

---

### Result 24: Mathlib.Meta.FunProp.LambdaTheoremArgs.const

- **Type**: N/A
- **Module**: `Mathlib.Tactic.FunProp.Theorems`
- **Relevance Score**: 0.4610 (distance: 0.5390)
- **Informal Name**: [Not applicable - this is a programming construct, not a mathematical theorem]

**Type Signature:**
```lean
Mathlib.Meta.FunProp.LambdaTheoremArgs
```

**Description:**
[This is a metaprogramming construct for Lean's function property automation system, not a mathematical theorem that can be translated into an informal statement.]

**Informal name**
[Not applicable - this is a programming construct, not a mathematical theorem]

---

### Result 25: Mathlib.LibraryNote.fact non-instances

- **Type**: definition
- **Module**: `Mathlib.Logic.Basic`
- **Relevance Score**: 0.4610 (distance: 0.5390)
- **Informal Name**: Library Note on Fact Non-Instances

**Type Signature:**
```lean
LibraryNote
```

**Documentation:**
In most cases, we should not have global instances of `Fact`; typeclass search is not an
advanced proof search engine, and adding any such instance has the potential to cause
slowdowns everywhere. We instead declare them as lemmata and make them local instances as required.


**Description:**
A library note in Mathlib: "In most cases, we should not have global instances of `Fact`; typeclass search is not an advanced proof search engine, and adding any such instance has the potential to cause slowdowns everywhere. We instead declare them as lemmata and make them local instances as required."

---

## Results by Category

### SAT Solving

1. **Mathlib.Tactic.Sat.commandLrat_proof_Example____** - LRAT Proof Macro for SAT Solving
6. **Mathlib.Tactic.Sat.termFrom_lrat___** - SAT Proof Construction from CNF and LRAT Strings
16. **Mathlib.Tactic.Sat._aux_Mathlib_Tactic_Sat_FromLRAT___elabRules_Mathlib_Tactic_Sat_termFrom_lrat____1.unsafe_4** - LRAT Proof Verification Tactic

### Propositional Tautology Provers

2. **Mathlib.Tactic.Tauto.DistribNotState.recOn** - Tactic for Propositional Tautologies (`tauto`)
3. **Mathlib.Tactic.ITauto.itauto** - Intuitionistic tautology prover (`itauto`)
4. **Mathlib.Tactic.Tauto.tauto** - Tautology tactic (`tauto`)
5. **Mathlib.Tactic.ITauto.Proof** - Intuitionistic Propositional Proof
7. **Mathlib.Tactic.ITauto.itauto!** - Enhanced intuitionistic tautology prover with selective LEM
8. **Mathlib.Tactic.Tauto.Config.mk** - Tauto Tactic for Propositional Logic
9. **Mathlib.Tactic.ITauto.itautoCore** - Core Intuitionistic Tautology Prover
10. **Mathlib.Tactic.Tauto.Config.ctorIdx** - Tauto Tactic for Propositional Logic
12. **Mathlib.Tactic.Tauto.tautology** - Tautology tactic (`tautology`)

### Proof Search Utilities

17. **Mathlib.Tactic.Find.tacticFind** - Find tactic for applicable lemmas
23. **Mathlib.Tactic.generalizeProofsElab** - `generalize_proofs` Tactic

### Function Properties

15. **Mathlib.Meta.FunProp.GeneralTheorem.getProof** - Proof retrieval for function property theorems
18. **Mathlib.Meta.FunProp.GeneralTheorems.rec** - N/A (This is a Lean metaprogramming constructor, not a mathematical theorem or definition.)
20. **Mathlib.Meta.FunProp.LambdaTheorem.thmName** - *Cannot be generated - insufficient mathematical content*
21. **Mathlib.Meta.FunProp.LambdaTheorem.getProof** - Proof retrieval for lambda theorem
22. **Mathlib.Meta.FunProp.instInhabitedTheoremForm** - Inhabited Theorem Forms
24. **Mathlib.Meta.FunProp.LambdaTheoremArgs.const** - [Not applicable - this is a programming construct, not a mathematical theorem]

### General Tactics

11. **Mathlib.Tactic.Polyrith.tacticPolyrithOnly[_]** - `polyrith` Tactic
13. **Mathlib.Tactic.Abel.AbelMode.term** - Abel Tactic for Additive Commutative Structures
19. **Mathlib.Tactic.Linarith.Comp** - *Cannot be generated - no mathematical theorem or definition is specified.*

### Other

14. **commandLibrary_note2____1** - Lean 4 Tactic Writing Utilities Documentation
25. **Mathlib.LibraryNote.fact non-instances** - Library Note on Fact Non-Instances
