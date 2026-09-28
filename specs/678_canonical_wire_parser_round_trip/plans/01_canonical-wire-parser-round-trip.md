# Implementation Plan: Canonical Wire Parser Round Trip

- **Task**: 678 - canonical_wire_parser_round_trip
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours
- **Dependencies**: 677 (completed)
- **Research Inputs**: specs/678_canonical_wire_parser_round_trip/reports/01_canonical-wire-parser-round-trip.md
- **Artifacts**: plans/01_canonical-wire-parser-round-trip.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the certificate wire codec with a two-layer verified one, so that deserialization leaves
the trust base. Layer 1 is a generic canonical JSON value with a canonical printer and a **total**
(non-`partial`) fuel-indexed parser; layer 2 is a schema `encode`/`decode` pair over that value.
The round trip then factors into one generic lexical theorem, proved once, and one schema theorem
that is pure structural induction over `RawCertificate`. The existing parser is not merely
unproven but demonstrably and silently wrong — twelve probe-recorded defects, four of which
decode a producing-side atom name into a *different* atom — so the work is a replacement, not a
repair. Done means: `lake build BimodalTools --wfail` and `lake build BimodalToolsTest --wfail`
are green, `scripts/check-module-invariants.sh` and `scripts/readme-lint.sh` pass, no `sorry`
and no new axiom beyond `[propext, Quot.sound]` appears in any new declaration, all nine pinned
theorems below are proved, the D1-D12 defects are each closed by a negative `#guard`, and the
export contract's field names, requiredness and defaults are byte-for-byte unchanged.

### Research Integration

The report's recommendations R1-R8 are adopted without exception, and its measured findings are
treated as settled rather than re-derived:

1. **New modules, not a repair of `JsonParse.lean`.** Every existing recursive parser is
   `partial def` with `while true do`, which yields no equation lemmas — so no theorem about the
   current code is possible in principle. `JsonParse.lean` also serves `TableauBridge`, whose
   envelope is not the certificate trust base and is out of scope (R5).
2. **A new canonical printer, not a change to `Formula.toJson`.** Its exact bytes are asserted by
   `Tests/BimodalToolsTest/TableauBridgeTest.lean:139-158` and
   `Tests/BimodalTest/Automation/NormalizationTest.lean:517-526`, across 225 call sites. The
   canonical printer is compact; `Formula.toJson` keeps its spaces and is untouched.
3. **`List Char` state, not `Array Char` + index.** The round-trip lemma shape
   `parse (print x ++ rest) = .ok (x, rest)` is only tractable over list remainders;
   `String.toList_append`, `String.toList_ofList` and `String.toList_injective`
   (`Init/Data/String/Basic.lean:385,334,370`) bridge back to `String` for the public API.
4. **Mutual inductives for the JSON value, not a nested `List CJson`** — validated by the
   147-line sorry-free spike at
   `specs/678_canonical_wire_parser_round_trip/spike-json-roundtrip.lean`, which is the skeleton
   Phases 1, 3 and 5 follow.
5. **Fuel for totality, with sufficiency proved** (R2), rather than `partial_fixpoint` (which
   gives partial correctness only, leaving "total on its input" unestablished) or a
   measure-carrying subtype (heavier definitions).
6. **Integers via `Nat.digits`/`Nat.ofDigits`, never `toString`.** No core or Mathlib lemma
   relates `toString` to `String.toNat?`; `Nat.ofDigits_digits` is exactly the lemma needed.
7. **No `do`-notation inside any function the round-trip proof unfolds.** `do` desugars to
   `<$>`/`bind`, which `simp` will not reduce; the spike's first two attempts failed on exactly
   this and the third, written with explicit `match ... with | .ok ... | .error ...`, closed every
   goal. This is a load-bearing constraint on every definition in Phases 1, 3 and 7.
