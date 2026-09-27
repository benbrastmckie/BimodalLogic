/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.SourceLanguage.Sentence
import BimodalTools.DataExport
import BimodalTools.JsonParse

/-!
# The source-sentence wire format and the conformance channel

`FormalSystem/SourceLanguage/` proves that the elimination `tr` of the source language's seventeen
operators into the six `Formula` primitives preserves truth. That theorem certifies the *encoding*;
it says nothing about any particular implementation of it. This module is what connects the two: a
JSON codec for `Sentence` in the same tag vocabulary `Formula` already uses, and a one-line-in,
one-line-out translation entry point, so the companion ModelChecker repository can diff its own
translation against this one **mechanically rather than by reading**.

## Main Definitions

- `Sentence.toJson` — the source-side serializer, in the `Formula.toJson` style
- `pSentence` — the source-side reader, in the `BimodalTools.JsonParse.pFormula` style
- `translateSentenceLineToJson` — parse → `tr` → `Formula.toJson`, one line in, one line out

## The source-side tag vocabulary

One tag per `Sentence` constructor, spelled as the constructor is:

| Tag | Fields |
|---|---|
| `atom` | `name` (the base name only) |
| `bot`, `top` | — |
| `neg`, `box`, `allFut`, `allPast`, `dia`, `someFut`, `somePast`, `next`, `prev` | `child` |
| `wedge`, `vee`, `cond`, `bicond` | `left`, `right` |
| `untl`, `snce` | `guard`, `event` |

`untl` and `snce` carry **named** `guard`/`event` fields rather than positional ones, exactly as
`Formula`'s own wire format does. The constructor is guard-first on both sides, so nothing depends
on the order — but the wire stays order-free anyway, which is the property that makes an
argument-order regression on either side impossible to hide.

Unknown object fields are skipped rather than rejected, so a producer may attach metadata a consumer
does not read. An atom round-trips on its base name only, as on the `Formula` side: a fresh-indexed
atom changes identity across a round trip, so it is rejected at the wire by convention on both
sides.

## Output shape, and why the successful case is bare

`translateSentenceLineToJson` emits the translated formula's own JSON object on success — not a
wrapper — so a fixture line's expected field is comparable directly. A failure emits
`{"error": "..."}` instead. The two are distinguishable without a schema: every formula object
carries a `tag` field and no `error` field.

## Comparison is on parsed JSON, never on bytes

`Formula.toJson` emits `", "` and `": "` separators, which Python's `json.dumps` defaults happen to
match. Nothing guarantees that, and neither side promises byte stability. A consumer comparing
serialized text is testing the separator convention, not the translation.

## Comparison runs forward only

`FormalSystem.SourceLanguage.tr_not_injective` proves the elimination is not injective: each defined
operator is sent onto the abbreviation it stands for, so a translated `Formula` does not determine
the `Sentence` it came from. There is therefore no inverse pass to check, and the channel is
one-directional by construction. What *does* round-trip is the source side alone:
`Sentence.toJson` after `pSentence` is the identity on a well-formed source object, which is what
`Tests/BimodalToolsTest/SentenceCodecTest.lean` asserts.

## References

* `FormalSystem/SourceLanguage/Sentence.lean` — `Sentence` and `tr`
* `FormalSystem/SourceLanguage/SentenceTruth.lean` — `sat_iff`, the theorem this channel exposes
* `BimodalTools/DataExport.lean` — `Formula.toJson`, the target vocabulary
* `BimodalTools/JsonParse.lean` — `pFormula` and the scalar primitives reused here
* `BimodalTools/TranslateSentenceMain.lean` — the `lake exe translate_sentence` root
* `Tests/fixtures/sentence-translation-fixtures.jsonl` — the shared fixture list
* `BimodalTools/README.md` — the wire schema and the hand-off contract
-/

set_option autoImplicit false

namespace BimodalTools.SentenceExport

open FormalSystem.Syntax
open FormalSystem.SourceLanguage
open BimodalTools.JsonParse
open BimodalTools.DataExport (escapeJsonString)

/-!
## Serialization
-/

