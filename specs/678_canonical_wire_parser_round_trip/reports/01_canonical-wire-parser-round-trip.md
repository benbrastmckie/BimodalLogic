# Research Report: Task #678

**Task**: 678 - canonical_wire_parser_round_trip
**Started**: 2026-09-27T20:52:00Z
**Completed**: 2026-09-27T21:40:00Z
**Effort**: 4-6 implementation phases (~1,400-1,900 new Lean lines, of which ~800-1,000 is proof)
**Dependencies**: 677 (completed)
**Sources/Inputs**:
- Codebase: `BimodalTools/JsonParse.lean`, `BimodalTools/CertificateImport.lean`,
  `BimodalTools/CheckCertificateMain.lean`, `BimodalTools/DataExport.lean`,
  `BimodalTools/README.md`, `Tests/BimodalToolsTest/CertificateImportTest.lean`,
  `lakefile.toml`, `.github/workflows/ci.yml`, `scripts/check-module-invariants.sh`,
  `scripts/readme-lint.sh`
- Lean toolchain sources (v4.33.0-rc1): `Init/Data/String/Basic.lean`,
  `Init/Internal/Order/*`
- Mathlib search: `lean_leansearch`, `lean_loogle`, `lean_local_search`
- Executable probes written for this report (both committed beside it):
  `specs/678_canonical_wire_parser_round_trip/probe-parser-defects.lean`,
  `specs/678_canonical_wire_parser_round_trip/spike-json-roundtrip.lean`
- Repository HEAD at time of research: `33451fafb`
**Artifacts**:
- `specs/678_canonical_wire_parser_round_trip/reports/01_canonical-wire-parser-round-trip.md`
- `specs/678_canonical_wire_parser_round_trip/probe-parser-defects.lean` (12 recorded probes)
- `specs/678_canonical_wire_parser_round_trip/spike-json-roundtrip.lean` (147-line
  sorry-free round-trip spike, compiles green)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The current parser is not merely unproven, it is demonstrably wrong, and wrong silently.**
  `pString` (`BimodalTools/JsonParse.lean:82`) decodes `\t` to `t`, `\r` to `r`, and
  `A` to the four-character run `u0041`. Python's `json.dumps` emits all three by
  default (`ensure_ascii=True` is the default), so a producing-side atom name containing a
  tab or any non-ASCII character makes the verified side decide conditions on **a different
  atom** than the one exported — precisely the defect class this task exists to close. All
  three are recorded probes, not inferences (D3, D10-D12).
- **Five further silent-acceptance defects are confirmed by probe**: trailing bytes after the
  top-level object are ignored (D1); an `atom` object with no `"name"` becomes the empty-base
  atom rather than an error (D2); duplicate keys silently last-win (D4); malformed JSON inside
  an unknown field is silently skipped, because `pSkipValue` is a scanner rather than a parser
  (D5); a raw control character in an atom name is emitted **unescaped**, producing bytes that
  Python's strict `json.loads` rejects outright (D6).
- **No round-trip theorem is provable against the parser as written.** `pString`,
  `pSkipValue`, `pFormula`, `pNat`, `pArrayOf` and `pObjectFields` are all `partial def` with
  `while true do` loops. A `partial def` has no equation lemmas, so nothing can be proved about
  it — the existing guarantee is two `#guard` rows on two example certificates
  (`Tests/BimodalToolsTest/CertificateImportTest.lean:155,157`), not a theorem.
- **Recommended approach: a new two-layer codec, not a repair of the existing one.** Layer 1
  is a generic canonical JSON value (mutual inductive), a canonical printer to `List Char`, and
  a fuel-indexed **total** `def` parser. Layer 2 is a schema `encode`/`decode` pair over that
  value. The round trip then factors into one generic lexical theorem (proved once, reusable)
  and one schema theorem that is pure structural induction with no parser state in it.
- **The proof technique is validated, not assumed.** I wrote and compiled a 147-line spike
  (strings + nested arrays: mutual inductive, canonical printer, fuel parser, measure, and the
  prefix round-trip theorem `pJ f (prJ j ++ rest) = .ok (j, rest)`). It compiles green under
  this toolchain with **zero `sorry`** and `#print axioms roundtrip` reporting only
  `[propext, Quot.sound]`. The spike also surfaced the one non-obvious detail (the naive size
  measure does not satisfy fuel sufficiency; see Risks).
