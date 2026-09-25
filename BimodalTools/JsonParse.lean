/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax

/-!
# Tag-Format JSON Parser

A hand-rolled recursive-descent JSON parser for the tag-format formula AST that
`BimodalTools.DataExport`'s `Formula.toJson` emits, plus the small envelope primitives its
consumers need (string, natural-number and skip-a-value readers).

This module exists so the parser has exactly one home. It was previously replicated verbatim
inside `BimodalTools/TableauBridge.lean`; that copy has been deleted and the bridge now opens
this namespace instead.

## Consumers

* `BimodalTools/TableauBridge.lean` — the `tableau_bridge` REPL's request envelope
* `BimodalTools/CertificateImport.lean` — the `check_certificate` certificate envelope

`BimodalTools/BenchmarkOracleMain.lean` still carries its own replication. It is an executable
root, so nothing imports it and the duplication is inert; retiring it the same way is a
separate change.

## The tag format

`atom` (with `name`), `bot`, `imp` (`left`, `right`), `box` (`child`), `untl` and `snce` (each
with `event` and `guard`). Unknown object fields are skipped rather than rejected, so a producer
may attach metadata a consumer does not read.

An atom round-trips on its base name only: `Formula.toJson` emits `a.base` and drops
`Atom.freshIndex`, and `pFormula` reads the name back through `Formula.atomS`, which builds
`Atom.mkBase`. A fresh-indexed atom therefore changes identity across a round trip.

## Main Definitions

- `PState` — parser state: the input as a character array, plus a position
- `pString`, `pNat`, `pSkipValue` — JSON scalar and skip primitives
- `pFormula` — the tag-format formula AST reader
-/

set_option autoImplicit false

namespace BimodalTools.JsonParse

open FormalSystem.Syntax

/-- Parser state: remaining characters and position. -/
structure PState where
  chars : Array Char
  pos : Nat
  deriving Repr, Inhabited

def mkPState (s : String) : PState :=
  { chars := s.toList.toArray, pos := 0 }

def pEof (st : PState) : Bool := st.pos >= st.chars.size

def pPeek (st : PState) : Option Char :=
  if st.pos < st.chars.size then st.chars[st.pos]? else none

def pAdvance (st : PState) : PState :=
  { st with pos := st.pos + 1 }

def pSkipWS (st : PState) : PState := Id.run do
  let mut st := st
  while st.pos < st.chars.size do
    match st.chars[st.pos]? with
    | some ' ' | some '\n' | some '\r' | some '\t' =>
      st := { st with pos := st.pos + 1 }
    | _ => break
  st

def pExpect (c : Char) (st : PState) : Except String PState :=
  let st := pSkipWS st
  match pPeek st with
  | some c' =>
    if c == c' then .ok (pAdvance st)
    else .error s!"expected '{c}' got '{c'}' at pos {st.pos}"
  | none => .error s!"expected '{c}' got EOF"

/-- Parse a JSON string value (expects opening quote). -/
partial def pString (st : PState) : Except String (String × PState) := do
  let st := pSkipWS st
  let st ← pExpect '"' st
  let mut result : List Char := []
  let mut st := st
  while true do
    if pEof st then throw "unterminated string"
    match st.chars[st.pos]? with
    | some '"' =>
      st := pAdvance st
      return (String.ofList result.reverse, st)
    | some '\\' =>
      st := pAdvance st
      if pEof st then throw "unterminated escape"
      match st.chars[st.pos]? with
      | some c =>
        st := pAdvance st
        match c with
        | '"' => result := '"' :: result
        | '\\' => result := '\\' :: result
        | 'n' => result := '\n' :: result
        | _ => result := c :: result
      | none => throw "escape at EOF"
    | some c =>
      result := c :: result
      st := pAdvance st
    | none => throw "unexpected none in string parse"
  throw "unreachable"

/-- Skip a JSON value without parsing it (for unknown fields). -/
partial def pSkipValue (st : PState) : Except String PState := do
  let st := pSkipWS st
  match pPeek st with
  | some '"' =>
    let (_, st) ← pString st
    return st
  | some '{' =>
    let mut st := pAdvance st
    let st' := pSkipWS st
    match pPeek st' with
    | some '}' => return (pAdvance st')
    | _ =>
      while true do
        let (_, st') ← pString st
        let st' := pSkipWS st'
        let st' ← pExpect ':' st'
        let st' ← pSkipValue st'
        let st' := pSkipWS st'
        match pPeek st' with
        | some ',' => st := pAdvance st'
        | some '}' => return (pAdvance st')
        | _ => throw "expected , or } in object"
      throw "unreachable"
  | some '[' =>
    let mut st := pAdvance st
    let st' := pSkipWS st
    match pPeek st' with
    | some ']' => return (pAdvance st')
    | _ =>
      while true do
        let st' ← pSkipValue st
        let st' := pSkipWS st'
        match pPeek st' with
        | some ',' => st := pAdvance st'
        | some ']' => return (pAdvance st')
        | _ => throw "expected , or ] in array"
      throw "unreachable"
  | some c =>
    if c == 'n' || c == 't' || c == 'f' || c.isDigit || c == '-' then
      let mut st := st
      while !pEof st do
        match pPeek st with
        | some c' =>
          if c' == ',' || c' == '}' || c' == ']' || c' == ' ' || c' == '\n' then
            break
          st := pAdvance st
        | none => break
      return st
    else
      throw s!"unexpected char '{c}'"
  | none => throw "unexpected EOF in value"

/-- Parse a formula AST from a JSON object. -/
partial def pFormula (st : PState) : Except String (Formula × PState) := do
  let st := pSkipWS st
  let st ← pExpect '{' st
  let mut tag : String := ""
  let mut name : String := ""
  let mut subFormulas : List (String × Formula) := []
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
      let (formula, st') ← pFormula st'
      subFormulas := (key, formula) :: subFormulas
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
  let getField (fname : String) : Except String Formula :=
    match subFormulas.find? (fun (k, _) => k == fname) with
    | some (_, f) => .ok f
    | none => .error s!"missing field '{fname}' for tag '{tag}'"
  match tag with
  | "atom" => return (Formula.atomS name, st)
  | "bot" => return (Formula.bot, st)
  | "imp" =>
    let left ← getField "left"
    let right ← getField "right"
    return (Formula.imp left right, st)
  | "box" =>
    let child ← getField "child"
    return (Formula.box child, st)
  | "untl" =>
    let event ← getField "event"
    let guard ← getField "guard"
    return (Formula.untl guard event, st)
  | "snce" =>
    let event ← getField "event"
    let guard ← getField "guard"
    return (Formula.snce guard event, st)
  | _ => throw s!"unknown tag '{tag}'"

/--
Parse a JSON number (natural number) from the parser state.
-/
partial def pNat (st : PState) : Except String (Nat × PState) := do
  let st := pSkipWS st
  let mut digits : List Char := []
  let mut st := st
  while st.pos < st.chars.size do
    match st.chars[st.pos]? with
    | some c =>
      if c.isDigit then
        digits := c :: digits
        st := pAdvance st
      else
        break
    | none => break
  if digits.isEmpty then
    throw s!"expected number at pos {st.pos}"
  let numStr := String.ofList digits.reverse
  match numStr.toNat? with
  | some n => return (n, st)
  | none => throw s!"invalid number: {numStr}"

end BimodalTools.JsonParse
