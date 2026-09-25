# Research Report: Required Target Time and Target Grouping

**Task**: 669 - Make the witness-family certificate's target time a required field and group the target condition to mirror the Lean structure.
**Started**: 2026-09-25T00:45:00Z
**Completed**: 2026-09-25T00:58:00Z
**Effort**: Small-to-medium (one schema revision across 6 files; no new proof obligations)
**Dependencies**: None (the `check_certificate` executable and its test rows already exist and are green)
**Sources/Inputs**: - Codebase (`BimodalTools/CertificateImport.lean`, `BimodalTools/CheckCertificateMain.lean`, `BimodalTools/JsonParse.lean`, `Tests/BimodalToolsTest/CertificateImportTest.lean`, `BimodalTools/README.md`, `lakefile.toml`, `scripts/check-module-invariants.sh`), `FormalSystem/Metalogic/Decidability/WitnessFamily/{Basic,Predicates,Decide}.lean`, a compiled end-to-end design spike run under `lake env lean`
**Artifacts**: - specs/669_required_target_time_and_target_grouping/reports/01_required-target-time-grouping.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The design is verified, not merely proposed.** A full end-to-end spike of the proposed
  nested-`target` schema — new records, partial-record parser, serializer, and the dependent-typed
  `mkFamily`/`checkRaw` rebuilt on top of them — was compiled against the real environment with
  `lake env lean` and exits **0 with zero output**: every one of its 12 `#guard` rows passes,
  including the two rows that were the only genuine risk in this task.
- **The one real risk was the dependent-type question, and it is closed.** `mkFamily raw` has type
  `Except StructuralFault (WitnessFamily raw.premises raw.conclusions)`; nesting turns that into
  `WitnessFamily raw.target.premises raw.target.conclusions`, and the test rows annotate the result
  as `fun W : WitnessFamily gammaPos delPos`. That unification still succeeds through the extra
  projection — confirmed by a passing `#guard`, not by argument.
- **Required-ness is best expressed by a parse-time partial record, not by the wire record.**
  `pObjectFields` folds a handler over an accumulator with defaults, so a field with no default
  cannot be its accumulator. Parse into `PartialTarget`/`PartialCertificate` (with
  `time : Option Int := none`), then `complete` them into the real records, returning
  `Except String` — which lands on `checkLine`'s **existing** `.error` path and therefore yields
  `{"status":"error",...}`, exactly as the acceptance criterion demands, with no change to
  `CheckResult` and no new rejection path.
- **Keep `premises`/`conclusions` defaulted to `[]`; make only `time` required.** `[]` is the
  identity of a context — an absent premise list genuinely means "no premises", a real certificate
  case. `0` is not the identity of a time; it is an arbitrary point that denotes the origin only by
  `LabelledLasso`'s decoding convention. That asymmetry is the whole argument for the task and
  should be written into the docstring as such.
- **Scope is two files wider than the dispatch names**: `BimodalTools/CheckCertificateMain.lean`'s
  `## Usage` block and `lakefile.toml`'s `# Run with:` comment both print the flat shape, and both
  become actively wrong (they would now be rejected as protocol errors). Two README inventory rows
  also go stale on line count and are fixed mechanically.
- **Recommendation: proceed.** Zero sorries, zero new axioms, no proof obligations of any kind.
  The entire change is data-shape plumbing plus documentation.

## Context & Scope

The task makes two coupled changes to the `lake exe check_certificate` wire format, in one
revision:

1. `"time"` becomes required. Its absence is a *protocol* failure (`{"status":"error"}`), not a
   *verdict* (`{"status":"rejected"}`) — the distinction the README's "Certificate re-verification
   protocol" section already settles and which this change must not blur.
2. `premises`, `conclusions` and `time` are grouped under one `"target"` object, because they are
   the three components of the single predicate `WitnessFamily.Target`.

Researched: the current parser/serializer mechanics, every consumer of the affected declarations,
the invariant gates that the change must still pass, and — by compiled spike — whether the proposed
shape actually elaborates and re-verifies the two example families.