- **Sorry-free is achievable.** No step of the recommended path needs a `sorry`, an axiom, or a
  deferral. The one genuinely optional theorem (fuel sufficiency) is a separate, self-contained
  phase and is recommended for inclusion rather than deferral.

## Context & Scope

Researched: how to give the witness-family certificate wire format a canonical printer, a total
parser, and a `parse ∘ print = id` theorem, without changing the export contract; and what the
current codec actually does on adversarial and on ordinary-but-unusual input.

Constraints taken as binding:

1. **The export contract is frozen.** `back`, `mid`, `fwd`, `bx`, `lassos`, `target`;
   `target.time` required and undefaulted; `target.premises`/`target.conclusions` defaulting to
   `[]`; `bx` sparse with unlisted formulas reading `false`; `lassos` index `0` the main lasso;
   atom identity base-only, a fresh-indexed atom rejected outright. All six are stated in
   `BimodalTools/README.md:76-131` and mirrored in `CertificateImport`'s module docstring.
2. **`Formula.toJson`'s bytes are pinned elsewhere and must not change.**
   `Tests/BimodalToolsTest/TableauBridgeTest.lean:139-158` and
   `Tests/BimodalTest/Automation/NormalizationTest.lean:517-526` assert its exact spelling
   (`{"tag": "atom", "name": "p"}` — with spaces). 225 `toJson` call sites exist across
   `BimodalTools/` and `Tests/`. The canonical printer must therefore be a **new** function,
   not a redefinition of `Formula.toJson`.
3. **Zero-debt.** `scripts/check-module-invariants.sh` gate C3 asserts zero structural `sorry`
   by content; CI runs `lake build BimodalTools --wfail` and `lake build BimodalToolsTest
   --wfail`, so every linter warning is fatal.

Out of scope for this report: the consuming repository's half (the parse-echo comparison). What
is in scope is what this side must emit for that comparison to be possible, which is discussed
under Decisions.

## Literature Proof Structure

Not applicable. No paper, textbook or external formalization is referenced by this task; the
"source" is the repository's own export contract, which is quoted above and treated as frozen.

## Findings

### Codebase Patterns

**Where the trust gap is, exactly.** `BimodalTools/README.md:190` already names the residual
trust base as "Lean's compiler, and this executable's decoding of the wire object into the
family the sender meant", and `README.md:205-211` already names *this* task as item (2) of a
jointly-gated pair: "a Lean-side echo of the parsed certificate compared against the bytes
actually sent, so that the residual decoding step above is itself pinned rather than trusted."
The task is therefore already scoped in the repository's own prose; nothing about the framing
needs re-deriving.

**The codec as it stands.** A serializer and a parser both already exist:

| Direction | Definitions | Location |
|-----------|-------------|----------|
| print | `jsonArray`, `labelToJson`, `segmentToJson`, `RawLasso.toJson`, `bxPairToJson`, `RawTarget.toJson`, `RawCertificate.toJson` | `CertificateImport.lean:383-425` |
| parse | `pKeyword`, `pBool`, `pInt`, `pArrayOf`, `pObjectFields`, `pLabel`, `pSegment`, `pBxPair`, `pRawLasso`, `pRawTarget`, `pRawCertificate`, `parseCertificate` | `CertificateImport.lean:240-375` |
| parse (shared primitives) | `PState`, `pString`, `pSkipValue`, `pFormula`, `pNat` | `JsonParse.lean:52-258` |

So the task is not greenfield on the *functions*; it is greenfield on the *guarantee*. The
existing guarantee is two `#guard` rows on the two example families
(`CertificateImportTest.lean:155,157`) plus a `.all` row over each family's closure
(`:142-152`). There is no round-trip theorem anywhere in the repository — a repo-wide grep for
`round`/`roundtrip`/`encode_decode`-shaped theorem names returns only unrelated results
(formula-substitution round trips in `Boneyard/`, a topology lemma).

**Why no theorem is currently possible.** Every recursive parser is `partial def`
(`JsonParse.lean:82,111,163,231`; `CertificateImport.lean:307,325`) and is written with
`while true do` + `mut` accumulators. `partial def` yields no equation lemmas and no
unfolding principle, so the functions are opaque to proof. This is the single structural reason
the task cannot be done by adding theorems to the existing modules: **the definitions have to
be rewritten as genuine (non-`partial`) recursive `def`s first.**