8. **Reject unsupported escapes; do not implement `\uXXXX`** (the settled decision recorded in
   `.decisions.json`, auto-resolved on the research agent's recommendation). The joint canonical
   contract pins `ensure_ascii=False` on the producing side, which is a one-line change there.
   This is a contract *sharpening*: no field name, requiredness or default moves.

### Prior Plan Reference

No prior plan. This is round 1 for this task.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap phases are therefore included.
`BimodalTools/README.md:205-211` already names this work as item (2) of a jointly-gated pair, so
the alignment that matters is recorded in the repository's own prose rather than in a roadmap.

## Goals & Non-Goals

**Goals**:
- `unescape_escape`
- `parseDigits_printDigits`
- `parseCJson_printCJson`
- `parseCJson_fuel_sufficient`
- `decode_encode`
- `parse_print`
- `print_parse_canonical`
- `printCertificate_injective`
- `parse_base_only`

Beyond those nine pinned theorems the phases below also deliver the definitions they are about
(the canonical JSON value and its measure, the escape and digit codecs, the canonical printer,
the total fuel parser, and the schema encode/decode pair), the migration of the certificate
envelope onto them, the additive echo output field, and the contract and module documentation.
Those are structural or documentary, carry no pinned statement, and are therefore not listed as
Goals identifiers.

**Non-Goals**:
- Migrating `TableauBridge`'s request envelope off `JsonParse.lean`. Its contract is not the
  certificate trust base; per R5 the fix is to amend `JsonParse.lean`'s "exactly one home"
  docstring and record the bridge migration as a follow-up task, not to widen this task's blast
  radius.
- Any change to `Formula.toJson`'s bytes, or to `DataExport.escapeJsonString`. Both are pinned by
  other tests with many call sites; the canonical codec gets its own printer and its own escape
  function.
- Implementing `\uXXXX` decoding, including surrogate pairs. Settled against; rejection with a
  protocol error is the decided behavior.
- Any change to the export contract's field names, requiredness or defaults. `back`, `mid`,
  `fwd`, `bx`, `lassos`, `target`; `target.time` required and undefaulted; `target.premises` and
  `target.conclusions` defaulting to empty; `bx` sparse with unlisted formulas reading false;
  `lassos` index 0 the main lasso; atom identity base-only. All frozen.
- Any change to `checkRaw`, `checkCertified`, `refutes_of_countermodel`, the four `Decidable`
  instances, or the acceptance vocabulary that task 677 landed. Only the decode and print edges
  move.
- Any edit inside the consuming repository. Its parse-echo verification half is a separate task;
  what this side owes it is the echo field (Phase 9) and the written joint contract.
- Editing the producing side's `ensure_ascii=False` one-liner. It is recorded as a hand-off in
  the contract prose, never performed here.
- Kernel-checking per certificate, `native_decide`, or any other change to the trust argument's
  shape. Out of scope and unrelated.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `unescape (escape s) = s` is the one genuinely fiddly lemma: a case split per escaped character class plus a hex-digit inverse for the `\u00XX` branch | M | H | Keep both functions on `List Char`; prove by induction on the list with one `have` per class. The spike's `pStr_append` (induction + one `simp` carrying the head-inequality hypothesis in context but *not* in the `simp` set) closed in three lines and is the pattern. Phase 4 is sized for this lemma alone. |
| Fuel sufficiency is a real obligation and the naive measure does not satisfy it — the spike measured the failure at the empty-array leaf, where `szJS .nil = 1` demands `2 <= 1` | M | H | Set the empty cases of the measure to `0` in Phase 1, and prove the bound `size j <= (printCJson j).length` as an explicit lemma in Phase 4 rather than assuming it. Documented alternative if it proves expensive: drop fuel for a measure-carrying return type threaded through every combinator with well-founded recursion on `cs.length` — heavier definitions, obligation gone instead of discharged. Note the containment: an unproved fuel bound can only cause a spurious rejection, never a misinterpretation, so this risk cannot reintroduce the defect class the task closes. |
| Moving the `Raw*` records into a new module breaks a `deriving` instance or an unqualified reference | M | M | The new module declares into namespace `BimodalTools.CertificateImport` verbatim, so every reference — including the fully-qualified external ones in `CheckCertificateMain.lean:26,27,57` — resolves unchanged. Only four files mention the namespace at all (grep-confirmed). Phase 2 is a pure move with no signature change and its own build gate; if it fails, the fallback is to keep the records in place and define the schema codec inside `CertificateImport.lean` instead (Phase 7 then lands there, ~200 lines, still under the 1500-line limit). |
| Error-message churn: `BimodalTools/README.md:141` shows a sample message a list-based parser cannot reproduce verbatim | L | H | The two required-field messages are produced by `PartialTarget.complete` / `PartialCertificate.complete`, which move unchanged in Phase 2 and stay the decoder's messages, so `CertificateImportTest.lean:169,172,176` keep passing. Update the README's positional sample in Phase 9. |
| `--wfail` makes every style linter fatal, including `linter.unusedSimpArgs` (which the spike tripped once) | M | H | Build each phase with `lake build BimodalTools --wfail` and, from Phase 2 on, `lake build BimodalToolsTest --wfail`, detached and guarded per `context/patterns/bounded-build-waiter.md` and `context/project/lean4/operations/long-builds.md` — never plain `lake build`. Every new declaration carries a doc comment. |
| File-length linter: `weak.linter.style.longFile = 1500` is package-wide and the codec is ~1,500 lines in total | M | M | Keep the five-module split below; do not consolidate. Re-check each file's length at the end of its phase. |
| Declaration-span drift from added lines breaks named `file.lean:NNN` citations (C20/C20_DECL) | M | M | Run `bash scripts/check-module-invariants.sh --no-build` in every phase that adds lines; on a C20_DECL hit repair with `python3 scripts/reanchor-lean-citations.py --by-name --files <target>` and read the diff. Never add a baseline key. New module prose cites declaration **names**, never `file.lean:NNN`. |
| A new subdirectory trips the gated conventions: `readme-lint.sh` check 1 (a `README.md` in every directory containing `.lean` files) and C8 (sibling `X.lean` beside `X/`) | L | H | Phase 1 creates `BimodalTools/CanonicalWire/README.md` and the sibling aggregator `BimodalTools/CanonicalWire.lean` in the same commit as the first module, and adds the row to `BimodalTools/README.md`'s module table with its line count. |
| Echo doubles the output line on a large certificate | L | L | It is one line on stdout and the consuming side already holds the bytes. If it becomes a problem, gate it behind a `--echo` flag on `check_certificate` rather than dropping the field. |
| Byte comparison versus the producer's trailing newline: `CheckCertificateMain.lean:56` forwards `stdin.readToEnd` verbatim | M | H | The strict-EOF check skips trailing whitespace, and Phase 9's contract prose states that the echo comparison is modulo surrounding whitespace. |
| Sibling-task collision on this shared working tree | M | L | Tasks 677, 679, 680 and 681 are completed. Dormant `partial` tasks 282, 296 and 298 each declare `BimodalTools/` and `Tests/BimodalToolsTest/` in `file_scope` but are not dispatched. Re-read every target immediately before editing; stage only this task's own hunks with an explicit file list; never a directory or glob `git add`; never `git-snapshot.sh` in its reverting default mode. Treat a build failure outside this plan's file set as possibly a sibling's in-flight edit. See `context/contracts/territory.md`. |
| A canonical printer whose bytes differ from the current `RawCertificate.toJson` breaks the existing round-trip `#guard`s | M | M | `CertificateImportTest.lean:96,109,122,133,155,157` feed `posRaw.toJson` / `sepRaw.toJson` back through `checkLine` / `parseCertificate`, so they remain true under any printer the new parser accepts. `#guard (checkRaw posRaw).toJson = posAcceptedLine` pins `CheckResult.toJson`, the *output* line, which is why Phase 9 adds the echo through a new `toJsonWithEcho` rather than by editing `CheckResult.toJson`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6, 7 | 5 |
| 6 | 8 | 6, 7 |
| 7 | 9 | 8 |

Phases within the same wave can execute in parallel. Phase 7 additionally requires Phase 2,
which completed in Wave 1.

### Phase 1: Canonical JSON value, measure and printer [COMPLETED]

**Goal**: `BimodalTools/CanonicalWire/Json.lean` exists and compiles: the mutual-inductive
canonical JSON value, its fuel measure, the escape and digit printers, and the canonical printer
to `List Char`. The new directory is registered against every gated convention.

**Tasks**:
- [ ] Create `BimodalTools/CanonicalWire/Json.lean` with a module docstring stating the layer-1
      contract: compact output (no whitespace), fields in encode order, `List Char`-valued.
- [ ] Define the mutual inductives `CJson` / `CJsonList` / `CJsonObj` per R1. Mutual inductives,
      not a nested `List CJson` field — validated by the spike.
- [ ] Define `escapeBody : List Char -> List Char`: escape `"` and `\`, and every character
      below `0x20` (as `\b \f \n \r \t` where JSON names them, `\u00XX` otherwise). Pass
      non-ASCII through as UTF-8. This closes D6.
- [ ] Define `printDigits : Nat -> List Char` through `Nat.digits 10`, special-casing `0`
      (`Nat.digits 10 0 = []`), and the signed integer printer over it.
- [ ] Define `printCJson : CJson -> List Char` and its mutual companions, with explicit `match`
      and no `do`-notation anywhere.
- [ ] Define the mutual measure `size` with **empty cases set to `0`**, so the Phase 4 bound
      `size j <= (printCJson j).length` is satisfiable at the empty-array leaf.
- [ ] Define the `Canonical : CJson -> Prop` well-formedness predicate the round-trip theorem is
      hypothesised on (no duplicate keys at any level; no raw control character in a string).
- [ ] Create `BimodalTools/CanonicalWire.lean` (sibling aggregator, C8) importing this module,
      and `BimodalTools/CanonicalWire/README.md` (`readme-lint.sh` check 1).
- [ ] Add `import BimodalTools.CanonicalWire` to `BimodalTools.lean`.
- [ ] Add the new rows, with line counts, to `BimodalTools/README.md`'s module table.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: the research estimates 400-500 lines for this module. Confirm at
implementation time with `wc -l BimodalTools/CanonicalWire/Json.lean`; if it exceeds ~600, split
the escape/digit codecs into `CanonicalWire/Lex.lean` rather than carrying a file that approaches
the 1500-line package limit once its proofs arrive.

**Files to modify**:
- `BimodalTools/CanonicalWire/Json.lean` - new: layer-1 value, measure, escape and digit
  printers, canonical printer
- `BimodalTools/CanonicalWire.lean` - new: sibling aggregator
- `BimodalTools/CanonicalWire/README.md` - new: directory README
- `BimodalTools.lean` - add the aggregator import
- `BimodalTools/README.md` - module-table rows with line counts

**Verification**:
- `lake build BimodalTools --wfail` green (detached and guarded per
  `context/patterns/bounded-build-waiter.md`).
- `grep -c sorry BimodalTools/CanonicalWire/Json.lean` is `0`; no `partial` and no `do` in the
  file.
- `bash scripts/check-module-invariants.sh --no-build` passes, including C8.
- `bash scripts/readme-lint.sh` passes.
- A `#eval` row printing a small hand-built `CJson` shows compact bytes with no whitespace.

---

### Phase 2: Extract the certificate records into their own module [COMPLETED]

**Goal**: the `Raw*` and `Partial*` records, their `complete` functions, `hasFreshAtom` and
`RawCertificate.formulas` live in `BimodalTools/CertificateRecords.lean` under the unchanged
namespace `BimodalTools.CertificateImport`, so that Phase 7's schema codec can sit *below*
`CertificateImport.lean` in the import graph instead of above it.

**Tasks**:
- [ ] Create `BimodalTools/CertificateRecords.lean` with `namespace BimodalTools.CertificateImport`
      and a module docstring explaining why the records are split out (the schema codec must be
      importable by `CertificateImport.lean`).
- [ ] Move `RawLasso`, `RawTarget`, `RawCertificate`, `PartialTarget`, `PartialCertificate` and
      their `complete` functions, `hasFreshAtom` and `RawCertificate.formulas` across
      **verbatim**, including every doc comment and `deriving` clause. No rename, no signature
      change, no namespace change.
- [ ] Add `import BimodalTools.CertificateRecords` to `CertificateImport.lean` and delete the
      moved block from it.
- [ ] Add the module to `BimodalTools.lean` and to `BimodalTools/README.md`'s module table; fix
      `CertificateImport.lean`'s own line count in that table.
- [ ] Preserve the two required-field error messages exactly as `complete` produces them
      (`CertificateImportTest.lean:169,172,176` depend on them).

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: the block to move is asserted to be ~130 lines
(`CertificateImport.lean:158-240` plus `hasFreshAtom` and `RawCertificate.formulas` near `:428`).
Confirm by reading the file immediately before editing and diffing the moved region's line count
against the reduction in `CertificateImport.lean`; the two must agree up to the import line.

**Files to modify**:
- `BimodalTools/CertificateRecords.lean` - new: the moved records and their helpers
- `BimodalTools/CertificateImport.lean` - delete the moved block, add the import
- `BimodalTools.lean` - add the import
- `BimodalTools/README.md` - module-table rows and the corrected line count

**Verification**:
- `lake build BimodalTools --wfail` and `lake build BimodalToolsTest --wfail` both green: this
  phase must be behavior-neutral, so every existing `#guard` in
  `Tests/BimodalToolsTest/CertificateImportTest.lean` passes untouched.
- `git diff` shows no change to any moved declaration's text beyond relocation.
- `bash scripts/check-module-invariants.sh --no-build` passes.

---

### Phase 3: The total fuel parser [COMPLETED]

**Goal**: `BimodalTools/CanonicalWire/Parse.lean` exists and compiles: a fuel-indexed, **total**
(`def`, never `partial`) parser for the layer-1 value, strict in every way R4 requires.

**Tasks**:
- [ ] Define `unescapeBody : List Char -> Except String (List Char * List Char)`: decode
      `\" \\ \/ \b \f \n \r \t`, **reject every other escape** with a protocol error (closing
      D3, D10, D11, D12 by clean rejection), and reject a raw character below `0x20` inside a
      string literal.
- [ ] Define `parseDigits : List Char -> Except String (Nat * List Char)` through
      `Nat.ofDigits 10`, and the signed integer parser over it. Accept integer syntax only:
      reject leading zeros, `+`, `-0`, fractions and exponents, so parse is injective on
      canonical bytes (D9 already errors, for the wrong reason).
- [ ] Define the mutual `parseCJson : Nat -> List Char -> Except String (CJson * List Char)` and
      its companions, taking one fuel unit per recursive descent, with explicit
      `match ... with | .ok ... | .error ...` and **no `do`-notation** anywhere.
- [ ] Reject duplicate keys at every nesting level (D4).
- [ ] Define the public entry point that skips trailing whitespace and then **requires EOF**,
      rejecting trailing bytes (D1), and that seeds fuel as `cs.length + 1`.
- [ ] Register the module in `CanonicalWire.lean` and in `BimodalTools/README.md`'s table.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: the research estimates 300-400 lines. Confirm with `wc -l`; the binding
constraint is that no function in this file may use `do`, so if the line count comes in far below
estimate, check that no combinator was quietly written monadically.

**Files to modify**:
- `BimodalTools/CanonicalWire/Parse.lean` - new: unescape, digit parser, total fuel parser,
  strict entry point
- `BimodalTools/CanonicalWire.lean` - add the import
- `BimodalTools/README.md` - module-table row

**Verification**:
- `lake build BimodalTools --wfail` green.
- `grep -nE '\bpartial\b|\bdo\b' BimodalTools/CanonicalWire/Parse.lean` returns nothing
  (inspect any hit by hand: the point is that no parser is `partial` and none is monadic).
- `#eval` rows on the D1, D2, D4, D5, D9, D10, D11, D12 inputs each return `.error`, and on a
  well-formed canonical object return `.ok`. These become `#guard`s in Phase 9.
- `bash scripts/check-module-invariants.sh --no-build` passes.

---

### Phase 4: Lexical round-trip lemmas and the measure bound [COMPLETED]

**Goal**: `BimodalTools/CanonicalWire/RoundTrip.lean` exists and proves the three lemmas the
generic theorem rests on: the escape round trip, the digit round trip, and the measure bound.

**Tasks**:
- [ ] Prove `unescape_escape : unescapeBody (escapeBody s) = .ok (s, [])` by induction on the
      list, one `have` per escaped character class, with the hex-digit inverse for the `\u00XX`
      branch as its own lemma.
- [ ] Prove the prefix form used by the generic theorem: `unescapeBody (escapeBody s ++ '"' :: rest)
      = .ok (s, rest)`, following the spike's `pStr_append`.
- [ ] Prove `parseDigits_printDigits : parseDigits (printDigits n ++ rest) = .ok (n, rest)` under
      the hypothesis that `rest` does not begin with a digit, via `Nat.ofDigits_digits`.
- [ ] Prove the measure bound `size j <= (printCJson j).length` by mutual induction, which is
      what Phase 6 needs and what the spike measured failing under the naive measure.
- [ ] Prove the arm-overlap side conditions (a printed value never starts with `]` or `}`), with
      explicit witnesses rather than leaving them to `simp`.
- [ ] Register the module in `CanonicalWire.lean` and in `BimodalTools/README.md`'s table.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: interface

**Scope Hypothesis**: the research estimates 350-450 lines for Phases 4 and 5 together. Confirm
by `wc -l` after Phase 5; if the escape lemma alone exceeds ~250 lines, that is the signal to
re-read R-1's mitigation rather than to keep pushing.

**Files to modify**:
- `BimodalTools/CanonicalWire/RoundTrip.lean` - new: lexical lemmas and the measure bound
- `BimodalTools/CanonicalWire.lean` - add the import
- `BimodalTools/README.md` - module-table row

**Verification**:
- `lake build BimodalTools --wfail` green, with no `unusedSimpArgs` warning: derive a
  head-inequality hypothesis into context but do **not** pass it to `simp`.
- `grep -c sorry BimodalTools/CanonicalWire/RoundTrip.lean` is `0`.
- `#print axioms unescape_escape` and `#print axioms parseDigits_printDigits` report at most
  `[propext, Quot.sound]`.

---

### Phase 5: The generic prefix round-trip theorem [COMPLETED]

**Goal**: `parseCJson_printCJson` is proved: parsing a printed canonical value, followed by any
remainder, returns that value and that remainder.

**Tasks**:
- [ ] State `parseCJson_printCJson (j : CJson) (rest : List Char) (hok : Canonical j) (f : Nat)
      (hf : size j <= f) : parseCJson f (printCJson j ++ rest) = .ok (j, rest)`.
- [ ] Prove by mutual induction on the value with induction on fuel, following the spike's
      `roundtrip`: close the fuel-`0` base case from the measure contradiction
      (`simp [size] at hf`); the string case by `simp` with the Phase 4 prefix lemma; the
      empty-array case by `simp` on the printer equations; the non-empty case by `rw` on the
      parser's equation lemma with the arm-overlap side condition discharged by hand.
- [ ] For the fuel arithmetic, unfold the inner measure on both sides first
      (`simp only [size] at hf |- ; omega`) — plain `simp` is measured insufficient.
- [ ] Add the `String`-level corollary via `String.toList_ofList` and `String.toList_append`.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: the theorem is asserted to need no new induction principle beyond the
mutual recursors the spike exercised. Confirm at implementation time by checking that the
`induction` invocation elaborates without a custom eliminator; if it does not, the fallback is the
spike's exact shape transplanted case by case.

**Files to modify**:
- `BimodalTools/CanonicalWire/RoundTrip.lean` - the generic theorem and its `String` corollary

**Verification**:
- `lake build BimodalTools --wfail` green.
- `#print axioms parseCJson_printCJson` reports at most `[propext, Quot.sound]`.
- `grep -c sorry BimodalTools/CanonicalWire/RoundTrip.lean` is `0`.
- A `#guard` round trip on a hand-built nested `CJson` with an escaped-tab string key evaluates
  to `true`.

---

### Phase 6: Fuel sufficiency [COMPLETED]

**Goal**: `BimodalTools/CanonicalWire/Fuel.lean` proves that the fuel the public entry point
seeds is always enough, so "out of fuel" is provably unreachable on canonical input rather than
merely unlikely.

**Tasks**:
- [ ] State and prove `parseCJson_fuel_sufficient (j : CJson) (rest : List Char)
      (hok : Canonical j) : parseCJson (printCJson j ++ rest).length (printCJson j ++ rest)
      = .ok (j, rest)`, by composing Phase 5's theorem with Phase 4's measure bound and
      `List.length_append`.
- [ ] State the negative corollary used in the module prose: the entry point never returns the
      out-of-fuel error on input it is given by the public wrapper.
- [ ] Register the module in `CanonicalWire.lean` and in `BimodalTools/README.md`'s table.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: interface

**Scope Hypothesis**: the research estimates 100-150 lines and asserts the proof is a composition
requiring no new induction. Confirm by `wc -l`; if the file passes ~250 lines the measure is
fighting back, and R-2's documented alternative (a measure-carrying return type, obligation
removed rather than discharged) should be re-costed before continuing.

