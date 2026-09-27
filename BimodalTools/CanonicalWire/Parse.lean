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

/-- Prepend a decoded character to a successful string-literal result.

A named function rather than an inline `match` because `RoundTrip.lean` has to *state* this shape
in a lemma, and two `match` expressions that print identically are still two distinct anonymous
auxiliary functions, which no amount of `simp` will identify. Naming it makes the lemma's
right-hand side and the definition's body the same term. -/
def consResult (c : Char) :
    Except String (List Char × List Char) → Except String (List Char × List Char)
  | .error m => .error m
  | .ok (s, rr) => .ok (c :: s, rr)

mutual

/-- Read the body of a string literal, consuming the closing quote. Returns the decoded
characters and the remainder after the quote.

Split across three mutually recursive functions rather than written with nested `match`es inside
one. The split is load-bearing for `RoundTrip.lean`, not cosmetic: the equation compiler splits
*every* `match` in a function's body when it generates that function's equation lemmas, including
matches in branches a concrete input never reaches. A nested `match` on the four hex positions
therefore made `rw [unescapeBody]` emit an unprovable side goal about the *unrelated* simple-escape
branch. With the three functions below, `unescapeBody` and `unescapeAfterBackslash` each have one
unconditional equation per constructor, and only `unescapeUEscape` splits — on input that is
concrete wherever it matters. -/
def unescapeBody : List Char → Except String (List Char × List Char)
  | [] => .error "unterminated string literal"
  | c :: cs =>
    if c = '"' then .ok ([], cs)
    else if c = '\\' then unescapeAfterBackslash cs
    else if c.toNat < 32 then .error "raw control character in string literal"
    else consResult c (unescapeBody cs)

/-- Read an escape sequence and the rest of the string literal, given the characters after the
backslash. -/
def unescapeAfterBackslash : List Char → Except String (List Char × List Char)
  | [] => .error "unterminated escape at end of input"
  | e :: r =>
    if e = 'u' then unescapeUEscape r
    else
      match simpleEscape e with
      | none => .error "unsupported escape sequence"
      | some d => consResult d (unescapeBody r)

/-- Read a `\u00XX` escape and the rest of the string literal, given the characters after the
`u`. Only the canonical control-character form is accepted: two `0`s, two lowercase hex digits,
and a value below `0x20`. Every other `\uXXXX` is a protocol error — the settled joint-contract
decision, which the producing side honours by pinning `ensure_ascii=False`. -/
def unescapeUEscape : List Char → Except String (List Char × List Char)
  | a :: b :: d :: g :: r' =>
    match hexVal d, hexVal g with
    | some hd, some hg =>
      if a = '0' && b = '0' && 16 * hd + hg < 32 then
        consResult (Char.ofNat (16 * hd + hg)) (unescapeBody r')
      else .error "\\u is supported only as \\u00XX with XX below 20"
    | _, _ => .error "malformed \\u escape"
  | _ => .error "truncated \\u escape"

end

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
per fuel successor, and every look-ahead past the first character goes through `List.head?`,
`List.tail`, `List.take` and `List.drop` rather than through a nested pattern match. Both are
load-bearing for `RoundTrip.lean`: a nested `match` on a *pattern variable* makes the equation
compiler split the enclosing function's equations by input shape, and `rw` then emits side goals
about branches the input never reaches — for a printed string value, four unprovable ones about
the array, object and keyword branches. With the shape below, `rw [parseCJson]` produces exactly
one goal.
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
        if cs'.head? = some ']' then .ok (.arr .nil, cs'.tail)
        else
          match parseElems f cs' with
          | .error m => .error m
          | .ok (xs, r) => .ok (.arr xs, r)
      else if c = '{' then
        if cs'.head? = some '}' then .ok (.obj .nil, cs'.tail)
        else
          match parseFields f cs' with
          | .error m => .error m
          | .ok (fs, r) => .ok (.obj fs, r)
      else if c = 't' then
        if cs'.take 3 = ['r', 'u', 'e'] then .ok (.bool true, cs'.drop 3)
        else .error "expected the literal true"
      else if c = 'f' then
        if cs'.take 4 = ['a', 'l', 's', 'e'] then .ok (.bool false, cs'.drop 4)
        else .error "expected the literal false"
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
      if r.head? = some ',' then
        match parseElems f r.tail with
        | .error m => .error m
        | .ok (xs, r') => .ok (.cons x xs, r')
      else if r.head? = some ']' then .ok (.cons x .nil, r.tail)
      else .error "expected , or ] in array"

/-- Parse a non-empty object's fields, consuming the closing `}`. A key that already occurs in
the *rest* of the object is a duplicate, which is rejected — the recursion reads right to left,
so checking against the tail catches every repetition. -/
def parseFields : Nat → List Char → Except String (CJsonObj × List Char)
  | 0, _ => .error outOfFuelMsg
  | f + 1, cs =>
    if cs.head? = some '"' then
      match unescapeBody cs.tail with
      | .error m => .error m
      | .ok (k, r0) =>
        if r0.head? = some ':' then
          match parseCJson f r0.tail with
          | .error m => .error m
          | .ok (v, r2) =>
            if r2.head? = some ',' then
              match parseFields f r2.tail with
              | .error m => .error m
              | .ok (fs, r4) =>
                if hasKey k fs then .error "duplicate key in object" else .ok (.cons k v fs, r4)
            else if r2.head? = some '}' then .ok (.cons k v .nil, r2.tail)
            else .error "expected , or } in object"
        else .error "expected : after an object key"
    else .error "expected a quoted object key"

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
