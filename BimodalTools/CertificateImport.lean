/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily
import BimodalTools.CanonicalWire.Cert
import BimodalTools.CertificateRecords
import BimodalTools.DataExport

/-!
# Witness-Family Certificate Import

Decoding, re-verification and serialization for the witness-family certificates the model
checker emits. This is the library half of `lake exe check_certificate`; the executable root
`BimodalTools/CheckCertificateMain.lean` reads stdin and prints, and everything else is here so
it can be tested from `Tests/BimodalToolsTest/`.

## The trust model

The accepting branch **constructs a term** of `WitnessFamily.Refutes Γ Δ` — the joint existence
statement: an explicit ℤ-time frame, model, world history and time at which every premise of the
target is true and every conclusion false. `checkCertified`'s accepting branch cannot be written
without one, because that is the type of its `CheckOutcome.countermodel` field, and
`refutes_of_countermodel` states the same guarantee at the level of the serialized verdict a
consumer reads.

Three things this does buy, and one it does not.

- **The implication is kernel-checked, once, at build time.** Lean elaborates
  `WitnessFamily.refutes_of_certifies` and `refutes_of_countermodel` when these modules compile.
  The step from "the four conditions hold of this family" to "a countermodel exists" is therefore
  no longer a composition the reader performs in their head; it is a checked term.
- **The per-certificate hypothesis comes from the four compiled `Decidable` instances** —
  `decidableLocalCoherentLab`, `decidableFulfillingLab`, `decidableBoxFaithful`,
  `decidableTarget`, composed by `decidableCertifies`. They are evaluated at run time, on the
  family this module rebuilt from the JSON.
- **The residual trust base is Lean's compiler plus this module's decoding.** The compiled
  instances must agree with the propositions they decide, and `parseCertificate`/`mkFamily` must
  have rebuilt the family the sender meant.
- **This is therefore not per-certificate kernel checking.** That would require re-elaborating a
  generated statement for each certificate, which no part of this module does. `Acceptance`
  reserves room for such a value without claiming it.

`rejected` is **never** a validity claim: it says only that the object handed over is not a
certificate.

## Runtime construction

`LabelledLasso` and `WitnessFamily` carry proof fields (`back_ne`, `fwd_ne`, `label_sub`,
`lassos_ne`), all of them decidable propositions over computable data. `mkLasso` and `mkFamily`
discharge each one with a `dite`, so a certificate that fails a structural precondition comes
back as a named rejection rather than as a parse error.

## Why `closureList` rather than `Finset.toList`

`Finset.toList` is noncomputable, so the diagnostic scans cannot enumerate `closureOf` directly.
`closureList` is the computable enumeration of the same members, and `mem_closureList` is the
one-line membership lemma that ties the two together.

## Atom identity

The canonical printer emits an atom's base name and drops `Atom.freshIndex`, and the canonical
parser reads it back as `Atom.mkBase`. A certificate therefore round-trips exactly on base atoms
only, which is why `BimodalTools.CanonicalWire.parse_print` carries a base-atom hypothesis — and
`BimodalTools.CanonicalWire.parse_base_only` then discharges that hypothesis on anything the parser
returns, so the clause holds as a theorem on the real pipeline rather than as a convention.
`hasFreshAtom` detects the exception; `checkRaw` rejects on it rather than letting a
`Finset Formula` membership silently change identity.

## Why the target time is witnessed, not defaulted

`Target Γ Δ` is an existential — *some* `t` with `Γ ⊆ L₀ t` and `Δ ∩ L₀ t = ∅` — and `t` is its
witness, so the wire format demands it. Every other existential a certificate settles is
explicitly witnessed: the box guess witnesses which boxes are false, the lassos witness the
falsifying histories, the labels witness the types. A `time` defaulting to `0` would have left
the outermost existential the only unwitnessed one, against the whole point of a certificate,
which is that checking requires no search.

