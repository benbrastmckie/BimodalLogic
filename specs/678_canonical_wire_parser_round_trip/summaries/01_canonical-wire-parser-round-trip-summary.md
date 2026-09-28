# Implementation Summary: Task #678

- **Task**: 678 - canonical_wire_parser_round_trip
- **Status**: [COMPLETED]
- **Started**: 2026-09-27T21:37:41Z
- **Completed**: 2026-09-28T00:31:29Z
- **Effort**: ~3 hours
- **Dependencies**: 677 (completed)
- **Artifacts**: plans/01_canonical-wire-parser-round-trip.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The certificate wire format now has a canonical printer and a **total** parser, and the two are
proved inverse: `BimodalTools.CanonicalWire.parse_print` states that parsing a printed certificate
returns that same certificate. Deserialization has therefore left the trust base. The parser it
replaced was `partial def` with `while true do` throughout — so no theorem about it was possible
*in principle*, not merely unproved — and it was also silently wrong in twelve recorded ways, four
of which decoded a producing-side atom name into a *different* atom. All nine phases landed; all
nine pinned theorems are proved; all twelve defects are closed by a negative `#guard`.

## What Changed

New, all under `BimodalTools/CanonicalWire/`:

- `Json.lean` (265) — the canonical value `CJson`/`CJsonList`/`CJsonObj` as mutual inductives, the
  `Canonical` well-formedness predicate, the escape and decimal codecs' printing halves, the
  compact canonical printer, and the fuel measure (empty cases `0`, as the measure bound requires)
- `Parse.lean` (316) — `unescapeBody`/`unescapeAfterBackslash`/`unescapeUEscape`, `parseDigits`,
  `parseInt`, the fuel-indexed **total** `parseCJson`/`parseElems`/`parseFields`, and the strict
  entry point `parseCanonical`. No `partial`, no `do`-notation
- `RoundTrip.lean` (536) — `unescape_escape`, `parseDigits_printDigits`, `parseInt_printInt`, the
  measure bound `size_le_print_length`, the arm-overlap witnesses, and the generic theorem
  `parseCJson_printCJson`
- `Fuel.lean` (77) — `parseCJson_fuel_sufficient`, `parseCanonical_printCanonical`,
  `parseCanonical_ne_outOfFuel`
- `Cert.lean` (735) — `encodeFormula`/`decodeFormula`, the schema codec, `printCertificate`,
  `parseCertificateCanonical`, and the five contract theorems
- `CanonicalWire.lean` (35) and `CanonicalWire/README.md` (52) — sibling aggregator and directory
  README

Also new:

- `BimodalTools/CertificateRecords.lean` (156) — the `Raw*`/`Partial*` records relocated
  **verbatim** (diff-confirmed against `git show HEAD:…`) under the unchanged namespace
  `BimodalTools.CertificateImport`, so the schema codec can sit below the envelope in the import
  graph
- `Tests/BimodalToolsTest/CanonicalWireTest.lean` (222) — one negative row per recorded defect
  (D1-D12), the canonical form's strictness rules, the round trips, and the echo rows

Modified:

- `BimodalTools/CertificateImport.lean` (792 → 599) — `parseCertificate` and
  `RawCertificate.toJson` are now thin wrappers over the verified codec; the eleven-function `p*`
  parser block and five serializer helpers are gone; `jsonArray` stays (the *output* line still
  uses it); new `canonicalString` and `CheckResult.toJsonWithEcho`, and `checkLineToJson` routes
  through the latter. `checkLine`, `checkRaw`, `checkCertified` and `refutes_of_countermodel` are
  untouched. The module no longer imports `BimodalTools.JsonParse` at all
- `BimodalTools/JsonParse.lean` (258 → 268) — docstring amended to bridge-only, with the
  bridge-migration follow-up recorded for a human to file (R5)
- `Tests/BimodalToolsTest/CertificateImportTest.lean` (201 → 205) — the two
  `pFormula ∘ Formula.toJson` closure rows retargeted to `decodeFormula ∘ encodeFormula`