**Observed behaviour of the current codec** (all from
`specs/678_canonical_wire_parser_round_trip/probe-parser-defects.lean`, run with
`lake env lean`; outputs verbatim):

| # | Input | Observed | Should be |
|---|-------|----------|-----------|
| D1 | `{"target":{"time":3},"lassos":[]} GARBAGE {"x":1}` | `Except.ok 3` | protocol error (trailing bytes) |
| D2 | `{"tag":"atom"}` | `atom { base := "", freshIndex := none }` | protocol error (missing `name`) |
| D3 | `{"tag":"atom","name":"A"}` | `atom { base := "u0041" }` | `atom { base := "A" }`, or a protocol error |
| D4 | `{"target":{"time":1},"target":{"time":9},…}` | `Except.ok 9` | protocol error (duplicate key) |
| D5 | `{"note":tru,"target":{"time":3},…}` | `Except.ok 3` | protocol error (malformed value) |
| D6 | `Formula.toJson (atomS "a\tb")` | `{"tag": "atom", "name": "a<TAB>b"}` | `"a\tb"` — the emitted bytes are invalid JSON |
| D7 | parse of D6's output | `Except.ok true` | (Lean-internal round trip holds; the bytes are still invalid) |
| D8 | `{"tag":"box","child":⊥,"left":⊥}` | `box ⊥` | protocol error, or documented tolerance |
| D9 | `{"target":{"time":3.7},…}` | `Except.error "expected , or }} at pos 19"` | error — the one already-strict case |
| D10 | `{"tag":"atom","name":"a\tb"}` (escaped tab) | `atom { base := "atb" }` | `atom { base := "a<TAB>b" }` |
| D11 | `{"tag":"atom","name":"a\rb"}` | `atom { base := "arb" }` | `atom { base := "a<CR>b" }` |
| D12 | `{"tag":"atom","name":"pé"}` | `atom { base := "pu00e9" }` | `atom { base := "pé" }` |

D3, D10, D11 and D12 are the severe ones. `pString`'s escape branch
(`JsonParse.lean:101-108`) handles `"`, `\\` and `n` and then falls through to `| _ => result
:= c :: result`, i.e. **every unrecognised escape decodes to the escaped character itself**.
Cross-checked against the producing side's default behaviour:

```
python3 -c "import json; print(json.dumps({'name':'pé'}))"   →  {"name": "pé"}
python3 -c "import json; print(json.dumps({'name':'a\tb'}))" →  {"name": "a\tb"}
```

Both are what a Python producer emits **by default**, and Lean decodes both to a different
string. Conversely D6's raw tab is rejected by the consuming side:

```
json.loads('{"tag": "atom", "name": "a<TAB>b"}')
  → ValueError: Invalid control character at: line 1 column 27
```

So the codec is currently broken in both directions on the same character class, and the
brokenness is only invisible because production atom names are `p`, `q`, `r`.

**Build and gate context the implementation must satisfy.**
`BimodalTools` is outside `defaultTargets` (`lakefile.toml:22`) but CI compiles it and
`BimodalToolsTest` explicitly with `--wfail` (`.github/workflows/ci.yml:93-107`), so the new
theorems are genuinely gated. Additional constraints: `weak.linter.style.longFile = 1500`
(package level, so it applies to `BimodalTools/` too); `scripts/readme-lint.sh` check 1 is
**gated** and requires a `README.md` in every directory containing `.lean` files;
`check-module-invariants.sh` C3 asserts zero structural `sorry`, C8 asserts the sibling-
aggregator convention (`X.lean` beside `X/`); new modules must be added to
`BimodalTools.lean` and to `BimodalTools/README.md`'s module table (which carries line counts).
`--wfail` in particular makes `linter.unusedSimpArgs` fatal — my spike tripped it once on a
`simp [pStr, hc, ih hcs]` where `hc` was unused.

**`CheckCertificateMain.lean:56-57`** passes `stdin.readToEnd` straight to `checkLineToJson`,
so the input carries the producer's trailing newline. Any strict-EOF check must skip trailing
whitespace, and any byte-exact echo comparison on the consuming side must compare modulo
surrounding whitespace.

### External Resources