Separately, `0` denotes the origin only by `LabelledLasso`'s three-segment decoding convention.
Were that convention ever re-indexed — branching families with shared states are contemplated,
and the compression half of the quasimodel route may re-index — a defaulted `0` would silently
change the meaning of every stored certificate that relied on it, with no diagnostic anywhere.

`premises` and `conclusions` keep their `[]` defaults while `time` does not, and the asymmetry
is deliberate rather than an oversight to be tidied in either direction: `[]` is the identity of
a context, so an absent premise list has one unambiguous correct reading, whereas `0` is not the
identity of a time and an absent `time` has none.

## Why the target is one object

`premises`, `conclusions` and `time` are the three data of the single predicate `Target`, so the
wire format groups them under one `"target"` key rather than flattening them into the envelope.
`WitnessFamily/Basic.lean` states that field names mirroring the Lean structures is an export
contract rather than a local naming choice; a faithful mirror is structural as well as nominal.

## Main Definitions

- `closureList`, `intRange` — computable enumerations the scans need
- The parsed records themselves — `RawLasso`, `RawTarget`, `RawCertificate`, `PartialTarget`,
  `PartialCertificate`, the two `complete` functions, `hasFreshAtom` and `RawCertificate.formulas`
  — live in `BimodalTools/CertificateRecords.lean`, under this same namespace, so that the
  verified codec can sit below this module in the import graph. They are reached through the
  import above and are not redeclared here
- `parseCertificate`, `RawCertificate.toJson` — the two directions of the wire format, as thin
  wrappers over the verified codec in `BimodalTools/CanonicalWire/Cert.lean`
- `mkLasso`, `mkFamily` — the runtime builders, `dite` on every proof field
- `Acceptance`, `CheckResult`, `checkRaw` — the acceptance strength, the serializable verdict
  and its JSON line
- `CheckOutcome`, `checkCertified`, `CheckOutcome.erase` — the dependent layer beneath them: an
  accepting outcome carries the entailment as a field, and `erase` forgets it

## Main Results

- `mem_closureList` — `closureList` enumerates exactly `closureOf`
- `refutes_of_countermodel` — a `countermodel` verdict entails `WitnessFamily.Refutes`

## References

* `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean` — the structures, and the note
  that their field names are an export contract
* `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean` — the four instances and the
  per-unit predicates the localization scans reuse
* `BimodalTools/CertificateRecords.lean` — the parsed records, split out so the verified codec
  can import them
* `BimodalTools/CanonicalWire/Cert.lean` — the verified wire codec this module's two edges wrap
* `BimodalTools/JsonParse.lean` — the tag-format formula parser, no longer on this module's path
* `BimodalTools/README.md` — the wire schema, beside the tableau bridge protocol
-/

set_option autoImplicit false

namespace BimodalTools.CertificateImport

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability
open BimodalTools.DataExport

/-!
## Computable enumerations

`Finset.toList` is noncomputable, so every scan below enumerates through these two instead.
-/

/-- The closure of a context, as a duplicate-free list. Computable, unlike `Finset.toList`. -/
def closureList (S : Context) : List Formula :=
  (S.flatMap FormalSystem.Syntax.Formula.subformulas).dedup

/-- `closureList` enumerates exactly the members of `closureOf`. -/
theorem mem_closureList {S : Context} {ψ : Formula} :
    ψ ∈ closureList S ↔ ψ ∈ closureOf S := by
  simp [closureList, mem_closureOf, FormalSystem.Syntax.subformulaClosure]

/-- The half-open integer range `[a, b)`, as a list. The scan windows are `Finset.Ico` at `ℤ`. -/
def intRange (a b : Int) : List Int := (List.range (b - a).toNat).map (fun k => a + (k : Int))

/-!
## The envelope, on the verified codec