**Files to modify**:
- `BimodalTools/CanonicalWire/Fuel.lean` - new: sufficiency theorem and corollary
- `BimodalTools/CanonicalWire.lean` - add the import
- `BimodalTools/README.md` - module-table row

**Verification**:
- `lake build BimodalTools --wfail` green.
- `#print axioms parseCJson_fuel_sufficient` reports at most `[propext, Quot.sound]`.
- `grep -c sorry BimodalTools/CanonicalWire/Fuel.lean` is `0`.

---

### Phase 7: Schema codec and the five contract theorems [COMPLETED]

**Goal**: `BimodalTools/CanonicalWire/Cert.lean` carries `encodeCert` / `decodeCert`, the
canonical certificate printer and parser, and the five theorems that state the export contract as
mathematics rather than as prose.

**Tasks**:
- [ ] Define `encodeCert : RawCertificate -> CJson` and `printCertificate : RawCertificate ->
      String`, emitting the frozen field order `target` (with `premises`, `conclusions`, `time`),
      `bx`, `lassos`, each lasso as `back`, `mid`, `fwd`. `target.time` is always emitted.
- [ ] Define `decodeCert : CJson -> Except String RawCertificate` and
      `parseCertificateCanonical : String -> Except String RawCertificate`. Land in the
      `Partial*` mirrors and go through `complete`, so the two required-field messages are the
      existing ones verbatim. Require `"name"` on `atom` and reject an unknown or missing `"tag"`
      (D2); reject extra sub-formula fields on a tag that does not take them (D8); reject an atom
      carrying a fresh or Skolem index outright. Ignore unrecognised envelope, target and lasso
      keys per the contract — but ignore them *after* the generic parser has parsed them, which
      is what closes D5.
