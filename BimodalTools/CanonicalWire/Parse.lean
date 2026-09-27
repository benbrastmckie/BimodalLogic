/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.CanonicalWire.Json

/-!
# Canonical Wire Format, Layer 1: the total parser

The reading half of the generic codec. Every function here is a **total** `def`: none is
`partial`, and none uses `do`-notation.

## Why totality is the point

A `partial def` has no equation lemmas, so no theorem about it is possible *in principle* — not
merely unproved. The parser this replaces was `partial def` with `while true do` throughout, and
it was also silently wrong: twelve recorded defects, four of which decoded a producing-side atom
name into a *different* atom. Totality here is achieved by a fuel parameter whose sufficiency is
proved in `Fuel.lean`, so "out of fuel" is unreachable on input the public entry point is given
rather than merely unlikely. The containment is worth stating: an exhausted fuel budget can only
cause a spurious *rejection*, never a misinterpretation.

## Why no `do`-notation

`do` desugars to `<$>` and `bind`, which `simp` will not reduce, so every goal in the round-trip
proof would stall on the monadic plumbing. Every branch below is an explicit
`match … with | .ok … | .error …`. This is a load-bearing constraint on this file, not a style
preference.

## What is rejected

Strictness is the whole point: a canonical codec that accepts more than it prints is not a
section of its own printer.

- Trailing bytes after the top-level value (whitespace excepted).
- A missing `"name"` on an `atom`, an unknown `"tag"` — enforced at the schema layer in
  `Cert.lean`, which this layer makes possible by parsing the whole document first.
- A duplicate key, at every nesting level.
- Any escape but `\" \\ \/ \b \f \n \r \t` and `\u00XX` with `XX < 20`. In particular a general
  `\uXXXX` is **rejected**, which is the settled joint-contract decision: the producing side
  pins `ensure_ascii=False` rather than this side guessing at surrogate pairs. The control-range
  `\u00XX` form is accepted because the canonical printer emits it, and for no other reason.
- A raw character below `0x20` inside a string literal.
- A non-canonical numeral: a leading zero, `+`, `-0`, a fraction or an exponent. The check is
  "reprinting the parsed value reproduces the bytes", which is exactly the right condition and
  needs no separate syntactic side conditions.
- Malformed content inside an unrecognised field. Unknown *keys* are ignored at the schema layer,
  but only after this layer has fully parsed their values, which is what closes the defect where
  malformed JSON hid inside a field the checker did not read.

## Main Definitions

- `isWS`, `hexVal`, `simpleEscape`, `charDigit` — the lexical tables
- `unescapeBody` — the string escape codec's reading half, stopping at the closing quote
- `takeDigits`, `natOfDigitChars`, `parseDigits`, `parseInt` — the decimal codec's reading half
- `parseCJson`, `parseElems`, `parseFields` — the fuel-indexed total parser
- `parseCanonical` — the public entry point: seeds the fuel and requires end of input

## References

* `BimodalTools/CanonicalWire/Json.lean` — the value and the canonical printer this inverts
* `BimodalTools/CanonicalWire/RoundTrip.lean` — the theorem that it does invert it
-/

set_option autoImplicit false

namespace BimodalTools.CanonicalWire

/-!
## Lexical tables
-/

/-- The message every out-of-fuel branch reports. Named so that `Fuel.lean` can state that no
run of the public entry point produces it. -/
def outOfFuelMsg : String := "canonical parser ran out of fuel"

/-- Whitespace the strict entry point tolerates *after* the top-level value. No whitespace is
tolerated inside a document: the canonical form emits none. -/
def isWS (c : Char) : Bool := c = ' ' || c = '\n' || c = '\r' || c = '\t'

/-- The value of a lowercase hexadecimal digit. Uppercase is not canonical and is rejected. -/
def hexVal (c : Char) : Option Nat :=
  if '0' ≤ c && c ≤ '9' then some (c.toNat - 48)
  else if 'a' ≤ c && c ≤ 'f' then some (c.toNat - 87)
  else none