- `BimodalTools.lean`, `Tests/BimodalToolsTest.lean` — aggregator imports
- `BimodalTools/README.md` — the `"echo"` key, the **joint canonical contract** table, the
  corrected error-line sample, the formula-shape and atom-identity paragraphs, and the
  "jointly gated" paragraph replaced with what item (2) now is
- `Tests/BimodalToolsTest/README.md` — module-table row

## Decisions

- **Two layers, and the split is load-bearing.** Every lexical question — escapes, numerals,
  fuel, trailing bytes — is answered once generically; `decode_encode` is then structural
  induction over `RawCertificate` with no goal mentioning the parser's fuel, and `parse_print` is
  one composition. That is what made a verified codec finite work.
- **The equation compiler drove the parser's shape.** It splits a function's equations on every
  `match` over a *pattern variable*, including in branches a concrete input never reaches, and
  `rw` then emits unprovable side goals about unrelated branches. `Parse.lean` was restructured
  twice for this: the unescape reader is three mutual functions plus a named `consResult`, and the
  value parser looks ahead with `List.head?`/`tail`/`take`/`drop` rather than nested patterns. Both
  reasons are recorded in the file, because the shape looks arbitrary otherwise.
- **A numeral is accepted exactly when it is what the canonical printer would emit.** That single
  reprint check subsumes leading zeros, `+`, `-0`, fractions and exponents, and cannot drift away
  from the printer it inverts.
- **`\u00XX` is decoded only for `XX < 20`.** This reconciles the settled "reject `\uXXXX`"
  decision with a *total* escape round trip: the printer must escape control characters somehow,
  and `\u00XX` is the only valid JSON spelling, so the reader must accept exactly that form and
  reject every other `\uXXXX` — including `A` and `é`.
- **Formula objects must match their tag's exact canonical shape.** One rule closes three defects
  at once (a missing `"name"`, an extra sub-formula field, a wire-level `"freshIndex"`). Unknown
  keys stay tolerated at the envelope, target and lasso levels, as the contract requires — but only
  after their values are fully parsed.
- **Both required-field messages are preserved byte for byte**, because the decoder still lands in
  the `Partial*` mirrors and goes through `complete`.

## Plan Deviations

Five of these are **statement-level** and are flagged for review — see "Follow-ups".

- **Phase 4/5/6 (altered), three pinned statements corrected because the recorded forms are
  false.** `unescape_escape` is stated as
  `unescapeBody (escapeBody s ++ ['"']) = .ok (s, [])`: `unescapeBody` *consumes* the closing
  quote, so the recorded form runs off the end of its input and reports an unterminated literal.
  `parseCJson_printCJson` and `parseCJson_fuel_sufficient` each carry one added hypothesis,
  `NoDigitHead rest` (the remainder does not begin with a decimal digit): without it the recorded
  form is false at the integer leaf, since `printCJson (.int 1) ++ ['2']` is the byte string `12`,
  which any correct parser reads as twelve. Every structural use discharges the condition for free
  (`,`, `]`, `}`, or end of input), so it costs nothing downstream. Conclusions are otherwise
  unchanged.
- **Phase 6 (altered)**: the negative fuel corollary is stated for canonical bytes
  (`parseCanonical_ne_outOfFuel`), not for arbitrary input. The stronger claim needs a fuel/length
  invariant through every rejection path and the trust argument does not rest on it: the
  out-of-fuel branch returns `.error`, so an exhausted budget can only cause a spurious rejection,
  never a misinterpretation.
- **Phase 7 (altered)**: `parse_base_only` is proved from an explicit guard at the end of
  `decodeCert` rather than from a six-level induction chain over the collection decoders. The guard
  is the contract's atom-identity clause made executable where the contract states it, and it is
  the repository's own idiom — `mkFamily`'s `atomNotBase` fault is likewise vacuous on parsed
  input, as `CertificateImport.lean`'s "Atom shape" docstring already said. Its unreachability on
  decoded input is itself recorded as a theorem, `decodeFormula_base_only`.