Constraints observed: zero-debt (no sorry, no axiom); `.claude/rules/source-store-deploy-boundary.md`
is not engaged (no `.claude/**` writes); no task-number citations in deliverables.

## Findings

### Codebase Patterns

**The current shape.** `RawCertificate` (`BimodalTools/CertificateImport.lean:116-127`) is flat:
`premises`, `conclusions`, `bx`, `lassos`, `time`, every field defaulted, `time : Int := 0`. The
envelope parser `pRawCertificate` (`:240-259`) is a `pObjectFields` fold whose accumulator is that
same record, seeded with `{}`. The serializer is `RawCertificate.toJson` (`:294-299`) — note that
the task description calls it `certificateToJson`; **no declaration of that name exists**, and the
plan should not go looking for one.

**Three downstream readers of the flat fields**, all in the same file:
- `RawCertificate.formulas` (`:319-321`) — `c.premises ++ c.conclusions ++ ...`
- `mkFamily` (`:366-375`) — both its *return type*
  `Except StructuralFault (WitnessFamily raw.premises raw.conclusions)` and its
  `closureOf (raw.premises ++ raw.conclusions)` body
- `checkRaw` (`:505-518`) — three uses of `raw.time` (the `decidableTarget` call, the
  `targetFailure` scan, and the accepted `.countermodel raw.time`)

**The error/verdict split is already load-bearing and already correct.** `checkLine` (`:521-524`)
maps `parseCertificate`'s `.error msg` straight to `CheckResult.error msg`, which
`CheckResult.toJson` (`:558`) renders as `{"status":"error","message":...}`. So *any* failure
surfaced as an `Except String` from the parse stage automatically lands on the required path. No
new constructor, no new branch, no risk of the missing field being misreported as a rejection.

**`pObjectFields` is generic in its accumulator** (`:185-206`), takes `init : α`, and `pExpect`
skips leading whitespace (`BimodalTools/JsonParse.lean:78`). Both facts matter: the first means a
nested `"target"` object can be parsed by a second `pObjectFields` call with its own accumulator
type; the second means the nested call needs no extra whitespace handling at the `:` boundary. The
"unknown fields are skipped" behaviour (`pSkipValue`) then holds at *both* nesting levels for free.

**Why the wire record cannot itself be the parse accumulator.** `pObjectFields` needs `{}` (all
fields defaulted) as its seed. A `time : Int` with no default makes `{}` ill-formed. The seam is
therefore a parse-time partial record — which is also where the "was the key present?" information
naturally lives, since `Option Int` distinguishes absent from `0` and `Int` cannot.

**Gates the change must still clear** (`scripts/check-module-invariants.sh`):
- **C25** — every `lean_exe` root in `lakefile.toml` compiles, which covers `check_certificate`.
- **INV** — every `<!-- BEGIN GENERATED: inventory -->` block is current. Both
  `BimodalTools/README.md:152-186` and `Tests/BimodalToolsTest/README.md` carry per-file **line
  counts** for the two files being edited, so they go stale the moment the edit lands. The fix is
  mechanical: `bash scripts/check-module-invariants.sh --emit-inventory`. `scripts/readme-inventory.sh`
  is a deprecated shim that only prints this instruction.
- **C3** (zero structural sorry), **C19** (docstring coverage), **C28** (per-file warning budget —
  neither file has an entry in `scripts/warning-budget.txt`, so the budget is zero and `--wfail`
  must stay clean). **C17** (dead-declaration scan) declares over non-Boneyard `FormalSystem/**`
  only and is reporting-only, so new in-file helpers under `BimodalTools/` are not at risk.

**Full consumer census.** A repo-wide grep for `CertificateImport`, `RawCertificate`,
`parseCertificate`, `checkLine`, `check_certificate` outside `specs/` and `.claude/` returns exactly
six live files: the two Lean sources, the test, the two READMEs, and `lakefile.toml`
(plus `BimodalTools.lean` / `Tests/BimodalToolsTest.lean`, which are import-only aggregators and
need no change). **Nothing under `docs/` or `typst/` documents this schema**, so the documentation
surface is genuinely just the README section and two usage comments.

### External Resources