- [ ] Prove `decode_encode : decodeCert (encodeCert c) = .ok c` for base-atom `c`, by structural
      induction over `RawCertificate` with key lookups on distinct string literals.
- [ ] Prove `parse_print : parseCertificateCanonical (printCertificate c) = .ok c` for base-atom
      `c`, by composing `decode_encode` with Phase 5's generic theorem.
- [ ] Prove `printCertificate_injective` from `parse_print`.
- [ ] Prove `print_parse_canonical` as the two-line corollary: if the bytes are in the image of
      `printCertificate`, the parsed certificate reprints to those same bytes. This is the
      statement the paired consuming-side echo comparison actually rests on.
- [ ] Prove `parse_base_only`: anything `parseCertificateCanonical` returns carries base-only
      atoms, which makes the base-atom hypothesis of `parse_print` vacuous on the real pipeline
      and re-proves that clause of the contract as a theorem.
- [ ] Register the module in `CanonicalWire.lean` and in `BimodalTools/README.md`'s table.

**Timing**: 2.5 hours

**Depends on**: 5, 2

**Verification Tier**: interface

**Scope Hypothesis**: the research estimates 300-400 lines and asserts the schema proof contains
no parser state. Confirm at implementation time that no goal in this file mentions `parseCJson`'s
fuel argument; if one does, the layer split has leaked and the generic theorem is being re-proved
here rather than applied.

