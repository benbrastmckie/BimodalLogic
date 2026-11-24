/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.AxiomNames
import BimodalTools.DataExport
import FormalSystem.ProofSystem.Substitution

/-!
# Emitting Lean source for an extracted derivation

The theorem library's ADMIT stage has a runtime `DerivationTree` in hand and needs a *registered*
row for it. The row's `proof` field is `Type`-valued and the kernel checks it, so the derivation
has to reach the environment as a term. This module reifies it the direct way: it prints Lean
source text that elaborates to the same tree.

## Why source text rather than elaboration-time search

The alternative is a generated body of the shape `(tryAxiomProof φ).get (by rfl)`, which asks the
kernel to reduce bounded proof search with no `native_decide` available — an unmeasured blow-up
under `--wfail`. Printing an explicit term costs one printer and leaves the generated library
auditable, which is the point of a theorem library: a reader can see the axiom instances and the
rule applications, not a search that happened to succeed.

Every `DerivationTree` constructor takes its context and its conclusion explicitly, so the
printer needs no implicit-argument reconstruction. The four proof-valued arguments print as
closed tactic blocks: `(by decide)` for `h_fc : h.minFrameClass ≤ fc` at a concrete frame class,
`(by simp)` for a membership side condition, and `(List.nil_subset _)` for weakening out of the
empty context.

## Main definitions

- `atomSource`, `formulaSource` — the six `Formula` constructors, fully explicit and
  unconditionally parenthesized, so the output needs no precedence table
- `schemaSource` — the schema-variable spelling the generated signature binds
- `schemaFormula`, `schemaFormulaSource` — the generalized statement, as a `Formula` and as source
- `axiomSource`, `axiomConstructorName` — the 20 `Axiom` constructors
- `derivationSource` — the seven `DerivationTree` constructors
- `entrySource` — the whole generated declaration for one admitted theorem, in the shape
  `register_theorem` accepts, laid out within the 100-character line limit

## Coverage

`axiomSampleNames` and the `#guard`s below assert that the 20 arms of `axiomConstructorName` are
exactly `BimodalTools.allAxiomNames`, in the shape `BenchmarkAnchorsMain.lean` and
`MachineAppendixMain.lean` already use. A constructor added to `Axiom` fails the exhaustiveness
check of `axiomSource`/`axiomConstructorName` first, and the sample list here second, rather than
being silently printed as nothing.

## The preamble the emitted text assumes

`entrySource` prints short names. A module holding its output therefore opens the two namespaces
and imports the registry:

```lean
import BimodalLib.Registry
import FormalSystem.ProofSystem.Substitution

open FormalSystem.Syntax
open FormalSystem.ProofSystem
```

## Generated names carry no underscores

`Concrete` and `Subst` are appended camelCase rather than with an underscore separator. Check
`C26` of `scripts/check-module-invariants.sh` flags a non-trailing underscore in any live
`def`/`abbrev` name, and the `env_linter` sweep over every other lakefile root carries a pinned
finding ceiling, so an emitted `fooConcrete` is conformant where an emitted `foo_concrete` would
spend ceiling.

## References

* `FormalSystem/ProofSystem/Substitution.lean` — `substF` and `DerivationTree.substNil`, the
  generalization the emitted declaration closes over
* `FormalSystem/ProofSystem/Derivation.lean` — the seven rules `derivationSource` prints
* `FormalSystem/ProofSystem/Axioms.lean` — the 20 schemata `axiomSource` prints
* `BimodalLib/Registry.lean` — `register_theorem` and the row shape the output targets

## Tags

theorem-library · code-generation · derivation · substitution
-/

namespace BimodalTools

open FormalSystem.Syntax
open FormalSystem.ProofSystem

/-! ## Atoms and formulas -/

/-- An `Atom` as an explicit constructor call. Atoms never print through notation: the base is a
string literal and the fresh index an `Option Nat`, so the output is independent of whatever
atom notation the consuming module has in scope. -/
def atomSource (a : Atom) : String :=
  let base := "\"" ++ DataExport.escapeJsonString a.base ++ "\""
  match a.freshIndex with
  | none => "(Atom.mk " ++ base ++ " none)"
  | some i => "(Atom.mk " ++ base ++ " (some " ++ toString i ++ "))"