Mathlib search tools were **not** used, and deliberately so: this task introduces no proof goal, no
new lemma need, and no mathematical content. The relevant "external" references are internal
formal-system anchors:

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean:108-114` —
  `Target (W) (t) : Prop := (∀ γ ∈ Γ, γ ∈ W.main t) ∧ (∀ σ ∈ Del, σ ∉ W.main t)`. This is the
  grouping's justification made precise: the predicate's content is fixed by exactly three data —
  `Γ`, `Del` (the family's type indices) and `t` (its explicit argument). The JSON `"target"` object
  carrying exactly `premises`, `conclusions`, `time` is a field-for-field mirror of that triple.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean:31-35` — "Field names are an export
  contract": renaming `back`, `mid`, `fwd`, `bx` or `lassos` is a breaking change on the consuming
  side. The grouping is the same principle applied one level up, to *structure* rather than to
  spelling.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean:927` — `decidableTarget W t`, the
  instance `checkRaw` evaluates at the certificate's time. It takes `t` as an argument; nothing in
  the Lean side ever supplied a default, which is itself evidence that the `:= 0` was a wire-format
  convenience rather than a modelling decision.

### Recommendations

A **sorry-free path exists and has been compiled**. The recommended shape, verbatim from the
spike that passes:

**1. Two wire records, replacing the one flat record.**

```lean
structure RawTarget where
  premises : List Formula := []
  conclusions : List Formula := []
  time : Int                       -- no default: required
  deriving Repr, Inhabited, DecidableEq

structure RawCertificate where
  target : RawTarget               -- no default
  bx : List (Formula × Bool) := []
  lassos : List RawLasso := []
  deriving Repr, Inhabited, DecidableEq
```

`deriving Inhabited` is confirmed to still synthesize with non-defaulted fields (`Int` and
`RawTarget` are both `Inhabited`); `deriving` uses the field *types*, not the field defaults.

**2. Two partial records plus their `complete` functions — the required-field seam.**

```lean
structure PartialTarget where
  premises : List Formula := []
  conclusions : List Formula := []
  time : Option Int := none
  deriving Repr, Inhabited, DecidableEq

structure PartialCertificate where
  target : Option PartialTarget := none
  bx : List (Formula × Bool) := []
  lassos : List RawLasso := []
  deriving Repr, Inhabited, DecidableEq

def PartialTarget.complete (p : PartialTarget) : Except String RawTarget :=
  match p.time with
  | none => .error "\"target\" is missing required field \"time\""
  | some t => .ok { premises := p.premises, conclusions := p.conclusions, time := t }

def PartialCertificate.complete (p : PartialCertificate) : Except String RawCertificate := do
  match p.target with
  | none => .error "certificate is missing required field \"target\""
  | some pt => return { target := (← pt.complete), bx := p.bx, lassos := p.lassos }
```

Two distinct messages fall out at no extra cost, which is worth having: a producer that forgot the
whole `"target"` object and one that forgot only its `"time"` have made different mistakes.

**3. The parser gains one nested level; `parseCertificate` gains one `complete` call.**

```lean
def pRawTarget : PState → Except String (PartialTarget × PState) :=
  pObjectFields (fun key acc st => do
    if key == "premises" then ... else if key == "conclusions" then ...
    else if key == "time" then
      let (v, st) ← pInt st
      return ({ acc with time := some v }, st)
    else
      let st ← pSkipValue st
      return (acc, st)) {}

def parseCertificate (s : String) : Except String RawCertificate := do
  let (p, _) ← pPartialCertificate (mkPState s)
  p.complete
