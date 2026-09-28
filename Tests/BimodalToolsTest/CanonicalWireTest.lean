/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.CertificateImport

/-!
# The Canonical Wire Codec: defect guards and round-trip rows

The acceptance rows for `BimodalTools/CanonicalWire/`. Two kinds:

1. **Negative rows, one per recorded defect.** The parser this codec replaced was not merely
   unproven but demonstrably wrong: twelve probed behaviours, four of which decoded a
   producing-side atom name into a *different* atom. Each row below asserts the corrected
   behaviour, and for the silent-misdecode cases it asserts **rejection or correct decoding**,
   never a different atom — the whole point being that a certificate is never quietly
   reinterpreted.
2. **Positive rows.** Round trips over the two example certificate families, over atom names
   carrying a tab and a non-ASCII character, and over the canonical form's strictness rules.

The theorems these rows instantiate are in `BimodalTools/CanonicalWire/RoundTrip.lean`,
`Fuel.lean` and `Cert.lean`. The rows are not the evidence; they are checks that the definitions
the theorems are about are the definitions the executable runs.

## D6 and D7 are about emitted bytes, not a parse verdict

Ten of the twelve rows are verdict assertions. D6 (a raw control character emitted unescaped,
which `json.loads` rejects) and D7 (that those invalid bytes nevertheless round-tripped through
Lean's own parser, so the old pair was self-consistent and jointly wrong) are about the bytes the
printer emits. They are asserted here as `#guard`s over `printCertificate`'s output — that it
contains no character below `0x20`, and that it round-trips — rather than as `#eval` rows.
-/

namespace BimodalToolsTest.CanonicalWire

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability.WitnessFamilyExamples
open BimodalTools.CanonicalWire
open BimodalTools.CertificateImport

/-! ## The example families, as wire data

The same two families `CertificateImportTest.lean` uses, rebuilt here so this file stands alone.
-/

/-- `labBack` as a list. -/
def rawBack : List Formula :=
  [Formula.top, pForm.neg, fP, Formula.or fP pP, pP.neg, occurs, occurs.box, once, once.box,
    phiPos]

/-- `labMid` as a list. -/
def rawMid : List Formula :=
  [pForm, Formula.top, fP.neg, pP.neg, occurs, occurs.box, once, once.box, phiPos]

/-- `labFwd` as a list. -/
def rawFwd : List Formula :=
  [Formula.top, pForm.neg, pP, fP.neg, Formula.or fP pP, occurs, occurs.box, once, once.box,
    phiPos]

/-- The non-vacuity family as a certificate. -/
def posRaw : RawCertificate where
  target := { premises := gammaPos, conclusions := delPos, time := 0 }
  bx := [(occurs, true), (once, true)]
  lassos := [{ back := [rawBack], mid := [rawMid], fwd := [rawFwd] }]

/-- The separation family as a certificate. -/
def sepRaw : RawCertificate where
  target := { premises := gammaSep, conclusions := delSep, time := 0 }
  lassos := [{ back := [[pForm, phiSep]], mid := [], fwd := [[pForm, phiSep]] }]

/-- A certificate whose atom names carry a tab and a non-ASCII character. The tab must be escaped
on the wire and must survive the round trip; the non-ASCII character passes through as UTF-8. -/
def escapedRaw : RawCertificate :=
  { sepRaw with
    target := { sepRaw.target with
      premises := [Formula.atomS "a\tb", Formula.atomS "pé", Formula.atomS (String.ofList
        [Char.ofNat 1])] } }

/-! ## The twelve defect rows

Each names the behaviour of the parser this codec replaced, then asserts the corrected one.
-/

-- D1. Trailing bytes after the top-level object were silently ignored (the old parser answered
-- `Except.ok 3` for this input). The canonical entry point requires end of input.
#guard (parseCertificateCanonical
  "{\"target\":{\"time\":3},\"lassos\":[]} GARBAGE {\"x\":1}").isOk = false

-- D2. An `atom` with no `"name"` silently became the empty-base atom. A formula object must carry
-- exactly its tag's own fields, so this is now a protocol error rather than a different atom.
#guard (parseCertificateCanonical
  "{\"target\":{\"premises\":[{\"tag\":\"atom\"}],\"time\":0}}").isOk = false

-- D3. `\u0041` was silently misdecoded to the five-character name `u0041` instead of `A`. The
-- settled joint-contract decision is to REJECT `\uXXXX` outside the control range, and to pin
-- `ensure_ascii=False` on the producing side, rather than to guess at surrogate pairs.
#guard (parseCertificateCanonical
  "{\"target\":{\"premises\":[{\"tag\":\"atom\",\"name\":\"\\u0041\"}],\"time\":0}}").isOk = false

-- D4. Duplicate keys: last wins, silently (the old parser answered `Except.ok 9` here). Rejected
-- now, at every nesting level.
#guard (parseCertificateCanonical
  "{\"target\":{\"time\":1},\"target\":{\"time\":9},\"lassos\":[]}").isOk = false

-- D5. Malformed JSON inside an unrecognised field was silently skipped. Unknown *keys* are still
-- tolerated, but only after their values have been fully parsed.
#guard (parseCertificateCanonical
  "{\"note\":tru,\"target\":{\"time\":3},\"lassos\":[]}").isOk = false

-- D6. A raw control character was emitted unescaped, which is invalid JSON — `json.loads` rejects
-- it. The canonical printer escapes every character below `0x20`, so its output contains none.
#guard ((printCertificate escapedRaw).toList.any fun c => c.toNat < 32) = false

