/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Nat.Digits.Lemmas
import Mathlib.Tactic.IntervalCases

/-!
# Canonical Wire Format, Layer 1: the value and its printer

The generic half of the verified certificate codec: a JSON value restricted to what the
certificate wire format uses, a **canonical** printer for it, and the measure that makes the
companion parser total. `BimodalTools/CanonicalWire/Parse.lean` supplies the parser,
`BimodalTools/CanonicalWire/RoundTrip.lean` the theorem that the two compose to the identity,
and `BimodalTools/CanonicalWire/Cert.lean` the certificate schema on top.

## The layer-1 contract

- **Compact.** No whitespace is ever emitted: no space after `:` or `,`, no newline anywhere.
  A parser that accepts whitespace would accept many byte strings per value, and the printer
  would stop being a section of the parser.
- **Fields in encode order.** `CJsonObj` is an ordered association list, so a value fixes its
  own key order and reprinting is byte-stable. Key order is part of the canonical form.
- **`List Char`, not `String`.** The round-trip lemma has the shape
  `parse (print x ++ rest) = .ok (x, rest)`, which is only tractable over list remainders.
  `String.toList_append` and `String.toList_ofList` bridge back to `String` at the public edge.
- **One escape per character.** `"` and `\` escape as themselves; the five control characters
  JSON names escape as `\b \f \n \r \t`; every other character below `0x20` escapes as
  `\u00XX` with lowercase hex. Everything from `0x20` up, including non-ASCII, passes through
  as UTF-8. There is therefore exactly one canonical byte string per string value, which is
  what makes the printer injective.

## Why the empty cases of `size` are `0`

`size` is the fuel budget the parser is seeded with, and the sufficiency proof needs
`size j ≤ (printCJson j).length`. The naive measure, counting every node as at least one unit,
fails that bound at the empty-array leaf — `[]` is two bytes but would need three units. The
empty list and empty object therefore measure `0`, which is sound because neither consumes a
recursive descent.

## Main Definitions

- `CJson`, `CJsonList`, `CJsonObj` — the canonical value, as mutual inductives. Mutual rather
  than a nested `List CJson` field, so that the recursors the round-trip proof needs exist
- `hasKey`, `Canonical`, `CanonicalList`, `CanonicalObj` — the well-formedness predicate the
  round-trip theorem is hypothesised on: no key repeats within one object
- `escapeChar`, `escapeBody`, `hexDigit` — the string escape codec's printing half
- `digitChar`, `printDigits`, `printInt` — the decimal codec's printing half, through
  `Nat.digits` rather than `toString`, because `Nat.ofDigits_digits` is the inverse lemma and
  nothing relates `toString` to `String.toNat?`
- `printKey`, `printCJson`, `printCJsonList`, `printCJsonObj`, `printCanonical` — the canonical
  printer
- `size`, `sizeList`, `sizeObj` — the fuel measure

## References

* `BimodalTools/CanonicalWire/README.md` — the directory's contract and module map
* `BimodalTools/README.md` — the certificate protocol, including the joint canonical contract
-/

set_option autoImplicit false

namespace BimodalTools.CanonicalWire

/-!
## The canonical value

Five scalar and structural shapes, which is exactly what the certificate schema uses: strings
(atom names and tags), integers (times), booleans (the box guess), arrays and objects. No
floating point and no `null`, because the certificate format has no use for either and a codec
that cannot represent them cannot mis-round-trip them.
-/

mutual

/-- A canonical JSON value: the subset of JSON the certificate wire format uses. -/
inductive CJson where
  /-- A string, as its decoded (unescaped) characters. -/
  | str (s : List Char)
  /-- A signed integer. -/
  | int (i : Int)
  /-- A boolean. -/
  | bool (b : Bool)
  /-- An array. -/
  | arr (xs : CJsonList)
  /-- An object: an ordered association list, so key order is part of the value. -/
  | obj (fs : CJsonObj)

/-- The elements of a `CJson.arr`, as a dedicated inductive rather than a `List CJson` field:
a nested inductive would not give the mutual recursors the round-trip proof needs. -/
inductive CJsonList where
  /-- The empty array. -/
  | nil
  /-- One element followed by the rest. -/
  | cons (x : CJson) (xs : CJsonList)

/-- The fields of a `CJson.obj`, in emission order. -/
inductive CJsonObj where
  /-- The empty object. -/
  | nil
  /-- One `key : value` field followed by the rest. -/
  | cons (k : List Char) (v : CJson) (fs : CJsonObj)

end

deriving instance Repr, DecidableEq for CJson, CJsonList, CJsonObj

/-- Does this object already carry the given key? The duplicate-key check, as a `Bool`. -/
def hasKey (k : List Char) : CJsonObj → Bool
  | .nil => false
  | .cons k' _ fs => k == k' || hasKey k fs

mutual

/-- Well-formedness: no key repeats within one object, at any nesting depth.

Nothing is asked of strings. A raw control character inside a string value is not excluded
here, and does not need to be: `escapeChar` escapes every character below `0x20`, so the
printer never emits one raw, and the parser rejects one if it ever sees one. The predicate
therefore carries only the condition the printer cannot enforce on its own. -/
def Canonical : CJson → Prop
  | .str _ => True
  | .int _ => True
  | .bool _ => True
  | .arr xs => CanonicalList xs
  | .obj fs => CanonicalObj fs

/-- `Canonical`, elementwise over an array. -/
def CanonicalList : CJsonList → Prop
  | .nil => True
  | .cons x xs => Canonical x ∧ CanonicalList xs

/-- `Canonical` for an object: each field's value is canonical, and no key repeats. -/
def CanonicalObj : CJsonObj → Prop
  | .nil => True
  | .cons k v fs => hasKey k fs = false ∧ Canonical v ∧ CanonicalObj fs

end

/-!
## The string escape codec, printing half

`\b` and `\f` are spelled through `Char.ofNat` rather than as character literals, so the source
carries no raw control byte of its own.
-/

/-- The backspace character, `U+0008`, which JSON escapes as `\b`. -/
def chBackspace : Char := Char.ofNat 8

/-- The form-feed character, `U+000C`, which JSON escapes as `\f`. -/
def chFormFeed : Char := Char.ofNat 12

/-- The lowercase hexadecimal digit for a value below `16`. -/
def hexDigit (n : Nat) : Char :=
  if n < 10 then Char.ofNat (n + 48) else Char.ofNat (n + 87)

/-- The canonical escape of one character: exactly one form per character, which is what makes
the printer injective on string values. -/
def escapeChar (c : Char) : List Char :=
  if c = '"' then ['\\', '"']
  else if c = '\\' then ['\\', '\\']
  else if c = '\n' then ['\\', 'n']
  else if c = '\r' then ['\\', 'r']
  else if c = '\t' then ['\\', 't']
  else if c = chBackspace then ['\\', 'b']
  else if c = chFormFeed then ['\\', 'f']
  else if c.toNat < 32 then
    ['\\', 'u', '0', '0', hexDigit (c.toNat / 16), hexDigit (c.toNat % 16)]
  else [c]

/-- The body of a canonical string literal: every character escaped, no delimiting quotes. -/
def escapeBody : List Char → List Char
  | [] => []
  | c :: cs => escapeChar c ++ escapeBody cs

/-!
## The decimal codec, printing half

Through `Nat.digits 10`, never `toString`: `Nat.ofDigits_digits` is exactly the inverse lemma
the round trip needs, and no core or Mathlib lemma relates `toString` to `String.toNat?`.
-/

/-- The decimal character for a value below `10`. -/
def digitChar (d : Nat) : Char := Char.ofNat (d + 48)

/-- The canonical decimal numeral of a natural number. `Nat.digits 10 0 = []`, so zero is
special-cased; every other numeral is the base-10 digits, most significant first. -/
def printDigits (n : Nat) : List Char :=
  if n = 0 then ['0'] else ((Nat.digits 10 n).map digitChar).reverse

/-- The canonical numeral of a signed integer. `-0` is unreachable: `printInt 0` is `0`. -/
def printInt (i : Int) : List Char :=
  if i < 0 then '-' :: printDigits i.natAbs else printDigits i.natAbs

/-!
## The canonical printer
-/

/-- The canonical bytes of an object key: the quoted, escaped key and its `:`. -/
def printKey (k : List Char) : List Char := '"' :: (escapeBody k ++ ['"', ':'])

mutual

/-- The canonical bytes of a value. Compact: no whitespace anywhere. -/
def printCJson : CJson → List Char
  | .str s => '"' :: (escapeBody s ++ ['"'])
  | .int i => printInt i
  | .bool b => if b then ['t', 'r', 'u', 'e'] else ['f', 'a', 'l', 's', 'e']
  | .arr xs => '[' :: printCJsonList xs
  | .obj fs => '{' :: printCJsonObj fs

/-- The canonical bytes of an array's elements, **including** the closing `]`. Carrying the
closing bracket here rather than at the `arr` node is what makes the parser's recursion and the
printer's recursion the same shape, which is what the round-trip proof needs. -/
def printCJsonList : CJsonList → List Char
  | .nil => [']']
  | .cons x .nil => printCJson x ++ [']']
  | .cons x xs => printCJson x ++ ',' :: printCJsonList xs

/-- The canonical bytes of an object's fields, **including** the closing `}`. -/
def printCJsonObj : CJsonObj → List Char
  | .nil => ['}']
  | .cons k v .nil => printKey k ++ printCJson v ++ ['}']
  | .cons k v fs => printKey k ++ printCJson v ++ ',' :: printCJsonObj fs

end

/-- The canonical bytes of a value, as a `String`: the public printing entry point. -/
def printCanonical (j : CJson) : String := String.ofList (printCJson j)

/-!
## The fuel measure

One unit per recursive descent the parser makes, and `0` at the two empty leaves, which the
parser reaches without descending. `RoundTrip.lean` proves `size j ≤ (printCJson j).length`,
and `Fuel.lean` composes that with the round-trip theorem to show the fuel the public entry
point seeds is always enough.
-/

mutual

/-- The fuel a value needs. -/
def size : CJson → Nat
  | .str _ => 1
  | .int _ => 1
  | .bool _ => 1
  | .arr xs => sizeList xs + 1
  | .obj fs => sizeObj fs + 1

/-- The fuel an array's elements need. `0` at the empty array: the parser reads `[]` without
descending, and a positive value here would make the measure bound unsatisfiable. -/
def sizeList : CJsonList → Nat
  | .nil => 0
  | .cons x xs => size x + sizeList xs + 1

/-- The fuel an object's fields need. `0` at the empty object, for the same reason. -/
def sizeObj : CJsonObj → Nat
  | .nil => 0
  | .cons _ v fs => size v + sizeObj fs + 1

end

end BimodalTools.CanonicalWire