- **Phases 4-9 (altered)**: every theorem reports `[propext, Classical.choice, Quot.sound]`, not
  the plan's `[propext, Quot.sound]`. `Classical.choice` arrives with Mathlib's `Nat.digits` API,
  which R6 mandates. These are Lean's three core axioms and are **exactly** the repository's own
  flagship baseline in `scripts/check-module-invariants.sh` check C2. No `axiom` declaration is
  added anywhere: the repo-wide count is 14 before and 14 after.
- **Phase 1 (altered)**: `Canonical` carries only the no-duplicate-key clause. The plan's second
  clause (no raw control character in a string) is unnecessary — `escapeChar` escapes every
  character below `0x20`, so the printer never emits one, and the parser rejects one if it sees
  one.
- **Phase 3 (altered)**: `parseDigits`'s canonicality check is the reprint test described above
  rather than the plan's separate syntactic side conditions.
- **Phase 7 (altered, a sharpening)**: formula objects are matched by exact canonical shape, which
  is stricter than "reject extra *sub-formula* fields". A formula is data in the trust base, and
  rejecting is the fail-closed direction.

## Verification

- Build: Success. `lake build BimodalTools --wfail`, `lake build BimodalToolsTest --wfail` and
  `lake build` (the published `FormalSystem` library, 2741 jobs, untouched) are all green, with
  **zero warnings** in the new modules — `--wfail` makes every style linter fatal, including
  `linter.unusedSimpArgs`, `linter.style.show`, `linter.style.longLine` and
  `linter.style.whitespace`.
- Sorry count: 0 (`lean-sorry-census.sh` over `BimodalTools`, `Tests`, `FormalSystem`).
- Vacuous count: 0 introduced. The one repo-wide grep hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, is pre-existing and outside this task's file
  set (its goal literally unfolds to `True`).
- Axiom count: unchanged, 14 before and 14 after, none in any file this task touched. Every pinned
  theorem reports `[propext, Classical.choice, Quot.sound]`.
- Gates: `bash scripts/check-module-invariants.sh` exit 0 (C3, C8, INV, C9, C20 tiers 1-2, C30-C35
  all PASS; the three `TODO` rows are pre-existing and non-enforced). `bash scripts/readme-lint.sh`
  PASS.
- Tests: Passed. Every `#guard` in `CanonicalWireTest.lean` (D1-D12, the strictness rules, the
  round trips, the echo rows) and every pre-existing `#guard` in `CertificateImportTest.lean`
  compiles, which is what a passing `#guard` means.
- End-to-end: a `countermodel` run and a `rejected` run of `lake exe check_certificate` each print
  an `"echo"` whose value, stripped of surrounding whitespace, is byte-identical to the bytes sent;
  an `error` run emits none. Trailing garbage prints
  `{"status":"error","message":"unexpected trailing bytes after the top-level value"}`. The
  separation family still prints the same verdict tuple as before the migration (`fulfilling`,
  lasso 0, position -2, `p U q`).
- Files verified: Yes.

### The nine pinned theorems

| Theorem | Where |
|---------|-------|
| `unescape_escape` | `CanonicalWire/RoundTrip.lean` |
| `parseDigits_printDigits` | `CanonicalWire/RoundTrip.lean` |
| `parseCJson_printCJson` | `CanonicalWire/RoundTrip.lean` |
| `parseCJson_fuel_sufficient` | `CanonicalWire/Fuel.lean` |
| `decode_encode` | `CanonicalWire/Cert.lean` |
| `parse_print` | `CanonicalWire/Cert.lean` |
| `printCertificate_injective` | `CanonicalWire/Cert.lean` |
| `print_parse_canonical` | `CanonicalWire/Cert.lean` |
| `parse_base_only` | `CanonicalWire/Cert.lean` |

### The twelve defects, each closed