/-- The character a single-character escape denotes, or `none` if the escape is unsupported.
`\/` is accepted although the canonical printer never emits it: JSON allows it and accepting it
costs nothing, because the round-trip guarantee runs from the printer's image outward. -/
def simpleEscape (c : Char) : Option Char :=
  if c = '"' then some '"'
  else if c = '\\' then some '\\'
  else if c = '/' then some '/'
  else if c = 'b' then some chBackspace
  else if c = 'f' then some chFormFeed
  else if c = 'n' then some '\n'
  else if c = 'r' then some '\r'
  else if c = 't' then some '\t'
  else none

/-- The value of a decimal digit character. -/
def charDigit (c : Char) : Nat := c.toNat - 48

/-!
## The string escape codec, reading half

Structural recursion throughout: every recursive call is on a pattern-matched tail of the input,
so this is a `def` with equation lemmas rather than a `partial def`.
-/

/-- Read the body of a string literal, consuming the closing quote. Returns the decoded
characters and the remainder after the quote. -/
def unescapeBody : List Char → Except String (List Char × List Char)
  | [] => .error "unterminated string literal"
  | c :: cs =>
    if c = '"' then .ok ([], cs)
    else if c = '\\' then
      match cs with
      | [] => .error "unterminated escape at end of input"
      | e :: r =>
        if e = 'u' then
          match r with
          | a :: b :: d :: g :: r' =>
            match hexVal d, hexVal g with
            | some hd, some hg =>
              if a = '0' && b = '0' && 16 * hd + hg < 32 then
                match unescapeBody r' with
                | .error m => .error m
                | .ok (s, rr) => .ok (Char.ofNat (16 * hd + hg) :: s, rr)
              else .error "\\u is supported only as \\u00XX with XX below 20"
            | _, _ => .error "malformed \\u escape"
          | _ => .error "truncated \\u escape"
        else
          match simpleEscape e with
          | none => .error "unsupported escape sequence"
          | some d =>
            match unescapeBody r with
            | .error m => .error m
            | .ok (s, rr) => .ok (d :: s, rr)
    else if c.toNat < 32 then
      .error "raw control character in string literal"
    else
      match unescapeBody cs with
      | .error m => .error m
      | .ok (s, rr) => .ok (c :: s, rr)

/-!
## The decimal codec, reading half

The canonicality check is `printDigits n = ds`: a numeral is accepted exactly when it is the one
the canonical printer would emit. That single condition subsumes every syntactic rule — no
leading zero, no `+`, no fraction, no exponent — and, unlike a hand-written list of side
conditions, it cannot drift away from the printer it is supposed to invert.
-/

/-- Split off the maximal leading run of decimal digits. -/
def takeDigits : List Char → List Char × List Char
  | [] => ([], [])
  | c :: cs =>
    if c.isDigit then
      match takeDigits cs with
      | (ds, r) => (c :: ds, r)
    else ([], c :: cs)

/-- The natural number a most-significant-first digit string denotes. -/
def natOfDigitChars (ds : List Char) : Nat := Nat.ofDigits 10 (ds.reverse.map charDigit)

/-- Read a canonical decimal numeral. -/
def parseDigits (cs : List Char) : Except String (Nat × List Char) :=
  match takeDigits cs with
  | (ds, r) =>
    if ds.isEmpty then .error "expected a decimal numeral"
    else
      let n := natOfDigitChars ds
      if printDigits n = ds then .ok (n, r)
      else .error "non-canonical decimal numeral"

/-- Read a canonical signed integer. `-0` is rejected: `printInt 0` is `0`. -/
def parseInt : List Char → Except String (Int × List Char)
  | [] => .error "expected an integer"
  | c :: cs =>
    if c = '-' then
      match parseDigits cs with
      | .error m => .error m
      | .ok (n, r) => if n = 0 then .error "-0 is not a canonical integer" else .ok (-(n : Int), r)
    else
      match parseDigits (c :: cs) with
      | .error m => .error m
      | .ok (n, r) => .ok ((n : Int), r)

