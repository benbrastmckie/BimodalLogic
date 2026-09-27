/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.SentenceExport

/-!
# The source-sentence conformance channel: acceptance rows

The acceptance criteria for `lake exe translate_sentence` and for
`Tests/fixtures/sentence-translation-fixtures.jsonl`, as `#guard` rows against
`BimodalTools/SentenceExport.lean`. The executable root
`BimodalTools/TranslateSentenceMain.lean` is deliberately **not** imported: it declares a
root-namespace `main`, and two of those cannot share one environment — the same hazard
`Tests/BimodalToolsTest.lean`'s own header comment records.

## The fixture file is read, not duplicated

The rows below run against the committed fixture file itself, pulled in with `include_str`, rather
than against literals copied out of it. That is the whole point of the file: it is the artifact the
consuming repository compares against, so a test that re-stated its contents in Lean could drift
from it silently and still pass.

## What the rows cover, per line

1. The envelope parses: four fields, `surface` and `kind` as strings, `sentence` through `pSentence`
   and `formula` through `pFormula`.
2. `tr` of the parsed sentence **is** the parsed expected formula — the translation row, checked
   against the file rather than against a restatement.
3. `Formula.toJson` of `tr` of the sentence re-parses through `pFormula` to the same formula, so the
   emitted wire form is readable by the reader on this side.
4. `Sentence.toJson` of the parsed sentence re-parses through `pSentence` to the same sentence, so
   the source-side codec round-trips. (The elimination itself does not round-trip and cannot:
   `tr_not_injective`. The channel is forward-only by construction.)
5. Rebuilding the whole line from the parsed parts reproduces the file's line **byte for byte**,
   which pins the file's canonical form to the two serializers rather than to whoever last edited
   it by hand.

Row 5 is a byte comparison *within this repository*, where both sides are `toJson`. The
cross-repository comparison documented in `BimodalTools/README.md` is on **parsed JSON**, because
nothing promises the separator convention across languages.
-/

namespace BimodalToolsTest.SentenceCodec

open FormalSystem.Syntax
open FormalSystem.SourceLanguage
open BimodalTools.JsonParse
open BimodalTools.SentenceExport

/-! ## The committed fixture file -/

/-- The fixture file, verbatim. -/
def fixtureFile : String := include_str "../fixtures/sentence-translation-fixtures.jsonl"

/-- The fixture file's non-empty lines. -/
def fixtureLines : List String :=
  (fixtureFile.splitOn "\n").filter (fun l => l != "")

/-! The fixture count is pinned: 18 constructor rows (one atomic instance of each `Sentence`
constructor), 4 argument-order rows for `untl`/`snce`, and 4 nested rows for the two families that
do not push through. A row added or dropped without updating this number fails the build. -/
#guard fixtureLines.length = 26

/-! ## The envelope -/

/-- One fixture line, parsed. -/
structure Fixture where
  /-- The source repository's surface form. -/
  surface : String
  /-- The row's group: `primitive`, `defined`, `asymmetry` or `nesting`. -/
  kind : String
  /-- The source sentence. -/
  sentence : Sentence
  /-- The expected translated formula. -/
  formula : Formula
  deriving Repr

