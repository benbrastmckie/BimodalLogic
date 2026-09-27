/-
Research probe for the canonical-wire task: the nine observed behaviours of the CURRENT
certificate parser (`BimodalTools/JsonParse.lean` + `BimodalTools/CertificateImport.lean`).
Run with:  lake env lean specs/678_canonical_wire_parser_round_trip/probe-parser-defects.lean
Recorded output is in the research report's Findings section.
-/
import BimodalTools.CertificateImport
open BimodalTools.JsonParse BimodalTools.CertificateImport FormalSystem.Syntax

-- D1 trailing bytes after the top-level object are silently ignored  => Except.ok 3
#eval (parseCertificate "{\"target\":{\"time\":3},\"lassos\":[]} GARBAGE {\"x\":1}").map
  (fun c => c.target.time)

-- D2 an `atom` with no "name" silently becomes the empty-base atom  => base := ""
#eval (pFormula (mkPState "{\"tag\":\"atom\"}")).map (fun p => repr p.1)

-- D3 \uXXXX is silently misdecoded  => base := "u0041" (should be "A")
#eval (pFormula (mkPState "{\"tag\":\"atom\",\"name\":\"\\u0041\"}")).map (fun p => repr p.1)

-- D4 duplicate keys: last wins, silently  => Except.ok 9
#eval (parseCertificate "{\"target\":{\"time\":1},\"target\":{\"time\":9},\"lassos\":[]}").map
  (fun c => c.target.time)

-- D5 malformed JSON inside an unknown field is silently skipped  => Except.ok 3
#eval (parseCertificate "{\"note\":tru,\"target\":{\"time\":3},\"lassos\":[]}").map
  (fun c => c.target.time)

-- D6 a raw control character is emitted unescaped (invalid JSON; Python json.loads rejects it)
#eval Formula.toJson (Formula.atomS "a\tb")

-- D7 ... yet it round-trips through Lean's own parser  => Except.ok true
#eval (pFormula (mkPState (Formula.toJson (Formula.atomS "a\tb")))).map
  (fun p => p.1 == Formula.atomS "a\tb")

-- D8 an extra subformula field on a unary tag is accepted  => box bot
#eval (pFormula (mkPState "{\"tag\":\"box\",\"child\":{\"tag\":\"bot\"},\"left\":{\"tag\":\"bot\"}}")).map
  (fun p => repr p.1)

-- D9 a fractional number DOES error out (the one strict case)  => Except.error
#eval (parseCertificate "{\"target\":{\"time\":3.7},\"lassos\":[]}").map (fun c => c.target.time)

-- D10-D12 the three standard escapes Python's json.dumps emits, all silently misdecoded
#eval (pFormula (mkPState "{\"tag\":\"atom\",\"name\":\"a\\tb\"}")).map (fun p => repr p.1) -- "atb"
#eval (pFormula (mkPState "{\"tag\":\"atom\",\"name\":\"a\\rb\"}")).map (fun p => repr p.1) -- "arb"
#eval (pFormula (mkPState "{\"tag\":\"atom\",\"name\":\"p\\u00e9\"}")).map (fun p => repr p.1) -- "pu00e9"