| Defect | Old behaviour | Now |
|--------|---------------|-----|
| D1 | trailing bytes silently ignored | `.error` (strict end of input) |
| D2 | `atom` with no `"name"` → empty-base atom | `.error` (exact formula shape) |
| D3 | `A` → the name `u0041` | `.error` (`\uXXXX` rejected) |
| D4 | duplicate keys, last wins | `.error` at every nesting level |
| D5 | malformed JSON hidden in an unread field | `.error` (values parsed before keys are ignored) |
| D6 | raw control character emitted unescaped | printer emits no character below `0x20` |
| D7 | those invalid bytes round-tripped anyway | canonical pair round-trips *and* emits valid JSON |
| D8 | extra sub-formula field accepted | `.error` (exact formula shape) |
| D9 | fraction errored, for the wrong reason | `.error` as a non-canonical numeral |
| D10 | `\t` → the name `atb` | decodes correctly to a tab |
| D11 | `\r` → the name `arb` | decodes correctly to a carriage return |
| D12 | `é` → the name `pu00e9` | `.error`; UTF-8 `é` passes through unchanged |

## Impacts

- The certificate trust base no longer contains an unverified parser. What a `countermodel` verdict
  now rests on is: Lean's compiler, the four compiled `Decidable` instances, and a decoding step
  that is *proved* to invert its printer rather than trusted to.
- The consuming repository's parse-echo verification task has what it needs: the `"echo"` key, and
  `print_parse_canonical` as the theorem the comparison rests on.
- `BimodalTools/JsonParse.lean` now serves the tableau bridge only.
- Producers are affected in exactly one direction: the format accepts *less* than it used to. A
  certificate that was previously accepted and silently misread is now rejected with a protocol
  error.

## Follow-ups

- **For review: three pinned Challenge statements were corrected rather than proved as recorded.**
  `unescape_escape` names the closing quote; `parseCJson_printCJson` and
  `parseCJson_fuel_sufficient` each carry `NoDigitHead rest`. Each recorded form is false as
  written, with the counterexample given under "Plan Deviations". Per
  `.claude/rules/plan-compliance.md`'s Statement Fidelity section an added hypothesis is a
  reviewable event even when the recorded statement was the wrong one, so it is surfaced here
  rather than annotated and forgotten. Nothing was quietly edited in the plan's
  `## Lean Challenge Statements` block.
- **Hand-off to the producing repository**: pin `ensure_ascii=False` in its exporter
  (`json.dumps(obj, separators=(",", ":"), ensure_ascii=False)`). Not performed here. Until it
  lands, an all-ASCII certificate is unaffected and a non-ASCII atom name is *rejected* rather than
  misdecoded — the safe direction.
- **Hand-off to the consuming repository**: actually perform the echo comparison. The theorem
  exists; nobody is yet checking its hypothesis about the bytes.
- **Recorded follow-up, for a human to file** (R5, also recorded in `JsonParse.lean`'s docstring):
  migrate the tableau bridge's request envelope onto the canonical codec and retire
  `JsonParse.lean`. Out of scope here because the bridge's envelope is not the certificate trust
  base.
- The `"acceptance"`-style non-breaking rule applies to `"echo"` too: an absent `echo` must be read
  as "this binary predates the key".

## References

- `specs/678_canonical_wire_parser_round_trip/plans/01_canonical-wire-parser-round-trip.md`
- `specs/678_canonical_wire_parser_round_trip/reports/01_canonical-wire-parser-round-trip.md`
- `specs/678_canonical_wire_parser_round_trip/spike-json-roundtrip.lean` — the validated skeleton
  Phases 1, 3 and 5 follow
- `specs/678_canonical_wire_parser_round_trip/probe-parser-defects.lean` — the twelve probed
  defects
- `specs/678_canonical_wire_parser_round_trip/handoffs/` — the per-phase handoffs
- `BimodalTools/CanonicalWire/README.md`, `BimodalTools/README.md`