/-- Read one fixture envelope: four named fields in any order, unknown fields skipped. -/
def parseFixture (line : String) : Except String Fixture := do
  let st := mkPState line
  let st := pSkipWS st
  let st ← pExpect '{' st
  let mut surface : String := ""
  let mut kind : String := ""
  let mut sentence : Option Sentence := none
  let mut formula : Option Formula := none
  let mut st := st
  while true do
    let st' := pSkipWS st
    match pPeek st' with
    | some '}' =>
      st := pAdvance st'
      break
    | _ => pure ()
    let (key, st') ← pString st
    let st' := pSkipWS st'
    let st' ← pExpect ':' st'
    let st' := pSkipWS st'
    if key == "surface" then
      let (v, st') ← pString st'
      surface := v
      st := st'
    else if key == "kind" then
      let (v, st') ← pString st'
      kind := v
      st := st'
    else if key == "sentence" then
      let (v, st') ← pSentence st'
      sentence := some v
      st := st'
    else if key == "formula" then
      let (v, st') ← pFormula st'
      formula := some v
      st := st'
    else
      let st' ← pSkipValue st'
      st := st'
    let st' := pSkipWS st
    match pPeek st' with
    | some ',' => st := pAdvance st'
    | some '}' =>
      st := pAdvance st'
      break
    | _ => throw s!"expected , or }} at pos {st'.pos}"
  match sentence, formula with
  | some s, some f => return { surface := surface, kind := kind, sentence := s, formula := f }
  | none, _ => throw "missing field 'sentence'"
  | _, none => throw "missing field 'formula'"

/-- Rebuild a fixture line from its parsed parts, in the file's canonical form. -/
def renderFixture (f : Fixture) : String :=
  "{\"surface\": \"" ++ BimodalTools.DataExport.escapeJsonString f.surface
    ++ "\", \"kind\": \"" ++ BimodalTools.DataExport.escapeJsonString f.kind
    ++ "\", \"sentence\": " ++ f.sentence.toJson
    ++ ", \"formula\": " ++ f.formula.toJson ++ "}"

/-! ## The rows -/

/-! Every line parses. -/
#guard fixtureLines.all fun l => (parseFixture l).toOption.isSome

/-! Row 2: `tr` of the parsed sentence is the parsed expected formula. -/
#guard fixtureLines.all fun l =>
  match parseFixture l with
  | .ok f => tr f.sentence == f.formula
  | .error _ => false

/-! Row 3: the emitted formula wire form re-parses to the same formula. -/
#guard fixtureLines.all fun l =>
  match parseFixture l with
  | .ok f =>
    match pFormula (mkPState (tr f.sentence).toJson) with
    | .ok (g, _) => g == tr f.sentence
    | .error _ => false
  | .error _ => false

/-! Row 4: the source-side codec round-trips. -/
#guard fixtureLines.all fun l =>
  match parseFixture l with
  | .ok f =>
    match pSentence (mkPState f.sentence.toJson) with
    | .ok (s, _) => s == f.sentence
    | .error _ => false
  | .error _ => false

/-! Row 5: the file's canonical form is exactly what the two serializers emit. -/
#guard fixtureLines.all fun l =>
  match parseFixture l with
  | .ok f => renderFixture f == l
  | .error _ => false

/-! The whole channel, end to end: `translateSentenceLineToJson` on the `sentence` field reproduces
the `formula` field. This is the function `lake exe translate_sentence` wraps, so a green row here
is the binary's contract. -/
#guard fixtureLines.all fun l =>
  match parseFixture l with
  | .ok f => translateSentenceLineToJson f.sentence.toJson == f.formula.toJson
  | .error _ => false

/-! Every `kind` is one of the four declared groups, and each group is non-empty — so no row is
quietly mislabelled into a group nothing checks. -/
#guard
  let kinds := (fixtureLines.filterMap fun l => (parseFixture l).toOption.map (·.kind))
  kinds.all (fun k => k == "primitive" || k == "defined" || k == "asymmetry" || k == "nesting")
    && kinds.contains "primitive" && kinds.contains "defined"
    && kinds.contains "asymmetry" && kinds.contains "nesting"

/-! A malformed line is an error, not a silent default. -/
#guard (parseFixture "{ nonsense").toOption.isNone

/-! An unknown source tag is rejected by name. -/
#guard (parseSentence "{\"tag\": \"nope\"}").toOption.isNone

/-! A failed translation emits the `error` envelope, which no formula object can be mistaken for. -/
#guard (translateSentenceLineToJson "{\"tag\": \"nope\"}").startsWith "{\"error\": "

end BimodalToolsTest.SentenceCodec