**Files to modify**:
- `BimodalTools/CanonicalWire/Cert.lean` - new: schema codec and the five theorems
- `BimodalTools/CanonicalWire.lean` - add the import
- `BimodalTools/README.md` - module-table row

**Verification**:
- `lake build BimodalTools --wfail` green.
- `#print axioms parse_print`, `print_parse_canonical`, `decode_encode`,
  `printCertificate_injective`, `parse_base_only` each report at most `[propext, Quot.sound]`.
- `grep -c sorry BimodalTools/CanonicalWire/Cert.lean` is `0`.
- `#guard parseCertificateCanonical (printCertificate posRaw) = .ok posRaw` and the same for
  `sepRaw`, using the two example families from `CertificateImportTest.lean`.

---

### Phase 8: Migrate the certificate envelope onto the verified codec [COMPLETED]

**Goal**: `parseCertificate` and `RawCertificate.toJson` are thin wrappers over the new codec, so
the trust base loses the old `partial def` parser without `checkLine`, `checkRaw`,
`checkCertified` or `refutes_of_countermodel` changing at all.

**Tasks**:
- [ ] Add `import BimodalTools.CanonicalWire.Cert` to `CertificateImport.lean`.
- [ ] Redefine `parseCertificate` as `parseCertificateCanonical` and `RawCertificate.toJson` as
      `printCertificate`, deleting the `pKeyword`/`pBool`/`pInt`/`pArrayOf`/`pObjectFields`/
      `pLabel`/`pSegment`/`pBxPair`/`pRawLasso`/`pRawTarget`/`pRawCertificate` block and the
      old serializer helpers that become unreachable.