`parseCertificate` and `RawCertificate.toJson` are thin wrappers over
`BimodalTools/CanonicalWire/Cert.lean`, which is where the wire format now lives. The
hand-rolled recursive-descent parser this replaced was `partial def` with `while true do`
throughout, so it had no equation lemmas and no theorem about it was possible **in principle** —
and it was also silently wrong, in twelve recorded ways, four of which decoded a producing-side
atom name into a *different* atom. What replaced it is a total `def` with a proved fuel bound and
a proved round trip, so deserialization has left the trust base.

`checkLine`, `checkRaw`, `checkCertified` and `refutes_of_countermodel` are untouched: only the
decode and print edges moved.

The guarantees now available at this edge, all from `CanonicalWire/Cert.lean`:

- `parse_print` — parsing a printed certificate returns that same certificate
- `print_parse_canonical` — on canonical bytes the echo is byte-identical to what was sent
- `printCertificate_injective` — the bytes determine the certificate that was checked
- `parse_base_only` — atom identity is base-only on anything the parser returns
-/

/-- Parse a whole certificate from one JSON line, checking its required fields.

A thin wrapper over the verified codec. The two required-field messages are still the ones
`PartialTarget.complete` and `PartialCertificate.complete` produce, because the decoder still lands
in those mirrors. -/
def parseCertificate (s : String) : Except String RawCertificate :=
  BimodalTools.CanonicalWire.parseCertificateCanonical s

/-!
## Serialization, the inverse direction

The wire format is pinned as mathematics rather than only executably: `parseCertificate` composed
with `RawCertificate.toJson` is the identity on base-atom certificates, and that is the theorem
`BimodalTools.CanonicalWire.parse_print`, not merely a `#guard`. The `#guard` rows in
`Tests/BimodalToolsTest/CertificateImportTest.lean` remain as instances of it.
-/

/-- Wrap a list of already-serialized items as a JSON array. Still used by `CheckResult.toJson`,
which is the *output* line and keeps its own hand-written serializer. -/
def jsonArray (items : List String) : String := "[" ++ String.intercalate "," items ++ "]"

/-- Serialize a whole certificate, in canonical form.

A thin wrapper over the verified printer. The bytes are compact — no space after `:` or `,` —
where the old serializer inherited `Formula.toJson`'s spaces. `Formula.toJson` itself is untouched:
its exact bytes are pinned by other tests across many call sites, so the canonical codec carries
its own printer rather than changing that one. -/
def RawCertificate.toJson (c : RawCertificate) : String :=
  BimodalTools.CanonicalWire.printCertificate c


/-!
## The runtime builders

Each structure field is discharged by a `dite` on its own `Decidable` instance, so a structural
violation is reported by name instead of aborting the decode.
-/

/-- Why one lasso could not be built. -/
inductive LassoFault where
  /-- `back` is empty, so leftward decoding would not be periodic. -/
  | backEmpty
  /-- `fwd` is empty, so rightward decoding would not be periodic. -/
  | fwdEmpty
  /-- Some listed label is not a subset of `closureOf (Γ ++ Δ)`. -/
  | labelOutsideClosure
  deriving Repr, DecidableEq

/-- Why the certificate could not be rebuilt as a `WitnessFamily`. -/
inductive StructuralFault where
  /-- The lasso at this index failed a structural precondition. -/
  | lasso (idx : Nat) (fault : LassoFault)
  /-- The family has no lassos, so the presented carrier would be empty. -/
  | lassosEmpty
  /-- Some formula carries a fresh-indexed atom, which does not survive the wire format. -/
  | atomNotBase
  deriving Repr, DecidableEq

/-- The box guess as a function, from the pairs on the wire. Anything unlisted reads `false`. -/
def bxOf (pairs : List (Formula × Bool)) : Formula → Bool :=
  fun φ => (pairs.find? (·.1 == φ)).map Prod.snd |>.getD false