-- D7. Those invalid bytes nevertheless round-tripped through Lean's own parser, so the old
-- printer/parser pair was self-consistent and jointly wrong. The canonical pair is self-consistent
-- and emits valid JSON, which D6 above asserts.
#guard parseCertificateCanonical (printCertificate escapedRaw) = .ok escapedRaw

-- D8. An extra sub-formula field on a unary tag was accepted (`box` with both `child` and `left`
-- decoded as `box bot`). A formula object must carry exactly its tag's own fields.
#guard (parseCertificateCanonical
    ("{\"target\":{\"premises\":[{\"tag\":\"box\",\"child\":{\"tag\":\"bot\"}," ++
      "\"left\":{\"tag\":\"bot\"}}],\"time\":0}}")).isOk = false

-- D9. A fractional number did error out — the one strict case in the old parser — but for the
-- wrong reason. It is now rejected as a non-canonical numeral, by the same rule that rejects a
-- leading zero, a `+` sign and `-0`.
#guard (parseCertificateCanonical "{\"target\":{\"time\":3.7},\"lassos\":[]}").isOk = false

-- D10. `\t` was silently misdecoded, turning the name `a<tab>b` into `atb`. It now decodes
-- correctly, which is the other acceptable outcome: the name that arrives is the name that was
-- sent.
#guard parseCanonical "\"a\\tb\"" = .ok (CJson.str "a\tb".toList)

-- D11. `\r` was silently misdecoded the same way, turning `a<cr>b` into `arb`.
#guard parseCanonical "\"a\\rb\"" = .ok (CJson.str "a\rb".toList)

-- D12. `\u00e9` was silently misdecoded, turning `pé` into `pu00e9`. Rejected now, by the same
-- rule as D3. A producer pinned to `ensure_ascii=False` sends the UTF-8 bytes instead, which pass
-- through unchanged — the row below D12 checks that.
#guard (parseCanonical "\"p\\u00e9\"").isOk = false

#guard parseCanonical "\"pé\"" = .ok (CJson.str "pé".toList)

/-! ## The canonical form's strictness rules -/

-- A leading zero, a `+` sign and `-0` are all non-canonical numerals.
#guard (parseCanonical "01").isOk = false
#guard (parseCanonical "+1").isOk = false
#guard (parseCanonical "-0").isOk = false

-- Uppercase hex in a `\u` escape is not canonical either; the printer emits lowercase.
#guard (parseCanonical "\"\\u001F\"").isOk = false

-- The control-range `\u00XX` form IS accepted, because the canonical printer emits it.
#guard parseCanonical "\"\\u0001\"" = .ok (CJson.str [Char.ofNat 1])

-- A raw control character inside a string literal is rejected.
#guard (parseCanonical (String.ofList ['"', Char.ofNat 9, '"'])).isOk = false

-- An unsupported escape is rejected rather than passed through as its own letter.
#guard (parseCanonical "\"\\q\"").isOk = false

-- No whitespace is tolerated inside a document; trailing whitespace after the value is.
#guard (parseCanonical "{ }").isOk = false
#guard (parseCanonical "{}  \n").isOk = true

/-! ## Round trips

Instances of `BimodalTools.CanonicalWire.parse_print`, which states the same thing for every
base-atom certificate.
-/

#guard parseCertificateCanonical (printCertificate posRaw) = .ok posRaw

#guard parseCertificateCanonical (printCertificate sepRaw) = .ok sepRaw

-- The canonical form is compact: no space follows a `:` or a `,`.
#guard (printCertificate sepRaw).toList.all (fun c => c != ' ') = true

-- A nested value whose object key carries a tab and whose string value carries a quote.
#guard parseCanonical (printCanonical
    (.obj (.cons "a\tb".toList (.arr (.cons (.str "x\"y".toList) (.cons (.int (-12)) .nil)))
      (.cons "c".toList (.obj (.cons "d".toList (.bool false) .nil)) .nil)))) =
  .ok (.obj (.cons "a\tb".toList (.arr (.cons (.str "x\"y".toList) (.cons (.int (-12)) .nil)))
    (.cons "c".toList (.obj (.cons "d".toList (.bool false) .nil)) .nil)))

/-! ## A wire-level fresh index is rejected

Atom identity is base-only, so a `"freshIndex"` on an atom object is not part of any tag's shape
and is rejected rather than ignored. `BimodalTools.CanonicalWire.parse_base_only` states the
consequence as a theorem: anything the parser returns carries base-only atoms.
-/

#guard (parseCertificateCanonical
    ("{\"target\":{\"premises\":[{\"tag\":\"atom\",\"name\":\"p\"," ++
      "\"freshIndex\":3}],\"time\":0}}")).isOk = false

/-! ## The output line's echo

A verdict about a certificate carries an `"echo"`; a protocol error does not.
-/

#guard ((checkLineToJson (printCertificate sepRaw)).splitOn "\"echo\":").length = 2

#guard ((checkLineToJson (printCertificate posRaw)).splitOn "\"echo\":").length = 2

#guard ((checkLineToJson "{ nonsense").splitOn "\"echo\":").length = 1

-- The echoed value, unescaped, is the canonical form of the certificate that was sent — so a
-- consumer comparing its own bytes against the echo is comparing what was actually checked.
#guard (checkLineToJson (printCertificate sepRaw)).endsWith
  ("\"echo\":" ++ canonicalString (printCertificate sepRaw) ++ "}") = true

-- Trailing whitespace on the input does not disturb the echo: the comparison is modulo
-- surrounding whitespace, because `main` forwards the producer's trailing newline verbatim.
#guard checkLineToJson (printCertificate sepRaw ++ "\n") =
  checkLineToJson (printCertificate sepRaw)

end BimodalToolsTest.CanonicalWire