```

`parseCertificate` keeps its name and its type `Except String RawCertificate`, so `checkLine` is
untouched and the protocol-error routing is inherited rather than rebuilt.

**4. Serializer splits in two**, `RawTarget.toJson` and `RawCertificate.toJson`, emitting
`{"target":{...},"bx":[...],"lassos":[...]}`. The round-trip
`parseCertificate ∘ RawCertificate.toJson = id` is preserved (verified).

**5. Three call sites re-projected**: `RawCertificate.formulas` → `c.target.premises ++
c.target.conclusions ++ ...`; `mkFamily`'s return type and `closureOf` argument →
`raw.target.premises` / `raw.target.conclusions`; `checkRaw`'s three `raw.time` → `raw.target.time`.
No logic changes anywhere.

**6. Output shape unchanged.** `.countermodel raw.target.time` still renders
`{"status":"countermodel","time":t}`. The dispatch is explicit that the output keeps echoing the
time flat, and nothing in the change pressures that.

**7. Test rows.** Of the 21 `#guard` rows, most need only the literal reshaped
(`target := { premises := gammaPos, conclusions := delPos, time := 0 }`). Three need real thought:
- `CertificateImportTest.lean:150-151` — *"`"time"` is optional on the wire and defaults to `0`"* —
  is now a **false** statement of the contract and must be **inverted**, not merely edited: assert
  that the same input is an error.
- `:154-155` (negative time) and `:158-159` (unknown field skipped) need the nested envelope; the
  unknown-field row is worth *extending* to cover an unknown field **inside** the `"target"` object,
  since that is new surface the nesting creates.
- `:164` (fresh-indexed atom) uses `{ sepRaw with premises := ... }`, which becomes
  `{ sepRaw with target := { sepRaw.target with premises := ... } }`.

Recommended **new** rows, both of which passed in the spike and both of which pin the acceptance
criterion directly rather than by proxy:

```lean
#guard (checkLineToJson "{\"target\":{\"premises\":[],\"conclusions\":[]},\"lassos\":[]}").startsWith
  "{\"status\":\"error\""

#guard (checkLineToJson "{\"bx\":[],\"lassos\":[]}").startsWith "{\"status\":\"error\""
```

Asserting on the rendered JSON prefix (rather than on the `CheckResult` constructor) is what makes
the row say *"status error, not rejected"* in the acceptance criterion's own vocabulary.

**8. Documentation, in four places.**
- The **module docstring** of `CertificateImport.lean` records the rationale the dispatch dictates:
  `Target Γ Δ` is an existential whose witness is `t`; every other existential in the certificate is
  explicitly witnessed (the box guess witnesses which boxes are false, the lassos witness the
  falsifying histories, the labels witness the types), so a defaulted `t` left the *outermost*
  existential the only unwitnessed one — against the whole point of a certificate, which is that
  checking requires no search. Second strand: `0` denotes the origin only by `LabelledLasso`'s
  three-segment decoding convention, so a re-indexing (branching families with shared states;
  the compression half of the quasimodel route) would silently change the meaning of every stored
  certificate that relied on the default. The `## Main Definitions` list should gain `RawTarget`
  and the partial records.
- **`BimodalTools/README.md`**, "Certificate re-verification protocol": the input block, the field
  table (a `target` row plus indented `target.premises` / `target.conclusions` / `target.time` rows,
  with the optionality note **deleted** and replaced by a required-field statement), and — per the
  cross-repo note — a sentence stating plainly that a certificate lacking `"target"` or
  `"target"."time"` is answered `{"status":"error"}`, so ModelChecker's exporter can be written
  against the section without reading the Lean.
- **`BimodalTools/CheckCertificateMain.lean:38`** — the `## Usage` example currently shows the flat
  shape *with* `"time"`; it must show the nested one.
- **`lakefile.toml:163`** — the `# Run with:` comment shows the flat shape *without* `"time"`, which
  the change turns from merely stale into an example that would be rejected.

**9. Regenerate the inventories last**: `bash scripts/check-module-invariants.sh --emit-inventory`,
then confirm with the full `bash scripts/check-module-invariants.sh`. Doing this before the Lean
edits are final just means doing it twice.

## Decisions

- **Nest in Lean, not only on the wire.** `RawCertificate` gets a real `RawTarget` field rather than
  staying flat with a nested-only serializer. Rationale: `Basic.lean` makes field naming an export
  contract; a serializer that invents structure the record does not have re-introduces exactly the
  drift the contract exists to prevent, and it would make the round-trip `#guard` test a weaker
  statement than it is today. Cost measured in the spike: three re-projected call sites, one of them
  a dependent return type — and it compiles.