**Lean 4.33.0-rc1 `String` is byte-backed, and the needed bridge lemmas exist.**
`Init/Prelude.lean:3537` defines `structure String where ofByteArray :: …` (a `ByteArray`, not a
`List Char`), so `String`-level append reasoning is not free. But the three lemmas that make a
`List Char`-based design work are all present in core:

- `String.toList_append : (s ++ t).toList = s.toList ++ t.toList` (`Init/Data/String/Basic.lean:385`)
- `String.toList_ofList : (String.ofList l).toList = l` (`:334`)
- `String.toList_injective` / `String.toList_inj` (`:370`, `:377`)

Design consequence: define the canonical printer as `List Char`-valued and expose
`String.ofList ∘ print` as the public `String`-valued printer; define the parser on `List Char`
and expose `parse ∘ String.toList`. All string-concatenation reasoning then happens in
`List Char`, where `simp` is strong, and the `String` wrapper is discharged by
`String.toList_ofList`.

**No core lemma relates `toString` to `String.toNat?`.** `lean_local_search` and
`lean_loogle "String.toNat? (toString _) = _"` both return nothing;
`lean_leansearch` for "parsing the decimal representation recovers the number" returns
`Nat.ofDigits_digits : Nat.ofDigits b (b.digits n) = n`
(`Mathlib.Data.Nat.Digits.Defs`) and `Nat.ofDigits_singleton`. Design consequence: do **not**
try to prove anything about `toString`. Print integers through `Nat.digits 10` (special-casing
`0`, since `Nat.digits 10 0 = []`) and parse through `Nat.ofDigits 10`, so the numeric round
trip is `Nat.ofDigits_digits` plus a `Char`↔digit inverse lemma. Mathlib is already in the
import closure of `CertificateImport` (via `FormalSystem.Metalogic.Decidability.WitnessFamily`),
so this costs no new dependency.

**`partial_fixpoint` is available but is the wrong tool here.** The toolchain ships
`Init/Internal/Order/{Basic,Lemmas,MonadTail,Tactic,While}.lean`, with `MonadTail (Except ε)`
(`MonadTail.lean:72`) and CCPO/MonoBind instances for `ExceptT`. So a `partial_fixpoint`-based
parser could obtain unfolding equations and thus support a positive round-trip proof. It is
nonetheless the wrong choice: `partial_fixpoint` gives **partial** correctness only, so
"a parser total on its input" — the task's own words — would remain unestablished. A
fuel-indexed or measure-carrying `def` gives totality by construction. Recording the finding
because it is the natural first idea and should be consciously rejected rather than missed.

**Mathlib has no verified-parser combinator library to build on.** `lean_leansearch` surfaces
only `Mathlib.Tactic.Sat.Parser.parseNat` (a `Std.Internal.Parsec.String.Parser ℕ`, unproved)
and `Lean.Json`/`Lean.Json.parse` in core, which is written with `Std.Internal.Parsec` and
carries no round-trip lemma. Reusing `Lean.Json.parse` would move the unproven code from this
repository into core without shrinking the trust base, and `Lean.Json`'s `RBNode`-backed objects
and `JsonNumber` mantissa/exponent numbers would make canonicality harder, not easier.
Conclusion: the codec must be this repository's own.

### Recommendations

**R1 — Build a new two-layer codec in new modules; do not repair `JsonParse.lean` in place.**

Layer 1, the generic canonical JSON value:

```
mutual inductive CJson | str | int | bool | arr (xs : CJsonList) | obj (kvs : CJsonObj)
       inductive CJsonList | nil | cons
       inductive CJsonObj  | nil | cons (k : List Char) (v : CJson) (kvs : CJsonObj)
```

with `printCJson : CJson → List Char` (compact: no whitespace, fields in encode order),
`parseCJson : Nat → List Char → Except String (CJson × List Char)` as a **total `def`**, and
`parse_print : printCJson j ++ rest` parses to `(j, rest)`.

Layer 2, the schema codec: `encodeCert : RawCertificate → CJson` and
`decodeCert : CJson → Except String RawCertificate`, with
`decode_encode : decodeCert (encodeCert c) = .ok c` for base-atom `c`.

The top-level theorem is the composition. Use **mutual** inductives (not a nested
`List CJson` field): mutual inductives give clean mutual recursors, and my spike confirms
`induction` over them behaves. Nested inductives through `List` make the induction hypothesis
awkward and are the main avoidable source of proof pain here.