/-- Rebuild one labelled lasso, or name the structural precondition it violates. -/
def mkLasso (C : Finset Formula) (raw : RawLasso) : Except LassoFault (LabelledLasso C) :=
  let back := raw.back.map List.toFinset
  let mid := raw.mid.map List.toFinset
  let fwd := raw.fwd.map List.toFinset
  if hb : back = [] then .error .backEmpty
  else if hf : fwd = [] then .error .fwdEmpty
  else if hs : ∀ X ∈ back ++ mid ++ fwd, X ⊆ C then
    .ok { back := back, mid := mid, fwd := fwd, back_ne := hb, fwd_ne := hf, label_sub := hs }
  else .error .labelOutsideClosure

/-- Rebuild the whole family, or name the structural precondition it violates. -/
def mkFamily (raw : RawCertificate) :
    Except StructuralFault (WitnessFamily raw.target.premises raw.target.conclusions) := do
  if raw.formulas.any hasFreshAtom then .error .atomNotBase
  else
    let lassos ← raw.lassos.zipIdx.mapM fun p =>
      match mkLasso (closureOf (raw.target.premises ++ raw.target.conclusions)) p.1 with
      | .ok Λ => .ok Λ
      | .error f => .error (.lasso p.2 f)
    if hl : lassos = [] then .error .lassosEmpty
    else return { bx := bxOf raw.bx, lassos := lassos, lassos_ne := hl }

/-!
## The verdict, and where a rejection happened

The verdict is the four top-level `Decidable` instances and nothing else, evaluated in order and
short-circuiting on the first `false`. The scans below run only to localize a rejection: each one
ranges over exactly the units its instance decides — `CoherentAt` over
`[labCohWindowLo, labCohWindowHi)`, `eventClauseAt` over `[labFulWindowLo, labFulWindowHi)`,
`boxClause` over the closure, `Target` at the single target time — so a scan cannot disagree with
the verdict it is explaining. When an instance says `false` and its scan finds nothing, the
`"unlocalized"` record is emitted rather than an empty `failed` list.
-/

/-- One failed condition, localized as far as the scan could take it. -/
structure Failure where
  /-- Which condition failed: `structural`, `local_coherent`, `fulfilling`, `box_faithful`,
  `target`, or `unlocalized`. -/
  condition : String
  /-- The lasso index, when the failure is tied to one. -/
  lasso : Option Nat := none
  /-- The position, when the failure is tied to one. -/
  position : Option Int := none
  /-- The closure member whose clause failed, when the scan found one. -/
  formula : Option Formula := none
  /-- A short human-readable note. -/
  detail : String := ""
  deriving Repr, Inhabited, DecidableEq

/--
**How strongly an acceptance was established.**

The distinction the `"acceptance"` key carries on the wire. It exists because the two are
genuinely different guarantees and a consumer may reasonably treat them differently — a
pure-Python re-checker can produce `decided`, and cannot produce `entailment`.

A third value, for per-certificate kernel checking by re-elaboration of a generated file, is
deliberately **reserved and not introduced here**: nothing in this module produces it, and adding
an inhabited-but-unreachable constructor would misrepresent what the binary can do.
-/
inductive Acceptance where
  /-- Four decision procedures returned `true`, and that is the whole of the claim. -/
  | decided
  /-- Lean constructed a term of `WitnessFamily.Refutes …` for this certificate's target, by
  applying a build-time kernel-checked implication to those four decisions. -/
  | entailment
  deriving Repr, Inhabited, DecidableEq

/-- The checker's answer. Note the absence of any "valid" constructor: this checker is one-sided
by construction and never makes a validity claim. -/
inductive CheckResult where
  /-- Every condition decided `true` at the given target time, at the given acceptance strength. -/
  | countermodel (time : Int) (acceptance : Acceptance)
  /-- Some condition decided `false`, or a structural precondition was violated. -/
  | rejected (failed : List Failure)
  /-- The input was not a well-formed certificate object. A protocol failure, not a verdict. -/
  | error (message : String)
  deriving Repr, Inhabited, DecidableEq

section Scans

variable {Γ Del : Context}