- **Required-ness lives in a parse-time partial record**, not in a validation pass over a fully
  defaulted record. A `time : Option Int` *cannot* confuse "absent" with "0"; a post-hoc check over
  `time : Int := 0` structurally cannot tell them apart. The `Option` is the honest encoding.
- **Only `time` becomes required; `premises` and `conclusions` keep `:= []`.** `[]` is the identity
  of a context and an absent premise list has an unambiguous correct reading; `0` is not the
  identity of a time and an absent time does not. This asymmetry should be stated in the docstring,
  because a later reader will otherwise "tidy" it in one direction or the other.
- **The whole `"target"` object is required too**, which follows: if `"target"` is absent then
  `"target"."time"` is absent. Distinct error messages for the two cases.
- **No `CheckResult` change.** Protocol failures already route through `parseCertificate`'s
  `Except String`; adding a constructor would create a second way to say "error" and invite the
  rejected/error confusion the README settles.
- **No Mathlib search performed.** There is no proof goal, no lemma gap and no mathematical content
  in this change; searching would have produced noise, not evidence. The compiled spike is the
  evidence this report rests on instead.

## Risks & Mitigations

| Risk | Assessment | Mitigation |
|------|-----------|------------|
| `mkFamily`'s dependent return type stops unifying with the test rows' `fun W : WitnessFamily gammaPos delPos` annotation once it reads through `raw.target.premises` | **Closed.** This was the only genuine technical risk. The spike's two `mkFamily` rows pass. | None needed; the spike file is reproducible (see Appendix) |
| A missing `"time"` gets reported as `rejected` rather than `error` | Low — but it is the acceptance criterion, so it must be pinned | Route the failure through `parseCertificate`'s existing `Except String`; assert on the **rendered JSON prefix** `{"status":"error"` in a `#guard`, not on an internal constructor |
| `pObjectFields`' `{}` seed breaks once a field loses its default | **Real, and designed around.** It is why the partial records exist | Parse into `PartialCertificate`; `complete` into `RawCertificate` |
| README inventory blocks go stale on line count → `INV` fails, `check-module-invariants.sh` does not print ALL CHECKS PASSED | Certain to occur; trivially fixed | `bash scripts/check-module-invariants.sh --emit-inventory` as the final step, before the verification run |
| Stale flat examples left in `CheckCertificateMain.lean` and `lakefile.toml` — both outside the dispatch's stated SCOPE | Moderate: an example that is now a *protocol error* is worse than a stale one, and the cross-repo note makes the exporter author a likely reader of exactly these lines | Treat both as in scope; they are one line each |
| Silent semantic drift for a producer that omits `"target"` entirely and would previously have been checked against empty `Γ`, `Δ` at time `0` | This is the *point* of the change, not a regression | Record it in the README as a stated behaviour change |
| Sorry/axiom debt | None. The change contains no proof obligation whatsoever — `mem_closureList` is untouched and every new declaration is data or `Except`-valued plumbing | C3 and the axiom baseline (C2) are unaffected by construction |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task introduces no proof goal: every new
  declaration is a structure, a parser, a serializer or an `Except`-valued conversion, and the
  existing `dite`-discharged proof fields in `mkLasso`/`mkFamily` are carried over verbatim. The
  verification that *was* performed is a compiled design spike (Appendix), which is the appropriate
  instrument here.

## Context Extension Recommendations

- **Topic**: Required-vs-optional field encoding in the `pObjectFields` parser idiom.
- **Gap**: `BimodalTools/JsonParse.lean`'s fold-with-defaults idiom makes *optional* the path of
  least resistance and offers no pattern for *required*. This task discovers the partial-record
  seam; the next schema tightening will rediscover it from scratch.
- **Recommendation**: Once implemented, the partial-record/`complete` pair is worth a short note in
  `JsonParse.lean`'s module docstring (or a `context/project/lean4/patterns/` entry) so the pattern
  is found rather than reinvented — particularly since the cross-repo note implies more schema work
  ahead as ModelChecker's exporter is written.

## Appendix