/-- The formula printer, parameterized by how an atom is rendered. The two public faces differ
only in that renderer: `formulaSource` prints every atom as itself, while
`schemaFormulaSource` prints the generalized atoms as the bound schema variables. -/
private def formulaSourceWith (render : Atom → String) : Formula → String
  | .atom p => render p
  | .bot => "(Formula.bot)"
  | .imp φ ψ =>
      "(Formula.imp " ++ formulaSourceWith render φ ++ " " ++ formulaSourceWith render ψ ++ ")"
  | .box φ => "(Formula.box " ++ formulaSourceWith render φ ++ ")"
  | .untl ψ φ =>
      "(Formula.untl " ++ formulaSourceWith render ψ ++ " " ++ formulaSourceWith render φ ++ ")"
  | .snce ψ φ =>
      "(Formula.snce " ++ formulaSourceWith render ψ ++ " " ++ formulaSourceWith render φ ++ ")"

/-- A `Formula` as source text, in the six primitive constructors only and parenthesized
unconditionally. No derived operator and no notation appears in the output. -/
def formulaSource (φ : Formula) : String :=
  formulaSourceWith (fun p => "(Formula.atom " ++ atomSource p ++ ")") φ

/-- A context as a source-level list literal. At the empty context this is `[]`, which is the
only shape the ADMIT stage emits. -/
def contextSource (Γ : Context) : String :=
  "[" ++ String.intercalate ", " (List.map formulaSource Γ) ++ "]"

/-! ## Schema variables -/

/-- The spelling of the `i`-th schema variable in a generated signature: `A`, `B`, `C`, … while
the arity stays within 26, and `(v i)` above it, where the signature binds `v : Nat → Formula`
instead of 27 separate letters. -/
def schemaSource (i : Nat) : String :=
  if i < 26 then String.singleton (Char.ofNat (65 + i)) else "(v " ++ toString i ++ ")"

/-- The index of `a` among the generalized atoms, if it is one of them. -/
private def atomIndex (atoms : List Atom) (a : Atom) : Option Nat :=
  atoms.findIdx? (· == a)

/-- The generalized statement as a `Formula`: each generalized atom replaced by an atom spelled
like its schema variable. This is a display form — it feeds the generated docstring — while the
statement the kernel checks comes from `schemaFormulaSource`. -/
def schemaFormula (atoms : List Atom) (φ : Formula) : Formula :=
  substF (fun q =>
    match atomIndex atoms q with
    | some i => .atom (Atom.mkBase (schemaSource i))
    | none => .atom q) φ

/-- The generalized statement as source text: the generalized atoms print as the *bound* schema
variables of the generated signature, every other atom as itself. -/
def schemaFormulaSource (atoms : List Atom) (φ : Formula) : String :=
  formulaSourceWith (fun p =>
    match atomIndex atoms p with
    | some i => schemaSource i
    | none => "(Formula.atom " ++ atomSource p ++ ")") φ

/-! ## Axioms -/

/-- The constructor name of an `Axiom` instance, in `allAxiomNames`' spelling. Twenty arms, one
per constructor of `inductive Axiom`; the match is exhaustive, so a constructor added upstream
fails here. -/
def axiomConstructorName : {φ : Formula} → Axiom φ → String
  | _, .prop_k _ _ _ => "prop_k"
  | _, .prop_s _ _ => "prop_s"
  | _, .ex_falso _ => "ex_falso"
  | _, .peirce _ _ => "peirce"
  | _, .modal_t _ => "modal_t"
  | _, .modal_5_collapse _ => "modal_5_collapse"
  | _, .modal_k_dist _ _ => "modal_k_dist"
  | _, .serial_future => "serial_future"
  | _, .left_mono_until_G _ _ _ => "left_mono_until_G"
  | _, .right_mono_until _ _ _ => "right_mono_until"
  | _, .enrichment_until _ _ _ => "enrichment_until"
  | _, .self_accum_until _ _ => "self_accum_until"
  | _, .absorb_until _ _ => "absorb_until"
  | _, .linear_until _ _ _ _ => "linear_until"
  | _, .modal_future _ => "modal_future"
  | _, .discrete_box_necessity => "discrete_box_necessity"
  | _, .prior_UZ _ => "prior_UZ"
  | _, .dense_indicator => "dense_indicator"
  | _, .prior_U_gap _ => "prior_U_gap"
  | _, .sep _ => "sep"