- [ ] Retarget `Tests/BimodalToolsTest/CertificateImportTest.lean`: keep every row that goes
      through `checkLine` / `checkRaw` / `parseCertificate` unchanged, and replace the
      `pFormula ∘ Formula.toJson` closure rows (`:142-152`) with their canonical-codec
      equivalents. Keep `:176`'s inequality row, which stays true.
- [ ] Amend `JsonParse.lean`'s "exactly one home" module docstring to say it now serves the
      tableau bridge only, and record the bridge migration as an explicit follow-up for a human
      to file (per R5 — do not perform it here).
- [ ] Update `BimodalTools/README.md`'s module-table line counts for every file whose length
      changed.

**Timing**: 2 hours

**Depends on**: 6, 7

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: the declared batch is exactly `BimodalTools/CertificateImport.lean`,
`Tests/BimodalToolsTest/CertificateImportTest.lean`, `BimodalTools/JsonParse.lean` and
`BimodalTools/README.md`. Intermediate per-file states are expected red and MUST NOT be
committed; the batch is one green objective. Confirm the set before the first edit by grepping
for every caller of `parseCertificate` and `RawCertificate.toJson` — if the grep names a file
outside this list, the batch was undercounted and must be re-declared before editing, never
widened afterwards.

**Files to modify**:
- `BimodalTools/CertificateImport.lean` - wrappers in, old parser and serializer out
- `Tests/BimodalToolsTest/CertificateImportTest.lean` - retargeted rows
- `BimodalTools/JsonParse.lean` - docstring amendment
- `BimodalTools/README.md` - module-table line counts

**Verification**:
- The complete gate set: `lake build BimodalTools --wfail`, `lake build BimodalToolsTest --wfail`,
  `lake build` (the published library, which must be untouched),
  `bash scripts/check-module-invariants.sh`, `bash scripts/readme-lint.sh`.
- `grep -n 'partial def' BimodalTools/CertificateImport.lean` returns nothing.
- `echo '<posRaw canonical bytes>' | lake exe check_certificate` prints the same verdict line as
  before the migration.
- Every pre-existing `#guard` in `CertificateImportTest.lean` that was not deliberately retargeted
  still passes.

---

### Phase 9: The echo field, the defect guards, and the joint contract [COMPLETED]

**Goal**: the output line carries an echo of what was parsed; D1-D12 are each closed by a
negative test row; and the joint canonical contract — including `ensure_ascii=False` and the
whitespace tolerance — is written down where the consuming repository can read it.

**Tasks**:
- [ ] Add `CheckResult.toJsonWithEcho`, taking the echo string, and route `checkLineToJson`
      through it on `countermodel` and `rejected`. Leave `CheckResult.toJson` byte-identical, so
      `CertificateImportTest.lean:109`'s pinned `posAcceptedLine` keeps passing; `error` carries
      no echo because it has no parsed certificate.
- [ ] Create `Tests/BimodalToolsTest/CanonicalWireTest.lean` with the D1-D12 rows as negative
      `#guard`s (each asserting `.error`, and the four silent-misdecode cases asserting rejection
      rather than a different atom), plus round-trip `#guard`s over the two example families and
      an escaped-control-character atom name.
- [ ] Add `import BimodalToolsTest.CanonicalWireTest` to `Tests/BimodalToolsTest.lean` and a row
      to `Tests/BimodalToolsTest/README.md`.