**The verification spike.** A single file was written to the session scratchpad, declaring the
complete proposed design in a fresh `Spike` namespace on top of `import BimodalTools.CertificateImport`
— `RawTarget`, `RawCertificate`, both partial records, both `complete` functions, `pRawTarget`,
`pPartialCertificate`, `parseCert`, both `toJson` functions, and re-projected copies of
`RawCertificate.formulas`, `mkFamily`, `checkRaw`, `checkLine` and `checkLineToJson` — followed by
12 `#guard` rows. Run as:

```
lake env lean <scratchpad>/Spike.lean
```

**Result: exit 0, zero bytes of output.** In Lean that is the strongest available signal short of a
full build: every `#guard` evaluated to `true` (a failing `#guard` is an error), and there were no
warnings, so the `--wfail` criterion is not endangered by anything in the design.

Rows that passed, grouped by what each one establishes:

| Row | Establishes |
|-----|-------------|
| `(mkFam posRaw).toOption.map (fun W : WitnessFamily gammaPos delPos => W.lassos) = some [posLasso]` | The dependent return type still unifies through `raw.target.premises` |
| the same for `sepRaw` / `sepLasso` | ditto, second family |
| `checkCertLine posRaw.toJson = CheckResult.countermodel 0` | Non-vacuity family still accepted, **through the new wire format** |
| `checkCertLine sepRaw.toJson = CheckResult.rejected [sepExpected]` | Separation family still rejected at `fulfilling`, lasso `0`, position `-2`, formula `p U q` |
| `parseCert posRaw.toJson = .ok posRaw`, and for `sepRaw` | Round trip through the nested shape |
| `parseCert "{\"target\":{\"premises\":[],\"conclusions\":[]},\"lassos\":[]}"` is `.error _` | Absent `"time"` inside a present `"target"` is a protocol failure |
| `(checkCertLineToJson <same>).startsWith "{\"status\":\"error\""` | …and it renders as **error**, not rejected |
| `(checkCertLineToJson "{\"bx\":[],\"lassos\":[]}").startsWith "{\"status\":\"error\""` | Absent `"target"` altogether is likewise an error |
| `(parseCert "…\"time\":-7…").map (·.target.time) = .ok (-7)` | Negative times still survive `pInt`'s sign handling |
| `(parseCert "{\"note\":…,\"target\":{\"note\":1,…,\"time\":3},…}").map (·.target.time) = .ok 3` | Unknown fields are skipped at **both** nesting levels |

**Searches and greps used**
- Repo-wide consumer census: `grep -rn "CertificateImport\|RawCertificate\|parseCertificate\|checkLine\|check_certificate"` over `*.lean`, `*.toml`, `*.md`, `*.sh`, `*.py`, `*.json`, excluding `specs/` and `.claude/`
- Documentation surface: `grep -rln "lassos\|check_certificate" docs/ typst/ README.md Tests/` → only `Tests/BimodalToolsTest/{README.md,CertificateImportTest.lean}`
- Gate discovery: `grep -n "^#   C[0-9]*" scripts/check-module-invariants.sh`; `--emit-inventory` contract read from the same file's header and from the `scripts/readme-inventory.sh` deprecation shim
- Warning budget: `grep -n "CertificateImport\|BimodalTools" scripts/warning-budget.txt` → no entries, so the budget is zero

**Line references** (against the files as read during this research)
- `BimodalTools/CertificateImport.lean`: `RawCertificate` 116-127 (`time := 0` at 125-126),
  `pObjectFields` 185-206, `pRawCertificate` 240-259 (`"time"` at 254-256), `parseCertificate`
  262-264, `RawCertificate.toJson` 294-299, `RawCertificate.formulas` 319-321, `mkFamily` 366-375,
  `checkRaw` 505-518, `checkLine` 521-524, `CheckResult.toJson` 554-558
- `BimodalTools/CheckCertificateMain.lean`: usage example 37-40
- `BimodalTools/README.md`: protocol section 76-148 (input block 89-95, field table 97-104,
  generated inventory 152-186)
- `Tests/BimodalToolsTest/CertificateImportTest.lean`: literals 63-78, rows 86-170
- `lakefile.toml`: `check_certificate` block 162-167
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean`: `Target` 108-114
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean`: export-contract note 31-35
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean`: `decidableTarget` 927