/-- An `Axiom` instance as source text: the constructor name, qualified by `Axiom.`, applied to
its `Formula` arguments through `formulaSource`. The three parameter-free constructors print
bare. Twenty arms, matching `axiomConstructorName` constructor for constructor. -/
def axiomSource : {φ : Formula} → Axiom φ → String
  | _, .prop_k φ ψ χ =>
      "Axiom.prop_k " ++ formulaSource φ ++ " " ++ formulaSource ψ ++ " " ++ formulaSource χ
  | _, .prop_s φ ψ => "Axiom.prop_s " ++ formulaSource φ ++ " " ++ formulaSource ψ
  | _, .ex_falso φ => "Axiom.ex_falso " ++ formulaSource φ
  | _, .peirce φ ψ => "Axiom.peirce " ++ formulaSource φ ++ " " ++ formulaSource ψ
  | _, .modal_t φ => "Axiom.modal_t " ++ formulaSource φ
  | _, .modal_5_collapse φ => "Axiom.modal_5_collapse " ++ formulaSource φ
  | _, .modal_k_dist φ ψ => "Axiom.modal_k_dist " ++ formulaSource φ ++ " " ++ formulaSource ψ
  | _, .serial_future => "Axiom.serial_future"
  | _, .left_mono_until_G φ χ ψ =>
      "Axiom.left_mono_until_G " ++ formulaSource φ ++ " " ++ formulaSource χ ++ " "
        ++ formulaSource ψ
  | _, .right_mono_until φ ψ χ =>
      "Axiom.right_mono_until " ++ formulaSource φ ++ " " ++ formulaSource ψ ++ " "
        ++ formulaSource χ
  | _, .enrichment_until φ ψ p =>
      "Axiom.enrichment_until " ++ formulaSource φ ++ " " ++ formulaSource ψ ++ " "
        ++ formulaSource p
  | _, .self_accum_until φ ψ =>
      "Axiom.self_accum_until " ++ formulaSource φ ++ " " ++ formulaSource ψ
  | _, .absorb_until φ ψ => "Axiom.absorb_until " ++ formulaSource φ ++ " " ++ formulaSource ψ
  | _, .linear_until φ ψ χ θ =>
      "Axiom.linear_until " ++ formulaSource φ ++ " " ++ formulaSource ψ ++ " "
        ++ formulaSource χ ++ " " ++ formulaSource θ
  | _, .modal_future φ => "Axiom.modal_future " ++ formulaSource φ
  | _, .discrete_box_necessity => "Axiom.discrete_box_necessity"
  | _, .prior_UZ φ => "Axiom.prior_UZ " ++ formulaSource φ
  | _, .dense_indicator => "Axiom.dense_indicator"
  | _, .prior_U_gap φ => "Axiom.prior_U_gap " ++ formulaSource φ
  | _, .sep φ => "Axiom.sep " ++ formulaSource φ

/-! ### The coverage assertion

One instance per constructor, each at `⊥`, so that the names `axiomConstructorName` can produce
are enumerable and comparable against `allAxiomNames`. The guards below fail the build on a
missing name, an extra name, a duplicate, or a count that has drifted. -/

/-- One `Axiom` instance per constructor, at `⊥` throughout. -/
def axiomSamples : List ((φ : Formula) × Axiom φ) :=
  [ ⟨_, .prop_k .bot .bot .bot⟩
  , ⟨_, .prop_s .bot .bot⟩
  , ⟨_, .ex_falso .bot⟩
  , ⟨_, .peirce .bot .bot⟩
  , ⟨_, .modal_t .bot⟩
  , ⟨_, .modal_5_collapse .bot⟩
  , ⟨_, .modal_k_dist .bot .bot⟩
  , ⟨_, .serial_future⟩
  , ⟨_, .left_mono_until_G .bot .bot .bot⟩
  , ⟨_, .right_mono_until .bot .bot .bot⟩
  , ⟨_, .enrichment_until .bot .bot .bot⟩
  , ⟨_, .self_accum_until .bot .bot⟩
  , ⟨_, .absorb_until .bot .bot⟩
  , ⟨_, .linear_until .bot .bot .bot .bot⟩
  , ⟨_, .modal_future .bot⟩
  , ⟨_, .discrete_box_necessity⟩
  , ⟨_, .prior_UZ .bot⟩
  , ⟨_, .dense_indicator⟩
  , ⟨_, .prior_U_gap .bot⟩
  , ⟨_, .sep .bot⟩
  ]