- [ ] Extend `BimodalTools/README.md`'s certificate protocol section: the `"echo"` key and the
      absent-field reading, the canonical form (compact separators, fixed key order,
      `ensure_ascii=False`), the rejection of `\uXXXX` and of every unrecognised escape, the
      strictness list from R4, and the statement that the echo comparison is modulo surrounding
      whitespace because `main` forwards the producer's trailing newline.
- [ ] Update the README's positional error-message sample (`:141`), and replace the
      "jointly gated, and has not landed yet" paragraph (`:205-211`) with what item (2) now is,
      naming the theorem `print_parse_canonical` the guarantee rests on.
- [ ] Record the producing-side `ensure_ascii=False` one-liner as a hand-off in the contract
      prose. Do not edit the consuming repository.

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: twelve defect rows (D1-D12) are asserted to be individually expressible as
`#guard`s. Confirm row by row against the probe file
`specs/678_canonical_wire_parser_round_trip/probe-parser-defects.lean`; if a row turns out not to
be expressible as a decidable `#guard` (D6/D7 concern emitted bytes rather than a parse verdict),
record it as a `#eval` with the expected output quoted in a comment and say so in the summary
rather than dropping it silently.

**Files to modify**:
- `BimodalTools/CertificateImport.lean` - `toJsonWithEcho` and the `checkLineToJson` routing
- `Tests/BimodalToolsTest/CanonicalWireTest.lean` - new: the D1-D12 guards and round-trip rows
- `Tests/BimodalToolsTest.lean` - add the import
- `Tests/BimodalToolsTest/README.md` - test-table row
- `BimodalTools/README.md` - the joint canonical contract, the echo key, the corrected
  disclaimer

**Verification**:
- The complete gate set, as in Phase 8.
- `echo '{"target":{"time":3},"lassos":[]} GARBAGE' | lake exe check_certificate` prints
  `{"status":"error",...}`.
- A `countermodel` and a `rejected` run each print an `"echo"` key whose value, reparsed, equals
  the certificate that was sent.
- `bash scripts/readme-lint.sh` passes with the new README rows.

## Lean Challenge Statements

```lean
import BimodalTools.CanonicalWire.Json
import BimodalTools.CanonicalWire.Parse
import BimodalTools.CanonicalWire.Cert
import BimodalTools.CertificateRecords

namespace BimodalTools.CanonicalWire

open BimodalTools.CertificateImport

/-- The escape codec is a round trip on any character list. -/
theorem unescape_escape (s : List Char) :
    unescapeBody (escapeBody s) = .ok (s, []) := sorry

/-- The decimal codec is a round trip, given a remainder that cannot extend the numeral. -/
theorem parseDigits_printDigits (n : Nat) (rest : List Char)
    (h : ∀ c ∈ rest.head?, ¬ c.isDigit) :
    parseDigits (printDigits n ++ rest) = .ok (n, rest) := sorry

/-- The generic layer-1 theorem: parsing a printed canonical value returns it, and returns the
remainder untouched. -/
theorem parseCJson_printCJson (j : CJson) (rest : List Char) (hok : Canonical j)
    (f : Nat) (hf : size j ≤ f) :
    parseCJson f (printCJson j ++ rest) = .ok (j, rest) := sorry

/-- The fuel the public entry point seeds is always enough: out-of-fuel is unreachable. -/
theorem parseCJson_fuel_sufficient (j : CJson) (rest : List Char) (hok : Canonical j) :
    parseCJson (printCJson j ++ rest).length (printCJson j ++ rest) = .ok (j, rest) := sorry

/-- The schema layer: decoding an encoded certificate returns it. -/
theorem decode_encode (c : RawCertificate)
    (h : c.formulas.all (fun φ => ! hasFreshAtom φ)) :
    decodeCert (encodeCert c) = .ok c := sorry

/-- The task's headline theorem: parsing a printed certificate returns that same certificate. -/
theorem parse_print (c : RawCertificate)
    (h : c.formulas.all (fun φ => ! hasFreshAtom φ)) :
    parseCertificateCanonical (printCertificate c) = .ok c := sorry

/-- The canonical printer is injective on base-atom certificates. -/
theorem printCertificate_injective (c c' : RawCertificate)
    (hc : c.formulas.all (fun φ => ! hasFreshAtom φ))
    (hc' : c'.formulas.all (fun φ => ! hasFreshAtom φ))
    (h : printCertificate c = printCertificate c') : c = c' := sorry

/-- The guarantee the paired consuming-side echo comparison rests on: on canonical bytes, the
echo is byte-identical to what was sent. -/
theorem print_parse_canonical (c c' : RawCertificate)
    (hc' : c'.formulas.all (fun φ => ! hasFreshAtom φ))
    (h : parseCertificateCanonical (printCertificate c') = .ok c) :
    printCertificate c = printCertificate c' := sorry

/-- Atom identity is base-only on anything the parser returns, which makes the base-atom
hypothesis above vacuous on the real pipeline. -/
theorem parse_base_only (s : String) (c : RawCertificate)
    (h : parseCertificateCanonical s = .ok c) :
    c.formulas.all (fun φ => ! hasFreshAtom φ) := sorry

end BimodalTools.CanonicalWire
```

Three notes on this block, all deliberate:

- The statements are pinned here at plan time, but the module they assemble into can only
  *compile* once Phases 1, 3 and 7 have landed the definitions it references — this task creates
  those definitions from nothing, so there is no pre-existing tree to snapshot against. Take the
  snapshot after Phase 7, or treat this block as the statement contract and check it by hand
  against the landed theorems.