/-- The first position at which local coherence fails, with the offending closure member. -/
def cohFailure (W : WitnessFamily Γ Del) : Option Failure :=
  (List.finRange W.lassos.length).findSome? fun i =>
    let Λ := W.lassos.get i
    (intRange (LabelledLasso.labCohWindowLo Λ) (LabelledLasso.labCohWindowHi Λ)).findSome? fun t =>
      if LabelledLasso.CoherentAt W.bx Λ t then none
      else if Formula.bot ∈ Λ.lab t then
        some { condition := "local_coherent", lasso := some i.val, position := some t,
               formula := some Formula.bot, detail := "⊥ is labelled at this position" }
      else
        let bad := (closureList (Γ ++ Del)).find? fun ψ =>
          ! decide (LabelledLasso.labClauseAt W.bx (Λ.lab (t - 1)) (Λ.lab t) (Λ.lab (t + 1)) ψ)
        some { condition := "local_coherent", lasso := some i.val, position := some t,
               formula := bad, detail := "the local clause of this closure member fails here" }

/-- The first position at which an eventuality is left undischarged. -/
def fulFailure (W : WitnessFamily Γ Del) : Option Failure :=
  (List.finRange W.lassos.length).findSome? fun i =>
    let Λ := W.lassos.get i
    (intRange (LabelledLasso.labFulWindowLo Λ) (LabelledLasso.labFulWindowHi Λ)).findSome? fun t =>
      match (closureList (Γ ++ Del)).find? fun ψ =>
          ! decide (LabelledLasso.eventClauseAt Λ t ψ) with
      | some ψ =>
        some { condition := "fulfilling", lasso := some i.val, position := some t,
               formula := some ψ, detail := "this eventuality is never discharged" }
      | none => none

/-- The first closure member whose box clause fails, with a counter-position when one exists. -/
def boxFailure (W : WitnessFamily Γ Del) : Option Failure :=
  (closureList (Γ ++ Del)).findSome? fun ψ =>
    if W.boxClause ψ then none
    else
      match ψ with
      | .box χ =>
        let counter := (List.finRange W.lassos.length).findSome? fun i =>
          let Λ := W.lassos.get i
          (intRange (-Λ.nb) (Λ.nm + Λ.nf)).findSome? fun t =>
            if χ ∈ W.L i t then none else some (i.val, t)
        some { condition := "box_faithful", lasso := counter.map Prod.fst,
               position := counter.map Prod.snd, formula := some ψ,
               detail := "the box guess disagrees with global label membership" }
      | _ => none

/-- The first premise missing from, or conclusion present in, the main label at the target. -/
def targetFailure (W : WitnessFamily Γ Del) (t : Int) : Option Failure :=
  match Γ.find? (fun γ => ! decide (γ ∈ W.main t)) with
  | some γ =>
    some { condition := "target", lasso := some 0, position := some t, formula := some γ,
           detail := "this premise is not labelled at the target position" }
  | none =>
    match Del.find? (fun σ => decide (σ ∈ W.main t)) with
    | some σ =>
      some { condition := "target", lasso := some 0, position := some t, formula := some σ,
             detail := "this conclusion is labelled at the target position" }
    | none => none

end Scans

/-- The `failed` entry for an instance that returned `false` whose scan found nothing. -/
def unlocalized (condition : String) : Failure :=
  { condition := "unlocalized",
    detail := s!"the {condition} instance decided false, but the scan localized no failure" }

/-- Render a structural fault as a `failed` entry. -/
def StructuralFault.toFailure : StructuralFault → Failure
  | .lasso idx .backEmpty =>
    { condition := "structural", lasso := some idx, detail := "back segment is empty" }
  | .lasso idx .fwdEmpty =>
    { condition := "structural", lasso := some idx, detail := "fwd segment is empty" }
  | .lasso idx .labelOutsideClosure =>
    { condition := "structural", lasso := some idx,
      detail := "a label is not a subset of the closure of the premises and conclusions" }
  | .lassosEmpty =>
    { condition := "structural", detail := "the family has no lassos" }
  | .atomNotBase =>
    { condition := "structural",
      detail := "an atom carries a fresh index, which the wire format does not preserve" }