/-- The constructor names the samples cover. -/
def axiomSampleNames : List String :=
  axiomSamples.map (fun s => axiomConstructorName s.2)

/-- Names in `allAxiomNames` that no sample covers. -/
def axiomNamesMissing : List String :=
  allAxiomNames.filter (fun n => !axiomSampleNames.contains n)

/-- Sample names that `allAxiomNames` does not list. -/
def axiomNamesExtra : List String :=
  axiomSampleNames.filter (fun n => !allAxiomNames.contains n)

-- The assertions are `example`s rather than `#guard`s: `lean_lib BimodalTools` does not carry
-- the test libraries' `linter.hashCommand` opt-out, and CI builds `--wfail`, so a `#`-command
-- here would be a warning and therefore a failure. An `example` fails the build the same way.
example : axiomNamesMissing = [] := by rfl
example : axiomNamesExtra = [] := by rfl
example : axiomSampleNames.length = allAxiomNames.length := by rfl
example : axiomSampleNames.eraseDups.length = axiomSampleNames.length := by rfl
example : axiomSampleNames.length = 20 := by rfl

/-! ## Derivations -/

/-- A `DerivationTree` as source text. Seven arms, one per rule.

The proof-valued arguments print as closed tactic blocks rather than as terms: `(by decide)`
discharges `h.minFrameClass ≤ fc` at a concrete frame class, `(by simp)` a context membership,
and `(List.nil_subset _)` the weakening side condition out of the empty context — the only
weakening shape the ADMIT stage emits. A weakening out of a non-empty context falls back to
`(by simp)`, which is the same `List.Subset` goal with a non-trivial left side. -/
def derivationSource {fc : FrameClass} :
    {Γ : Context} → {φ : Formula} → DerivationTree fc Γ φ → String
  | _, _, .axiom Γ φ h _ =>
      "(DerivationTree.axiom " ++ contextSource Γ ++ " " ++ formulaSource φ ++ " ("
        ++ axiomSource h ++ ") (by decide))"
  | _, _, .assumption Γ φ _ =>
      "(DerivationTree.assumption " ++ contextSource Γ ++ " " ++ formulaSource φ
        ++ " (by simp))"
  | _, _, .modus_ponens Γ φ ψ d1 d2 =>
      "(DerivationTree.modus_ponens " ++ contextSource Γ ++ " " ++ formulaSource φ ++ " "
        ++ formulaSource ψ ++ " " ++ derivationSource d1 ++ " " ++ derivationSource d2 ++ ")"
  | _, _, .necessitation φ d =>
      "(DerivationTree.necessitation " ++ formulaSource φ ++ " " ++ derivationSource d ++ ")"
  | _, _, .temporal_necessitation φ d =>
      "(DerivationTree.temporal_necessitation " ++ formulaSource φ ++ " "
        ++ derivationSource d ++ ")"
  | _, _, .time_reflection φ d =>
      "(DerivationTree.time_reflection " ++ formulaSource φ ++ " " ++ derivationSource d ++ ")"
  | _, _, .weakening Γ Δ φ d _ =>
      let side := match Γ with
        | [] => "(List.nil_subset _)"
        | _ => "(by simp)"
      "(DerivationTree.weakening " ++ contextSource Γ ++ " " ++ contextSource Δ ++ " "
        ++ formulaSource φ ++ " " ++ derivationSource d ++ " " ++ side ++ ")"

/-! ## The generated entry -/

/-- Rejoin a `(by decide)` or `(by simp)` block that splitting on spaces broke in two, so that
`wrapSource` treats it as one unbreakable token. A tactic moved onto a continuation line is read
at a different indentation; merging rather than exempting the pair from the width check is also
what keeps the result *under* the limit, since an exemption appends its token unchecked and can
push a line past 100 on its own. -/
private def mergeTacticTokens : List String → List String
  | "(by" :: t :: rest => ("(by " ++ t) :: mergeTacticTokens rest
  | t :: rest => t :: mergeTacticTokens rest
  | [] => []

/-- Greedy line wrapping on space boundaries, with every line carrying `indent` spaces.