- `Canonical`, `size`, `escapeBody`, `unescapeBody`, `printDigits`, `parseDigits`, `encodeCert`,
  `decodeCert`, `printCertificate` and `parseCertificateCanonical` are named rather than unfolded,
  because their bodies are fixed by Phases 1, 3 and 7 and restating them here would duplicate
  definitions this plan already fixes in one place.
- `parseDigits_printDigits`'s hypothesis is stated over `rest.head?` so it is vacuous on the empty
  remainder; the exact spelling of this side condition is the one degree of freedom the
  implementer may adjust, provided the conclusion is unchanged.

## Testing & Validation

- [ ] `lake build` green: the published `FormalSystem` library is untouched by this task.
- [ ] `lake build BimodalTools --wfail` green — no warning anywhere in the new modules, including
      `linter.unusedSimpArgs` and `linter.style.longFile`.
- [ ] `lake build BimodalToolsTest --wfail` green.
- [ ] `grep -rn 'sorry' BimodalTools/CanonicalWire/ BimodalTools/CertificateRecords.lean` finds
      nothing structural; `bash scripts/check-module-invariants.sh` C3 passes.
- [ ] `#print axioms` on each of the nine pinned theorems reports at most `[propext, Quot.sound]`.
- [ ] `grep -n 'partial' BimodalTools/CanonicalWire/` returns nothing: the certificate parser is
      total by construction.
- [ ] Each of D1-D12 has a corresponding row in `Tests/BimodalToolsTest/CanonicalWireTest.lean`
      asserting rejection (or, for D6/D7, the corrected emitted bytes).
- [ ] Round-trip `#guard`s on both example families, plus one atom name containing a tab and one
      containing a non-ASCII character.
- [ ] `bash scripts/readme-lint.sh` and `bash scripts/check-module-invariants.sh` both pass.
- [ ] End-to-end: a `countermodel` run and a `rejected` run of `lake exe check_certificate` each
      emit an `"echo"` whose value reparses to the certificate that was sent; an `error` run emits
      none.

## Artifacts & Outputs

- `BimodalTools/CanonicalWire.lean` - sibling aggregator
- `BimodalTools/CanonicalWire/README.md` - directory README
- `BimodalTools/CanonicalWire/Json.lean` - canonical value, measure, escape and digit printers,
  canonical printer
- `BimodalTools/CanonicalWire/Parse.lean` - unescape, digit parser, total fuel parser, strict
  entry point
- `BimodalTools/CanonicalWire/RoundTrip.lean` - lexical lemmas, measure bound, the generic
  prefix round-trip theorem
- `BimodalTools/CanonicalWire/Fuel.lean` - fuel sufficiency
- `BimodalTools/CanonicalWire/Cert.lean` - schema codec and the five contract theorems
- `BimodalTools/CertificateRecords.lean` - the relocated certificate records
- `BimodalTools/CertificateImport.lean` - migrated to thin wrappers, plus the echo
- `BimodalTools/JsonParse.lean` - amended docstring (bridge-only)
- `BimodalTools.lean`, `Tests/BimodalToolsTest.lean` - aggregator imports
- `Tests/BimodalToolsTest/CanonicalWireTest.lean` - the D1-D12 guards and round-trip rows
- `Tests/BimodalToolsTest/CertificateImportTest.lean` - retargeted rows
- `BimodalTools/README.md`, `Tests/BimodalToolsTest/README.md` - module tables and the joint
  canonical contract
- `specs/678_canonical_wire_parser_round_trip/summaries/01_canonical-wire-parser-round-trip-summary.md`
- A recorded follow-up: migrate `TableauBridge`'s request envelope off `JsonParse.lean` (R5)

## Rollback/Contingency

Every phase is additive until Phase 8, and Phases 1-7 are independently green, so the natural
contingency is to stop after any completed phase: the new modules compile and prove their
theorems while `CertificateImport` still runs the old codec, which is a strictly better position
than today (the verified codec exists and is proved) even if the migration never lands.

- **Phases 1-7**: no rollback needed. Each phase's commit can be reverted in isolation with
  `git revert <sha>`; nothing outside `BimodalTools/CanonicalWire/`,
  `BimodalTools/CertificateRecords.lean`, the two aggregators and the README table is touched.
  Phase 2 is the one exception in principle (it moves existing declarations), and its
  verification is explicitly that behavior is unchanged, so a revert restores the prior tree
  exactly.
- **Phase 8**: the declared atomic batch is one commit, so `git revert` of that single commit
  restores the old codec wholesale. Because the batch's intermediate states are expected red,
  an interruption mid-batch leaves an uncommitted tree; if that tree must be discarded rather
  than finished, that is a genuine rollback — take the snapshot first per
  `context/contracts/recovery.md`'s rollback rung (including its out-of-scope override flag for
  the deliberate whole-tree case), then run the destructive command. Never emit a bare
  `git-snapshot.sh 678` as a routine start-of-phase precaution; a defensive checkpoint before
  risky work uses `--no-revert`.
- **Phase 9**: the echo key is purely additive and the absent-field reading is documented, so
  reverting it leaves both repositories consistent. The README contract prose can be reverted
  independently of the code.
- **If R-2 bites** (fuel sufficiency proves expensive): Phase 6 is the only phase that may be
  closed with `[COMPLETED WITH EXCLUSIONS]` plus a `#### Reasoned Exclusions` record, because an
  unproved fuel bound can only cause a spurious rejection and never a misinterpretation. No other
  phase may be excluded: each of the other eight is load-bearing for the task's stated deliverable.