Why two layers rather than one monolithic proof: the lexical work (escapes, digits, whitespace,
arm overlap) is proved **once**, generically, and the schema-level theorem becomes pure
structural induction over `RawCertificate` with key lookups on distinct string literals — no
parser state in it at all. It is also the layer split that makes "unknown fields are skipped,
so a producer may attach metadata" (`README.md:124`) *sound* rather than scanned: the generic
parser parses metadata properly and the decoder ignores unrecognised keys, which fixes D5 for
free.

**R2 — Totality by fuel, with fuel sufficiency proved.** Take `fuel := cs.length + 1` at the
top level; each recursive descent consumes at least one character. This makes
`parseCertificate : String → Except String RawCertificate` a total `def` with no `partial`
anywhere, so malformed input can only ever produce `.error` — never a partial or misinterpreted
structure. Add the sufficiency theorem (`cs.length ≤ f → parseCJson f cs ≠ .error outOfFuel`)
as its own phase so that "out of fuel" is provably unreachable rather than merely unlikely; see
Risks R-2 for the alternative that removes the obligation instead of discharging it.

**R3 — Fix the escape layer, and pin the joint canonical form.** Define the codec's own
`escape`/`unescape` on `List Char` (do **not** reuse `DataExport.escapeJsonString`, whose bytes
are pinned by other tests), and prove `unescape (escape s) = s`. Required behaviour:

- escape `"`, `\`, and **every** character below `0x20` (as `\b \f \n \r \t` where JSON names
  them, `\u00XX` otherwise) — this closes D6;
- decode `\" \\ \/ \b \f \n \r \t` correctly, and **reject every other escape** with a protocol
  error — this closes D10-D11 and turns D3/D12 from silent corruption into a clean rejection;
- reject raw characters below `0x20` inside a string literal;
- pass non-ASCII through as UTF-8 in both directions.

Consequence for the joint contract, which must be written into `BimodalTools/README.md`: the
canonical form is compact (`separators=(',',':')` on the Python side), fixed key order, and
**`ensure_ascii=False`**. With `\uXXXX` rejected, a producer that leaves Python's default
`ensure_ascii=True` in place gets a loud protocol error instead of a silently different atom —
which is the correct trade. Implementing `\uXXXX` decoding instead is the alternative; it costs
surrogate-pair handling and a harder round-trip lemma, and buys tolerance the producing side does
not need. Recommend rejection; if the producing side cannot set `ensure_ascii=False`, revisit.

**R4 — Tighten strictness to the list D1-D8 implies.** Require whitespace-then-EOF after the
top-level value (D1); reject duplicate keys at every nesting level (D4); require `"name"` on
`atom` and reject an unrecognised or missing `"tag"` (D2); reject extra sub-formula fields on a
tag that does not take them (D8, or document the tolerance explicitly — recommend rejecting,
since a canonical codec has nothing to gain from it); accept integer syntax only, rejecting
leading zeros, `+`, `-0`, fractions and exponents, so that parse is injective on canonical bytes
(D9 already errors, for the wrong reason). Keep unknown **envelope/target/lasso** keys skipped,
per the contract, but skip them by *parsing* them.

**R5 — Migrate `CertificateImport` onto the new codec; leave `JsonParse.lean` for the bridge.**
`parseCertificate` and `RawCertificate.toJson` become thin wrappers over the new layer, so
`checkLine`, `checkRaw`, `checkCertified` and `refutes_of_countermodel` are untouched.
`JsonParse.lean` stays in place for `TableauBridge.lean`, whose request envelope is not the
certificate trust base. This contradicts `JsonParse.lean`'s "exactly one home" docstring, so
either migrate the bridge in the same task (its envelope is small) or record the bridge
migration as an explicit follow-up task and amend that docstring. **Recommend amending the
docstring and filing the follow-up**: pulling the bridge in widens this task's blast radius for
no gain in the certificate trust argument.

**R6 — State the theorem in both directions, and get the second one free.** The two statements
worth having are:

1. `parse_print`: `parseCertificate (printCertificate c) = .ok c`, for `c` with base-only atoms.
2. `print_parse_canonical`: if `s` is canonical — defined as *being in the image of
   `printCertificate`* — then `parseCertificate s = .ok c → printCertificate c = s`.