/-!
## The dependent layer

`CheckResult` is what goes on the wire, and it is deliberately non-dependent: a `List Failure`
and an `Int` serialize, a proof does not. `CheckOutcome` sits beneath it and carries, on its
accepting constructor only, the very statement `WitnessFamily.refutes_of_certifies` produces. The
point is structural rather than informational: `checkCertified`'s accepting branch **cannot be
written** without a term of that type in hand, so acceptance is a constructed entailment rather
than a report about four decisions. `erase` is the forgetful map down to the serializable layer,
and `checkRaw` is its composition — so the wire behaviour is unchanged while the branch that
produces it is not.
-/

/--
The checker's answer, with the accepting case carrying its entailment.

Mirrors `CheckResult` constructor for constructor, and derives nothing: the `entails` field is a
`Prop`, so `Repr`, `Inhabited` and `DecidableEq` have nothing to say about it. The indexing by
`raw` is what lets the field mention `raw.target.premises` and `raw.target.conclusions`.
-/
inductive CheckOutcome (raw : RawCertificate) where
  /-- Every condition held at the given target time, and here is the countermodel it yields. -/
  | countermodel (time : Int)
      (entails : WitnessFamily.Refutes raw.target.premises raw.target.conclusions)
  /-- Some condition failed, or a structural precondition was violated. -/
  | rejected (failed : List Failure)
  /-- The input was not a well-formed certificate object. A protocol failure, not a verdict. -/
  | error (message : String)

/--
Re-verify a decoded certificate, **constructing** the entailment on the accepting path.

The four conditions are decided individually, in the order `decidableLocalCoherentLab`,
`decidableFulfillingLab`, `decidableBoxFaithful`, `decidableTarget`, each by a `dite` that
short-circuits on the first failure — the same order, the same short-circuit and the same cost as
the four-way `if` chain this replaced, with each localization scan left in the branch it already
occupied. A bundled `dite` on `WitnessFamily.Certifies` would instead force the rejecting path to
re-decide the failing prefix before it could localize.

What the `dite`s buy over an `if ! decide …` chain is that each binds its condition as a
hypothesis, so the innermost branch has all four in scope and discharges
`WitnessFamily.refutes_of_certifies` directly.
-/
def checkCertified (raw : RawCertificate) : CheckOutcome raw :=
  match mkFamily raw with
  | .error f => .rejected [f.toFailure]
  | .ok W =>
    if hloc : W.LocalCoherentLab then
      if hful : W.FulfillingLab then
        if hbox : W.BoxFaithful then
          if htgt : W.Target raw.target.time then
            .countermodel raw.target.time
              (WitnessFamily.refutes_of_certifies W ⟨hloc, hful, hbox, htgt⟩)
          else .rejected [(targetFailure W raw.target.time).getD (unlocalized "target")]
        else .rejected [(boxFailure W).getD (unlocalized "box_faithful")]
      else .rejected [(fulFailure W).getD (unlocalized "fulfilling")]
    else .rejected [(cohFailure W).getD (unlocalized "local_coherent")]

/-- Forget the entailment: the map from the dependent outcome down to the serializable verdict. -/
def CheckOutcome.erase {raw : RawCertificate} : CheckOutcome raw → CheckResult
  | .countermodel t _ => .countermodel t .entailment
  | .rejected fs => .rejected fs
  | .error m => .error m

/--
Re-verify a decoded certificate, as the serializable verdict.

`checkCertified` composed with `CheckOutcome.erase`: the decision work and the accepting branch's
construction happen in the dependent layer above, and this only forgets the entailment so the
answer can be printed. The verdict is `decidableLocalCoherentLab`, `decidableFulfillingLab`,
`decidableBoxFaithful` and `decidableTarget`, in that order, short-circuiting on the first
failure, exactly as before.