/-!
## The total parser

One fuel unit per recursive descent. Each of the three functions has exactly **one** equation
per fuel successor — the dispatch is an `if` chain on the head character rather than a family of
overlapping patterns — so `simp only [parseCJson]` reduces a goal without leaving arm-overlap
side conditions behind. That shape is what makes the round-trip proof tractable.
-/

mutual

/-- Parse one canonical value, or report why the bytes are not one. -/
def parseCJson : Nat → List Char → Except String (CJson × List Char)
  | 0, _ => .error outOfFuelMsg
  | f + 1, cs =>
    match cs with
    | [] => .error "expected a value, got end of input"
    | c :: cs' =>
      if c = '"' then
        match unescapeBody cs' with
        | .error m => .error m
        | .ok (s, r) => .ok (.str s, r)
      else if c = '[' then
        match cs' with
        | ']' :: r => .ok (.arr .nil, r)
        | _ =>
          match parseElems f cs' with
          | .error m => .error m
          | .ok (xs, r) => .ok (.arr xs, r)
      else if c = '{' then
        match cs' with
        | '}' :: r => .ok (.obj .nil, r)
        | _ =>
          match parseFields f cs' with
          | .error m => .error m
          | .ok (fs, r) => .ok (.obj fs, r)
      else if c = 't' then
        match cs' with
        | 'r' :: 'u' :: 'e' :: r => .ok (.bool true, r)
        | _ => .error "expected the literal true"
      else if c = 'f' then
        match cs' with
        | 'a' :: 'l' :: 's' :: 'e' :: r => .ok (.bool false, r)
        | _ => .error "expected the literal false"
      else
        match parseInt (c :: cs') with
        | .error m => .error m
        | .ok (i, r) => .ok (.int i, r)

/-- Parse a non-empty array's elements, consuming the closing `]`. -/
def parseElems : Nat → List Char → Except String (CJsonList × List Char)
  | 0, _ => .error outOfFuelMsg
  | f + 1, cs =>
    match parseCJson f cs with
    | .error m => .error m
    | .ok (x, r) =>
      match r with
      | ',' :: r' =>
        match parseElems f r' with
        | .error m => .error m
        | .ok (xs, r'') => .ok (.cons x xs, r'')
      | ']' :: r' => .ok (.cons x .nil, r')
      | _ => .error "expected , or ] in array"

/-- Parse a non-empty object's fields, consuming the closing `}`. A key that already occurs in
the *rest* of the object is a duplicate, which is rejected — the recursion reads right to left,
so checking against the tail catches every repetition. -/
def parseFields : Nat → List Char → Except String (CJsonObj × List Char)
  | 0, _ => .error outOfFuelMsg
  | f + 1, cs =>
    match cs with
    | '"' :: cs' =>
      match unescapeBody cs' with
      | .error m => .error m
      | .ok (k, r0) =>
        match r0 with
        | ':' :: r1 =>
          match parseCJson f r1 with
          | .error m => .error m
          | .ok (v, r2) =>
            match r2 with
            | ',' :: r3 =>
              match parseFields f r3 with
              | .error m => .error m
              | .ok (fs, r4) =>
                if hasKey k fs then .error "duplicate key in object" else .ok (.cons k v fs, r4)
            | '}' :: r3 => .ok (.cons k v .nil, r3)
            | _ => .error "expected , or } in object"
        | _ => .error "expected : after an object key"
    | _ => .error "expected a quoted object key"

end

/-- The public entry point: seed the fuel from the input's own length, parse one value, skip
trailing whitespace and then **require** end of input. Trailing bytes are a protocol error, not
something to ignore. -/
def parseCanonical (s : String) : Except String CJson :=
  let cs := s.toList
  match parseCJson (cs.length + 1) cs with
  | .error m => .error m
  | .ok (j, rest) =>
    if rest.all isWS then .ok j
    else .error "unexpected trailing bytes after the top-level value"

end BimodalTools.CanonicalWire