(2) follows from (1) plus injectivity of `printCertificate` with no new induction: if
`s = printCertificate c'` then `parseCertificate s = .ok c'` by (1), so `c = c'` and
`printCertificate c = s`. (2) is the theorem the paired consuming-side comparison actually rests
on — it says the echo is byte-identical to the bytes sent, whenever the sender was canonical —
so it should be stated even though it is a two-line corollary.

Also worth stating, and cheap: `parseCertificate s = .ok c → c.formulas.all (! hasFreshAtom ·)`
(the decoder only ever builds `Atom.mkBase`), which makes (1)'s base-atom hypothesis vacuous on
the real pipeline and re-proves the "atom identity is base-only" clause of the contract as a
theorem rather than a comment.

**R7 — Emit the echo, so the pairing can close.** Add an `"echo"` key to the output line
carrying `printCertificate` of the parsed certificate, on `countermodel` and `rejected` (both
have a parsed certificate; `error` does not). This is an output-side addition of exactly the
shape `"acceptance"` already took (`README.md:146-149`), so it is non-breaking, and the README's
"an absent X must be read as …" convention should be extended to it. Document that the
comparison is modulo surrounding whitespace, because `main` forwards the producer's trailing
newline.

**R8 — Suggested phase decomposition** (each sized to one agent run, each independently green):

| Phase | Content | Est. lines |
|-------|---------|-----------|
| 1 | `CanonicalWire/Json.lean`: mutual inductives, measures, `escape`/`unescape`, digit codec, canonical printer | 400-500 |
| 2 | `CanonicalWire/Parse.lean`: the total fuel parser, strictness per R4 | 300-400 |
| 3 | `CanonicalWire/RoundTrip.lean`: `unescape_escape`, digit round trip, the generic prefix round-trip theorem | 350-450 |
| 4 | `CanonicalWire/Cert.lean`: `encodeCert`/`decodeCert`, `decode_encode`, the two contract theorems (R6) | 300-400 |
| 5 | Fuel sufficiency theorem (R2) | 100-150 |
| 6 | `CertificateImport` migration, `"echo"` (R7), README/docstring updates, tests: the D1-D12 rows as negative `#guard`s plus the two existing `#guard` round-trip rows retargeted | 150-250 |

Directory note: a new `BimodalTools/CanonicalWire/` needs its own `README.md` (gated by
`readme-lint.sh` check 1) and a sibling `BimodalTools/CanonicalWire.lean` aggregator (C8
convention). Flat `BimodalTools/CanonicalWire*.lean` filenames avoid both; either is fine, the
subdirectory reads better at this size.

## Decisions

- **New modules, not in-place repair of `JsonParse.lean`.** The existing parsers are
  `partial def`, which admits no proof; and `JsonParse.lean` is shared with `TableauBridge`,
  whose contract is not being changed.
- **A new canonical formula printer, not a change to `Formula.toJson`.** Its exact bytes are
  asserted by `TableauBridgeTest.lean:139-158` and `NormalizationTest.lean:517-526`, and it has
  225 call sites. The canonical printer is compact; `Formula.toJson` keeps its spaces.
- **`List Char` as the parser's state, not `Array Char` + index.** The round-trip lemma shape
  `p (print x ++ rest) = .ok (x, rest)` is only tractable over list remainders; core's
  `String.toList_append` / `toList_ofList` bridge back to `String` for the public API. No
  performance regression: the current parser already materialises `s.toList.toArray`.
- **Mutual inductives for the JSON value, not a nested `List CJson`.** Validated by spike.
- **Fuel for totality, with sufficiency proved** (R2), rather than `partial_fixpoint` (partial
  correctness only) or a measure-carrying subtype (heavier definitions).
- **Integers via `Nat.digits`/`Nat.ofDigits`, never via `toString`.** No core lemma relates
  `toString` to `String.toNat?`; `Nat.ofDigits_digits` is exactly the lemma needed.
- **Reject unsupported escapes rather than implement `\uXXXX`**, and pin `ensure_ascii=False`
  in the joint canonical form (R3). This is a contract *sharpening*, not a contract change: no
  field name, requiredness or default moves.
- **The echo lands on `countermodel` and `rejected`, not on `error`** (R7).
- **The bridge migration is a follow-up, not part of this task** (R5).

## Risks & Mitigations