So a `countermodel` answer here is the *erasure* of a constructed `WitnessFamily.Refutes …`, not a
report that four procedures returned `true`: `refutes_of_countermodel` recovers the statement from
the verdict alone. What is kernel-checked is the implication, once at build time; the hypothesis
it is applied to is decided at run time by the four compiled instances. A rejection is never a
claim that the consequence holds.
-/
def checkRaw (raw : RawCertificate) : CheckResult := (checkCertified raw).erase

/--
**A `countermodel` verdict entails the joint existence statement.**

The composition the checker's accepting branch stands for, stated at the level of the serialized
verdict a consumer actually reads: if `checkRaw` answers `countermodel`, then there really is a
ℤ-time frame, model, world history and time at which every premise of the target is true and
every conclusion false.

What this does and does not say. The implication is kernel-checked **once, at build time** — Lean
elaborates this proof, and `WitnessFamily.refutes_of_certifies` inside it, when the module is
compiled. The per-certificate hypothesis, that the four conditions hold of the family rebuilt
from *this* input, is supplied at run time by the four compiled `Decidable` instances. So this is
not per-certificate kernel checking: what it removes is the reader's obligation to compose the
decided conditions with the agreement theorem by hand, not the compiler from the trust base.
-/
theorem refutes_of_countermodel {raw : RawCertificate} {t : Int} {a : Acceptance}
    (h : checkRaw raw = .countermodel t a) :
    WitnessFamily.Refutes raw.target.premises raw.target.conclusions := by
  rw [checkRaw] at h
  cases hco : checkCertified raw with
  | countermodel t' hent => exact hent
  | rejected fs => rw [hco] at h; simp [CheckOutcome.erase] at h
  | error m => rw [hco] at h; simp [CheckOutcome.erase] at h

/-- Parse and re-verify one JSON line. Malformed input is an `error`, never a verdict. -/
def checkLine (line : String) : CheckResult :=
  match parseCertificate line with
  | .error msg => .error msg
  | .ok raw => checkRaw raw

/-!
## The output line
-/

/-- Serialize an optional natural number as a JSON value. -/
def optNatToJson : Option Nat → String
  | none => "null"
  | some n => toString n

/-- Serialize an optional integer as a JSON value. -/
def optIntToJson : Option Int → String
  | none => "null"
  | some n => toString n

/-- Serialize an optional formula as a JSON value. -/
def optFormulaToJson : Option Formula → String
  | none => "null"
  | some φ => φ.toJson

/-- Serialize one failure record. -/
def Failure.toJson (f : Failure) : String :=
  "{\"condition\":\"" ++ escapeJsonString f.condition ++
  "\",\"lasso\":" ++ optNatToJson f.lasso ++
  ",\"position\":" ++ optIntToJson f.position ++
  ",\"formula\":" ++ optFormulaToJson f.formula ++
  ",\"detail\":\"" ++ escapeJsonString f.detail ++ "\"}"

/-- Serialize the acceptance strength as the `"acceptance"` field's value. -/
def Acceptance.toJson : Acceptance → String
  | .decided => "\"decided\""
  | .entailment => "\"entailment\""

/-- Serialize the verdict as the single JSON line the executable prints. The `"acceptance"` key
appears on `countermodel` only; `rejected` and `error` are byte-identical to what they were
before the key existed. -/
def CheckResult.toJson : CheckResult → String
  | .countermodel t a =>
    "{\"status\":\"countermodel\",\"time\":" ++ toString t ++
    ",\"acceptance\":" ++ a.toJson ++ "}"
  | .rejected fs =>
    "{\"status\":\"rejected\",\"failed\":" ++ jsonArray (fs.map Failure.toJson) ++ "}"
  | .error m => "{\"status\":\"error\",\"message\":\"" ++ escapeJsonString m ++ "\"}"

/-- Parse, re-verify and serialize: the whole executable, minus the IO. -/
def checkLineToJson (line : String) : String := (checkLine line).toJson

end BimodalTools.CertificateImport