The generated module lands under `BimodalLib/`, where the package's
`linter.mathlibStandardSet` makes a line over 100 characters a warning and CI's `--wfail` makes
a warning a failure. Fully explicit formula source passes that width on any formula of interest,
so the layout is wrapped rather than emitted as one line. Every break falls between two whole
tokens of one applied term — see `mergeTacticTokens` for the one pair that is never split — where
a continuation line indented at least as far as the first is accepted. -/
private def wrapSource (indent : Nat) (s : String) : String :=
  let pad := String.ofList (List.replicate indent ' ')
  let width := 98
  let folded := (mergeTacticTokens (s.splitOn " ")).foldl
    (fun (st : List String × String) t =>
      let (done, cur) := st
      if cur.isEmpty then (done, pad ++ t)
      else if cur.length + 1 + t.length ≤ width then (done, cur ++ " " ++ t)
      else (cur :: done, pad ++ t))
    ([], "")
  String.intercalate "\n" ((folded.2 :: folded.1).reverse)


/-- The schema-variable binder group of a generated signature, empty at arity 0. -/
private def binderGroup (arity : Nat) : String :=
  if arity == 0 then ""
  else if arity ≤ 26 then
    " (" ++ String.intercalate " " ((List.range arity).map schemaSource) ++ " : Formula)"
  else " (v : Nat → Formula)"

/-- The schema-variable argument list, for applying a generated declaration to its own binders. -/
private def binderArgs (arity : Nat) : String :=
  if arity == 0 then ""
  else if arity ≤ 26 then
    " " ++ String.intercalate " " ((List.range arity).map schemaSource)
  else " v"

/-- The body of the generalizing substitution: a chain of atom tests ending in the identity, so
every atom outside `atoms` is left alone. -/
private def substBody (atoms : List Atom) : String :=
  (atoms.zip (List.range atoms.length)).foldr
    (fun p acc => "if q = " ++ atomSource p.1 ++ " then " ++ schemaSource p.2 ++ " else " ++ acc)
    "Formula.atom q"

/--
The whole generated declaration for one admitted theorem: a docstring, the extracted derivation
as a `private def` over its concrete atoms, the generalizing substitution as a second
`private def`, the schematic `def` obtained from the two by `DerivationTree.substNil`, and the
`register_theorem` line that files it.

`atoms` is the ordered list of atoms to generalize — the `i`-th becomes the `i`-th schema
variable — and `ns` is the namespace the generated module declares, used only to qualify the
`register_theorem` argument. The schematic declaration is stated at the fixed frame class
`FrameClass.Base`, which is where proof extraction produces derivations and therefore where the
row is filed.

The closing `simpa [substF, …]` is the shape verified on the research probe before this module
existed: `substNil` delivers `substF σ φ` and `simp` reduces the substitution through the
formula's constructors and the substitution's atom tests, leaving the generalized statement.
-/
def entrySource (ns declName : String) (atoms : List Atom) {φ : Formula}
    (d : DerivationTree FrameClass.Base [] φ) : String :=
  let arity := atoms.length
  let concreteName := declName ++ "Concrete"
  let substName := declName ++ "Subst"
  let pretty := (schemaFormula atoms φ).prettyPrint
  String.intercalate "\n"
    [ wrapSource 0 ("/-- The derivation the tableau extracted for `" ++ φ.prettyPrint
        ++ "`, over its own concrete atoms. Generated; do not edit by hand. -/")
    , "private def " ++ concreteName ++ " : DerivationTree FrameClass.Base []"
    , wrapSource 4 (formulaSource φ ++ " :=")
    , wrapSource 2 (derivationSource d)
    , ""
    , wrapSource 0 ("/-- The substitution generalizing `" ++ concreteName
        ++ "`'s atoms to schema variables. Generated; do not edit by hand. -/")
    , "private def " ++ substName ++ binderGroup arity ++ " : Atom → Formula :="
    , wrapSource 2 ("fun q => " ++ substBody atoms)
    , ""
    , wrapSource 0 ("/-- `" ++ pretty
        ++ "` — admitted by the theorem-library pipeline at `Base`."
        ++ " Generated; do not edit by hand. -/")
    , "def " ++ declName ++ binderGroup arity ++ " : DerivationTree FrameClass.Base []"
    , wrapSource 4 (schemaFormulaSource atoms φ ++ " := by")
    , wrapSource 2 ("have h := DerivationTree.substNil (" ++ substName ++ binderArgs arity
        ++ ") " ++ concreteName)
    , "  simpa [substF, " ++ substName ++ "] using h"
    , ""
    , "register_theorem " ++ ns ++ "." ++ declName
    ]

end BimodalTools