- **R-1 — Escape round trip is the one genuinely fiddly lemma.** `unescape (escape s) = s`
  needs a case split per escaped character class, and the `\u00XX` branch needs a hex-digit
  inverse. *Mitigation*: keep `escape`/`unescape` on `List Char`, prove by induction on the
  list with one `have` per class; the spike's `pStr_append` (induction + one `simp` with the
  head-inequality hypothesis) is the pattern, and it closed in three lines.
- **R-2 — Fuel sufficiency is a real obligation, and the naive measure does not satisfy it.**
  The spike found this concretely: with `szJS .nil = 1`, the inequality `szJ j ≤ (printJ j).length`
  fails at the empty-array leaf (it demands `2 ≤ 1`). *Mitigation*: tune the measure (set the
  empty cases to `0`) and prove `sz j ≤ (print j).length` as an explicit lemma in Phase 3 rather
  than assuming it. If sufficiency proves expensive, the documented alternative is to drop fuel
  for a measure-carrying return type (`{ r : List Char // r.length ≤ cs.length }`) threaded
  through every combinator, with well-founded recursion on `cs.length` — heavier definitions,
  but the obligation disappears instead of being discharged. Note that even an unproved fuel
  bound can only cause a **spurious rejection**, never a misinterpretation, so this risk cannot
  reintroduce the defect class the task is closing.
- **R-3 — Error-message churn.** `BimodalTools/README.md:141` shows a sample message
  (`"expected '\"' got 'n' at pos 2"`) that a list-based parser cannot reproduce verbatim, and
  `CertificateImportTest.lean` asserts `checkLineToJson noTimeLine != checkLineToJson
  noTargetLine`. *Mitigation*: keep the two required-field messages verbatim (they are produced
  by `PartialTarget.complete`/`PartialCertificate.complete`, which move to the decoder
  unchanged); update the README sample; keep the `!=` row, which stays true.
- **R-4 — `--wfail` makes style linters fatal.** The spike tripped `linter.unusedSimpArgs` on a
  single unused `simp` argument. *Mitigation*: build each phase with
  `lake build BimodalTools --wfail` (detached and guarded per
  `context/project/lean4/operations/long-builds.md`) rather than plain `lake build`.
- **R-5 — File-length linter.** `weak.linter.style.longFile = 1500` applies package-wide; the
  codec is ~1,500 lines in total. *Mitigation*: the four-module split in R8 keeps every file
  well under the limit; do not consolidate.
- **R-6 — Echo output size.** A large certificate's echo doubles the output line.
  *Mitigation*: it is one line on stdout and the consuming side already holds the bytes; if it
  becomes a problem, gate it behind a `--echo` flag on `check_certificate` rather than dropping
  the field.
- **R-7 — Byte comparison versus trailing newline.** `main` forwards `readToEnd` verbatim
  (`CheckCertificateMain.lean:56`). *Mitigation*: the strict-EOF check skips trailing
  whitespace, and the README states the echo comparison is modulo surrounding whitespace.

## Tactic Survey Results

Surveyed against the spike's actual goals (`spike-json-roundtrip.lean`), not against
hypotheticals. The file compiles green: no errors, no warnings, no `sorry`
(`grep -c sorry` = 0), and `#print axioms roundtrip` reports `[propext, Quot.sound]`.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `pStr (s ++ '"' :: rest) = .ok (s, rest)` | `induction` + `simp` | success | `simp [pStr, ih hcs]`; the head-inequality `hc` must be derived but **not** passed to `simp` (`--wfail` + `unusedSimpArgs`) |
| printed value never starts with `]` (arm-overlap side condition) | `cases` + explicit witness | success | `⟨'"', …, by simp, by simp [prJS, prJ]⟩`; `simp` alone does not find the existential |
| round trip, fuel `0` base case | `cases` + `simp … at h` | success | `simp [szJ] at h` closes it from the measure contradiction |
| round trip, `str` case | `simp` | success | `simp [prJ, pJ, pStr_append s rest hok]` |
| round trip, empty-array case | `simp` | success | `simp [prJ, prJS, pJ]` |
| round trip, non-empty-array case | `rw` on the equation lemma, side condition by hand | success | `rw [pJ]` leaves `∀ cs, c :: r = ']' :: cs → False`, closed by `intro cs' h; cases h; exact hc rfl` |
| fuel arithmetic (`szJS (.cons y ys) ≤ f`) | `simp only` + `omega` | success | plain `simp [szJS]` is **not** enough — the inner `szJS` must be unfolded on both sides first (`simp only [szJS] at hsz ⊢; omega`) |
| final `match` on a constructor scrutinee | `rfl` / `show` | success | `rw` cannot see through the match; either `rfl` or a `show` that names the reduced form |
| the whole theorem | `decide` / `aesop` | not attempted | the statement is universally quantified over an inductive type and over `List Char`; neither is applicable |