/--
Serialize a `Sentence` to a JSON object string, in the `Formula.toJson` style: one tag per
constructor, `guard`/`event` named on `untl`/`snce`, and an atom reduced to its base name.
-/
def _root_.FormalSystem.SourceLanguage.Sentence.toJson : Sentence → String
  | .atom a =>
    "{\"tag\": \"atom\", \"name\": \"" ++ escapeJsonString a.base ++ "\"}"
  | .bot => "{\"tag\": \"bot\"}"
  | .top => "{\"tag\": \"top\"}"
  | .neg A => "{\"tag\": \"neg\", \"child\": " ++ A.toJson ++ "}"
  | .box A => "{\"tag\": \"box\", \"child\": " ++ A.toJson ++ "}"
  | .allFut A => "{\"tag\": \"allFut\", \"child\": " ++ A.toJson ++ "}"
  | .allPast A => "{\"tag\": \"allPast\", \"child\": " ++ A.toJson ++ "}"
  | .dia A => "{\"tag\": \"dia\", \"child\": " ++ A.toJson ++ "}"
  | .someFut A => "{\"tag\": \"someFut\", \"child\": " ++ A.toJson ++ "}"
  | .somePast A => "{\"tag\": \"somePast\", \"child\": " ++ A.toJson ++ "}"
  | .next A => "{\"tag\": \"next\", \"child\": " ++ A.toJson ++ "}"
  | .prev A => "{\"tag\": \"prev\", \"child\": " ++ A.toJson ++ "}"
  | .wedge A B =>
    "{\"tag\": \"wedge\", \"left\": " ++ A.toJson ++ ", \"right\": " ++ B.toJson ++ "}"
  | .vee A B =>
    "{\"tag\": \"vee\", \"left\": " ++ A.toJson ++ ", \"right\": " ++ B.toJson ++ "}"
  | .cond A B =>
    "{\"tag\": \"cond\", \"left\": " ++ A.toJson ++ ", \"right\": " ++ B.toJson ++ "}"
  | .bicond A B =>
    "{\"tag\": \"bicond\", \"left\": " ++ A.toJson ++ ", \"right\": " ++ B.toJson ++ "}"
  | .untl g e =>
    "{\"tag\": \"untl\", \"guard\": " ++ g.toJson ++ ", \"event\": " ++ e.toJson ++ "}"
  | .snce g e =>
    "{\"tag\": \"snce\", \"guard\": " ++ g.toJson ++ ", \"event\": " ++ e.toJson ++ "}"

/-!
## Parsing
-/

/--
Parse a `Sentence` from a JSON object, in the `BimodalTools.JsonParse.pFormula` style: scan the
object's fields, collecting the tag, the atom name and any sub-sentences, then dispatch on the tag.
Unknown fields are skipped.
-/
partial def pSentence (st : PState) : Except String (Sentence × PState) := do
  let st := pSkipWS st
  let st ← pExpect '{' st
  let mut tag : String := ""
  let mut name : String := ""
  let mut subs : List (String × Sentence) := []
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
    if key == "tag" then
      let (val, st') ← pString st'
      tag := val
      st := st'
    else if key == "name" then
      let (val, st') ← pString st'
      name := val
      st := st'
    else if key == "left" || key == "right" || key == "child" ||
            key == "event" || key == "guard" then
      let (sub, st') ← pSentence st'
      subs := (key, sub) :: subs
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
  let getField (fname : String) : Except String Sentence :=
    match subs.find? (fun (k, _) => k == fname) with
    | some (_, s) => .ok s
    | none => .error s!"missing field '{fname}' for tag '{tag}'"
  let unary (mk : Sentence → Sentence) : Except String (Sentence × PState) := do
    let child ← getField "child"
    return (mk child, st)
  let binary (mk : Sentence → Sentence → Sentence) : Except String (Sentence × PState) := do
    let left ← getField "left"
    let right ← getField "right"
    return (mk left right, st)
  match tag with
  | "atom" => return (Sentence.atom (Atom.mkBase name), st)
  | "bot" => return (Sentence.bot, st)
  | "top" => return (Sentence.top, st)
  | "neg" => unary Sentence.neg
  | "box" => unary Sentence.box
  | "allFut" => unary Sentence.allFut
  | "allPast" => unary Sentence.allPast
  | "dia" => unary Sentence.dia
  | "someFut" => unary Sentence.someFut
  | "somePast" => unary Sentence.somePast
  | "next" => unary Sentence.next
  | "prev" => unary Sentence.prev
  | "wedge" => binary Sentence.wedge
  | "vee" => binary Sentence.vee
  | "cond" => binary Sentence.cond
  | "bicond" => binary Sentence.bicond
  | "untl" =>
    let guard ← getField "guard"
    let event ← getField "event"
    return (Sentence.untl guard event, st)
  | "snce" =>
    let guard ← getField "guard"
    let event ← getField "event"
    return (Sentence.snce guard event, st)
  | _ => throw s!"unknown sentence tag '{tag}'"

/-- Parse one source-sentence JSON object from a string. -/
def parseSentence (s : String) : Except String Sentence :=
  match pSentence (mkPState s) with
  | .ok (sentence, _) => .ok sentence
  | .error e => .error e

/-!
## The conformance entry point
-/

/--
The whole channel in one function: read one source-sentence JSON object, eliminate its defined
operators with `FormalSystem.SourceLanguage.tr`, and emit the resulting `Formula`'s JSON.

On success the output is the formula object itself, so a fixture's expected field is directly
comparable. On failure it is `{"error": "..."}`, which is distinguishable without a schema: a
formula object carries `tag` and no `error`.
-/
def translateSentenceLineToJson (line : String) : String :=
  match parseSentence line with
  | .ok s => (tr s).toJson
  | .error e => "{\"error\": \"" ++ escapeJsonString e ++ "\"}"

/-- Round-trip the source side: read a source-sentence JSON object and write it back out. The
canonical form this produces is what `Tests/fixtures/sentence-translation-fixtures.jsonl` stores. -/
def normalizeSentenceLineToJson (line : String) : String :=
  match parseSentence line with
  | .ok s => s.toJson
  | .error e => "{\"error\": \"" ++ escapeJsonString e ++ "\"}"

end BimodalTools.SentenceExport