The one recurring trap: `do`-notation in the parser desugars to `<$>`/`bind`, which `simp` does
not reduce without help. Writing the parsers with explicit `match … with | .ok … | .error …`
instead of `do` made every one of the goals above close. **Recommend the implementation avoid
`do`-notation inside any function the round-trip proof unfolds.** This is a concrete,
load-bearing finding, and it is why my first two spike attempts failed where the third
succeeded.

## Context Extension Recommendations

- **Topic**: Verified codec / round-trip proof patterns for Lean 4 in this repository.
  **Gap**: `.claude/context/project/lean4/` has no pattern file for "prove a printer/parser
  round trip": the `List Char` remainder convention, the `p (print x ++ rest) = .ok (x, rest)`
  lemma shape, mutual-inductive-over-nested-inductive, fuel-versus-measure totality, the
  `do`-notation-blocks-`simp` trap, and the `String.toList_append`/`toList_ofList` bridge.
  **Recommendation**: add `context/project/lean4/patterns/verified-codec-round-trip.md`
  distilled from this report's Tactic Survey and from
  `specs/678_canonical_wire_parser_round_trip/spike-json-roundtrip.lean`, which is a complete
  147-line worked example.
- **Topic**: The `--wfail` + `linter.unusedSimpArgs` interaction.
  **Gap**: nothing in the Lean context notes that CI's `--wfail` turns Mathlib style-linter
  warnings into build failures, so a locally-green file can fail CI on an unused `simp`
  argument. **Recommendation**: one paragraph in
  `context/project/lean4/operations/long-builds.md` or the lean4 rules file.

## Appendix

**Search queries used**

- `lean_local_search "toNat? toString round trip"` → no results
- `lean_loogle "String.toNat? (toString _) = _"` → no results
- `lean_leansearch "parsing the decimal string representation of a natural number recovers the
  number"` → `Nat.ofDigits_digits`, `Nat.ofDigits_singleton`, `Mathlib.Tactic.Sat.Parser.parseNat`,
  `Real.ofDigits_digits`, `Encodable.decode_nat`
- Repo greps: `"lassos"|"bx"|"fwd"` (located the two wire modules);
  `theorem.*round|roundtrip|encode_decode|parse_.*toJson` (established no existing round-trip
  theorem); `\"tag\": \"` (located the pinned-byte tests); `skolem` (confirmed "fresh or Skolem
  atom" means `Atom.freshIndex.isSome` — `Atom` has exactly `base` and `freshIndex`,
  `FormalSystem/Syntax/Atom.lean:76-81`)
- Toolchain greps: `structure String` / `String.toList` in `Init/`; `Except` in
  `Init/Internal/Order/`

**Executable evidence committed beside this report**

- `probe-parser-defects.lean` — 12 probes, run with
  `lake env lean specs/678_canonical_wire_parser_round_trip/probe-parser-defects.lean`; the
  outputs quoted in the D1-D12 table are that command's verbatim output.
- `spike-json-roundtrip.lean` — 147 lines, sorry-free, green. Contains the mutual inductive,
  canonical printer, fuel parser, measure, `okJ` well-formedness predicate, `pStr_append`,
  the head-character lemma, and the combined round-trip theorem proved by induction on fuel.
  This is the skeleton Phases 1-3 should follow.

**Documentation consulted**

- `BimodalTools/README.md:76-215` — the wire schema, the `target.time` rationale, the atom-
  identity clause, the acceptance/trust-base section, and the already-written statement that
  the Lean-side echo is item (2) of the jointly-gated pair
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean` (via `CertificateImport`'s
  docstring) — field names as an export contract
- `.github/workflows/ci.yml:80-107`, `lakefile.toml:19-45`,
  `scripts/check-module-invariants.sh:1-30`, `scripts/readme-lint.sh:1-25` — the gates
