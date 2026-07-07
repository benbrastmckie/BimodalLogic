# Research Report: Machine-Readable JSONL Appendix for BimodalReference (Task 316)

**Task**: 316 | **Type**: lean4 | **Session**: sess_1783410218_f83296_316
**Date**: 2026-07-07 | **Status of research**: complete

## Objective

Ground the design of a machine-readable appendix for the BimodalReference book: export the
42-constructor axiom table, 7 inference rules, and derived-operator definitions from Lean as
JSONL; ship it in the book build with a human-readable rendering plus a pointer to the raw
artifact; wire `chapters/p4-dataset-pipeline.typ` to point at the shipped artifact; make
generation re-runnable and commit-stamped like `scripts/typst-status-counts.sh`.

## Ground-Truth Inventory (verified against live source)

### Axioms — 42 constructors, 8 layers

`Theories/Bimodal/ProofSystem/Axioms.lean`, `inductive Axiom : Formula → Type` (line 76).
Verified count: `awk '/^inductive Axiom/,/deriving Repr/' ... | grep -c '^  | '` = **42**
(exactly the methodology of `typst-status-counts.sh`). Layer comments in source:

| Layer | Content | Count |
|-------|---------|-------|
| 1 | Propositional (`prop_k`, `prop_s`, `ex_falso`, `peirce`) | 4 |
| 2 | S5 Modal (`modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist`) | 5 |
| 3 | BX Temporal (serial/mono/connect/enrichment/self_accum/absorb/linear/until_F/since_P) | 20 |
| 3b | Additional BX Temporal (`temp_linearity`, `temp_linearity_past`, `F_until_equiv`, `P_since_equiv`) | 4 |
| 4 | Modal-Temporal Interaction (`modal_future`) | 1 |
| 5 | Uniformity (`discrete_symm_fwd/bwd`, `discrete_propagate_fwd/bwd`, `discrete_box_necessity`) | 5 |
| 6 | Prior Axioms (`prior_UZ`, `prior_SZ`) | 2 |
| 7 | Z1 (`z1`) | 1 |
| 8 | Density (`density`, `dense_indicator`) | 2 |

Frame classes come from `Axiom.minFrameClass` (Axioms.lean:456): `density`/`dense_indicator`
→ `.Dense`; `prior_UZ`/`prior_SZ`/`z1` → `.Discrete`; catch-all → `.Base`. So Base=37,
Dense-only=2, Discrete-only=3 — matching the `base_count`/`dense_only_count`/
`discrete_only_count` fields of `typst-status-counts.sh --json`.

### Inference rules — 7 constructors

`Theories/Bimodal/ProofSystem/Derivation.lean`, `inductive DerivationTree (fc : FrameClass) :
Context → Formula → Type`: `axiom`, `assumption`, `modus_ponens`, `necessitation`,
`temporal_necessitation`, `temporal_duality`, `weakening`. Verified = **7** (the
`typst-status-counts.sh` RULE_COUNT awk block counts the same lines).

### Derived operators — ~21 definitions

`Theories/Bimodal/Syntax/Formula.lean`. Primitives are `atom`, `bot`, `imp`, `box`, `untl`,
`snce`; everything else is a `def`:

`top` (109→112), `neg` (115), `some_future` (125), `some_past` (135), `all_future` (145),
`all_past` (155), `and` (384), `or` (389), `diamond` (394), `always` (411), `next` (415),
`prev` (419), `weak_future` (428), `weak_past` (437), `release` (448), `weak_until` (457),
`trigger` (465), `weak_since` (474), `strong_release` (477), `strong_trigger` (480),
`sometimes` (519). (Also `atom_s`, a constructor convenience, not a logical operator —
implementation should decide inclusion; recommend excluding it and `swap_temporal`, which is a
formula transformer, not an operator.)

## Existing Schema and Pipeline Assets (reuse targets)

1. **`Automation/DataExport.lean`** — the canonical formula JSON schema used across the whole
   dataset pipeline (and therefore what "matching the DatasetExporter.lean schema" means at the
   formula level):
   - `atom a` → `{"tag": "atom", "name": "<base>"}`; `bot` → `{"tag": "bot"}`;
     `imp` → `{"tag": "imp", "left": ..., "right": ...}`; `box` → `{"tag": "box", "child": ...}`;
     `untl`/`snce` → `{"tag": "untl"|"snce", "event": ..., "guard": ...}`.
   - `Formula.toJson` (line 104), `Formula.prettyPrint` (human-readable), `escapeJsonString`,
     `listToJsonArray`. All string-concatenation based, no external JSON library.
2. **`Automation/DatasetExporter.lean`** — metadata envelope precedent: `DatasetMetadata`
   with `generator` ("BimodalLogic/DatasetExporter"), `version`, `frameClass` fields and
   `.toJson`. The appendix JSONL should carry an analogous metadata line
   (`generator: "BimodalLogic/MachineAppendixExport"`).
3. **`Automation/DatasetExport.lean`** — the JSONL streaming precedent (`writeRecordJSONL`,
   `writeDatasetJSONL`: one JSON object per line via `handle.putStrLn`), CLI arg parsing
   (`--output PATH`), and the `dataset_generator` lake exe wiring.
4. **`Automation/BenchmarkAnchors.lean`** — the closest existing relative:
   - `allAxiomNames : List String` (line 297) already lists **all 42** constructor names.
   - `TaggedFormula` pairs a formula with its `axiomName`.
   - `checkCoverage` verifies 42/42 coverage and warns on missing names — the exact
     self-verification pattern the appendix exporter should replicate.
   - Caveat: BenchmarkAnchors exports *concrete instances* (substitution vocabulary), not
     *schemata*, and its `main` labels via the decision procedure. The appendix wants the
     schemata themselves (with metavariables), so a new module is needed, but `allAxiomNames`
     and the coverage-check idiom transfer directly.
5. **`lakefile.lean`** — 10 existing `lean_exe` declarations, all with `srcDir := "Theories"`
   and `supportInterpreter := true`. Adding `lean_exe machine_appendix where root :=
   `Bimodal.Automation.MachineAppendixExport` follows an established, low-risk pattern.

## Commit-Stamp and Sync Infrastructure (must integrate with)

1. **`scripts/typst-status-counts.sh`** — single-source-of-truth generator. Writes
   `Theories/Bimodal/typst/generated/status.typ` containing `#let stamp-commit = "<short
   sha>"`, `#let stamp-date = "<UTC date>"`, plus counts (`axiom-count`, `rule-count`,
   `base-count`, `dense-only-count`, `discrete-only-count`, sorry counts). `--json` mode
   emits JSON for the sync checker. The generated file header says "GENERATED FILE — never
   edit by hand. Regenerate via: ..." — the appendix generator must copy this pattern.
2. **`scripts/typst-sync-check.sh`** — two checks:
   - Check 1 (name resolution): every backticked span in `typst/**/*.typ` (excluding
     `generated/`) must resolve against live Lean source, exist as a path (repo-root or
     Theories/Bimodal-relative, with suffix search), or be whitelisted in
     `typst/sync-check-whitelist.txt`. **Implication**: the new appendix chapter's backticked
     Lean names (`prop_k`, `Axiom`, `DerivationTree`, ...) resolve automatically; backticked
     artifact paths (e.g. `typst/generated/machine-appendix.jsonl`) resolve via path existence
     once the file is committed; only non-Lean spans like `lake exe machine_appendix` or JSON
     field names would need whitelist entries.
   - Check 2 (count freshness): regenerated `status.typ` JSON must match the committed file
     exactly. A third check for appendix freshness should follow this model.
3. **Task 319 re-anchor** (per `specs/319_.../summaries/01_restructure-clean-textbook-summary.md`,
   line 80): "Task 316: JSONL appendix pointer re-anchored to `chapters/p4-dataset-pipeline.typ`."
   The former "How to Read This Book If You Are an AI" introduction section no longer exists
   (zero sync-class symbols remain in `chapters/`), so the *only* narrative anchor for the
   artifact pointer is the dataset-pipeline chapter.
4. **Book structure** (`typst/BimodalReference.typ`): four parts + back matter. Back matter is
   `chapters/06-notes.typ` followed by an unnumbered `References` heading. The appendix
   belongs between `06-notes.typ` and the bibliography. Five chapters already
   `#import "../generated/status.typ"` — the appendix chapter should import a new generated
   `.typ` the same way.

## Critical Constraint: Artifact Location

`.gitignore` contains `data/*.jsonl` and `/data` ("Do not commit JSONL datasets to git —
download from HF Hub instead") and `build/`. Therefore:

- The shipped JSONL **cannot** live in `data/` (would be untracked and unavailable to readers
  of the repo/book) nor in `typst/build/`.
- `Theories/Bimodal/typst/generated/` is the correct home: `generated/status.typ` is already
  committed there (verified via `git ls-files`), and sync-check's Check 1 skips `generated/`
  for backtick scanning while Check 2 enforces freshness of committed generated files.
- Recommended paths: `Theories/Bimodal/typst/generated/machine-appendix.jsonl` (raw artifact)
  and `Theories/Bimodal/typst/generated/machine-appendix.typ` (human-readable rendering
  consumed by the appendix chapter).

## Recommended Architecture

### Component 1 — Lean exporter module (the fidelity core)

New file `Theories/Bimodal/Automation/MachineAppendixExport.lean`, new
`lean_exe machine_appendix` in `lakefile.lean`. The key design point that eliminates all
hand-copying of formulas is **implicit-index extraction**: because `Axiom : Formula → Type`
is indexed by the axiom's formula, a helper can recover the schema formula from the
constructor's type itself:

```lean
structure AxiomEntry where
  name : String
  layer : String
  params : List String       -- e.g. ["φ", "ψ", "χ"]
  formula : Formula          -- the schema, with metavariables as atoms
  frameClass : FrameClass

/-- The formula index φ is inferred from the constructor application;
    frameClass is computed by `Axiom.minFrameClass`, not hand-assigned. -/
def mkAxiomEntry {φ : Formula} (name layer : String) (params : List String)
    (ax : Axiom φ) : AxiomEntry :=
  { name, layer, params, formula := φ, frameClass := ax.minFrameClass }

-- e.g.
def phi := Formula.atom_s "φ"
def psi := Formula.atom_s "ψ"
-- mkAxiomEntry "modal_t" "S5 Modal" ["φ"] (Axiom.modal_t phi)
```

Instantiating each of the 42 constructors once with schematic atoms (`φ`, `ψ`, `χ`, `θ`, `p`)
yields, for each axiom: the exact schema formula (from the type index — Lean's elaborator
guarantees it matches `Axioms.lean`), the exact frame class (from `minFrameClass` — not a
copied table), serialized with the pipeline's own `Formula.toJson` and `Formula.prettyPrint`.
A wrong formula or frame class is a *type error or definitional mismatch*, not silent drift.

The same trick applies to derived operators: apply the real `def` to schematic atoms and let
`Formula.toJson` serialize the definitional unfolding (e.g. `Formula.neg phi` *is*
`imp (atom "φ") bot` by definition, so the exported `definition` field is computed by the
kernel, never transcribed):

```lean
structure DerivedOpEntry where
  name : String
  params : List String
  definition : Formula   -- the unfolding in primitives, computed by Lean

-- mkDerivedOp "neg" ["φ"] (Formula.neg phi)
-- mkDerivedOp "weak_until" ["φ", "ψ"] (Formula.weak_until phi psi)
```

Inference rules cannot be instantiated the same way (constructors take derivation-tree
arguments), so the 7 rules are declarative records (name, premises as strings, conclusion
string, side condition, e.g. "empty context only" for the three necessitation-style rules).
Fidelity is enforced by count cross-check (see Component 4) and by keeping the records in the
same repo, adjacent to `Derivation.lean`, with doc-comment references.

Self-verification in `main` (mirroring `BenchmarkAnchors.checkCoverage`): assert exactly 42
axiom entries with names matching `allAxiomNames` (importable from `BenchmarkAnchors` or
duplicated with a cross-check), exactly 7 rule entries, and fail with nonzero exit on
mismatch. This makes the exporter a *litmus* against constructor drift: adding a 43rd axiom
breaks the build of the appendix until the table is extended.

### Component 2 — JSONL schema (one object per line)

Aligned with the `DataExport.lean` formula encoding and the `DatasetExporter.lean` metadata
envelope, adapted to JSONL (metadata as first line, `kind` discriminator per line):

```jsonl
{"kind": "metadata", "generator": "BimodalLogic/MachineAppendixExport", "version": "1.0", "stamp_commit": "<sha>", "stamp_date": "YYYY-MM-DD", "axiom_count": 42, "rule_count": 7, "derived_operator_count": N}
{"kind": "axiom", "name": "prop_k", "layer": "propositional", "params": ["φ", "ψ", "χ"], "frame_class": "Base", "schema_string": "(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))", "schema": {"tag": "imp", ...}}
{"kind": "inference_rule", "name": "modus_ponens", "premises": ["Γ ⊢[fc] φ → ψ", "Γ ⊢[fc] φ"], "conclusion": "Γ ⊢[fc] ψ", "side_condition": null}
{"kind": "derived_operator", "name": "neg", "params": ["φ"], "definition_string": "φ → ⊥", "definition": {"tag": "imp", "left": {"tag": "atom", "name": "φ"}, "right": {"tag": "bot"}}}
```

Note: `stamp_commit`/`stamp_date` are injected by the wrapper script (Component 3) — a Lean
exe should not shell out to git. Two clean options: (a) exe accepts `--stamp-commit`/
`--stamp-date` CLI args (script passes them), or (b) exe emits everything except the stamp and
the script prepends/rewrites the metadata line. Option (a) is simpler and keeps the JSONL
written in one pass; recommend (a).

### Component 3 — Generation script (the re-runnable, commit-stamped wrapper)

`scripts/typst-machine-appendix.sh`, modeled line-for-line on `typst-status-counts.sh`:

1. `STAMP_COMMIT=$(git rev-parse --short HEAD)`, `STAMP_DATE=$(date -u +%Y-%m-%d)`.
2. `lake exe machine_appendix -- --output Theories/Bimodal/typst/generated/machine-appendix.jsonl --stamp-commit "$STAMP_COMMIT" --stamp-date "$STAMP_DATE"`.
3. Render `Theories/Bimodal/typst/generated/machine-appendix.typ` **from the JSONL** (python3
   heredoc reading the JSONL with `json.loads` per line — never from the Lean source and never
   hand-written), emitting the standard "GENERATED FILE — never edit by hand" header with
   stamp variables plus typst arrays/tables:
   `#let stamp-commit`, `#let stamp-date`, `#let axiom-table = ( ("prop_k", "propositional", "(φ → (ψ → χ)) → ...", "Base"), ... )`,
   `#let rule-table = (...)`, `#let derived-op-table = (...)`.
4. `--json` mode (metadata-line passthrough with stamps zeroed/normalized) for the sync
   checker, mirroring `typst-status-counts.sh --json`.

### Component 4 — Sync-check extension

Add "Check 3: machine appendix freshness" to `scripts/typst-sync-check.sh`. Two sub-checks,
both cheap (no `lake` invocation in the checker — regeneration via Lean would make sync-check
depend on a full build):

- **Count agreement**: `jq -s` over the committed JSONL: number of `kind=="axiom"` lines must
  equal `AXIOM_COUNT` and `kind=="inference_rule"` lines must equal `RULE_COUNT` from the
  `typst-status-counts.sh` methodology (recompute the two awk counts inline — they are pure
  text scans). This catches "axiom added to Axioms.lean but appendix not regenerated".
- **Rendering agreement**: re-render `machine-appendix.typ` from the committed JSONL (the
  python renderer factored so the checker can call it with the *committed* stamps) and diff
  against the committed `.typ` — proves the human-readable rendering is derived from the
  artifact, not hand-edited. (Same normalize-stamp treatment Check 2 will need: compare with
  committed stamp values, not fresh ones.)

Full regeneration through `lake exe` stays a developer action (documented in the script
header and appendix chapter), exactly like `typst-status-counts.sh` today.

### Component 5 — Appendix chapter + book wiring

- New `chapters/ax-machine-appendix.typ`: unnumbered-or-lettered heading ("Appendix: The
  Machine-Readable Axiomatization"), short prose for the AI-practitioner audience (what the
  artifact is, the `tag`-schema in one table, how to load it — reuse the python two-liner
  idiom from `DatasetExport.lean`'s docstring), pointer to the raw artifact path
  `Theories/Bimodal/typst/generated/machine-appendix.jsonl` (path-like backtick → resolves in
  sync-check via file existence), then `#import "../generated/machine-appendix.typ":
  axiom-table, rule-table, derived-op-table, stamp-commit, stamp-date` and render the three
  tables with the stamp footer ("Generated from live source at commit ... — never hand-copied").
  Note: a 42-row table is large; use the book's existing `stroke: none` + `table.hline()`
  figure style (see the Tier-1 gate table in p4-dataset-pipeline.typ) and allow page breaks.
- `BimodalReference.typ`: `#include "chapters/ax-machine-appendix.typ"` after
  `chapters/06-notes.typ`, before References. If appendix should be unnumbered like
  References, use `#heading(numbering: none)`; if lettered, a local
  `#set heading(numbering: "A.1")` scoped by the include position — implementation detail for
  the planner; both are consistent with the current back-matter layout.
- `chapters/p4-dataset-pipeline.typ`: add a short subsection (natural position: after
  "BimodalHarness Integration: Artifact-Only" or just before "Operational Pointer") titled
  e.g. "Shipped Machine-Readable Axiomatization", stating that the axiom table, rules, and
  derived operators the pipeline presumes are shipped with this book as JSONL at
  `typst/generated/machine-appendix.jsonl`, cross-referencing the appendix
  (`@`-label on the appendix heading) and noting the same `tag` formula encoding is used by
  `dataset_generator` output. This satisfies the task-319 re-anchor: the pointer lives in the
  dataset-pipeline chapter, not the removed AI-intro section.

## Verification Plan (maps to task's verify clause)

1. **Build produces the JSONL**: `lake build Bimodal.Automation.MachineAppendixExport` then
   `bash scripts/typst-machine-appendix.sh`; check the JSONL exists, first line is
   `kind=="metadata"`, `jq` counts = 42/7/N; exporter's own coverage assertion exits 0.
2. **Typst compile green**: `cd Theories/Bimodal/typst && typst compile BimodalReference.typ
   build/BimodalReference.pdf` (command from `typst/README.md:21`).
3. **Sync-check green**: `bash scripts/typst-sync-check.sh` — existing Checks 1-2 plus new
   Check 3. Expected whitelist additions (few): `lake exe machine_appendix`,
   possibly JSON field-name spans used in the appendix prose (`schema_string`, `frame_class`)
   if they don't literal-grep-match Lean source; artifact paths resolve by existence.
4. **Re-runnability**: run the script twice from the same commit → identical output
   (deterministic ordering: source order for axioms/rules, definition order for operators; no
   timestamps except the date stamp).

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| `data/*.jsonl` gitignore would silently drop the artifact | Ship under `typst/generated/` (verified committed location), never `data/` |
| Hand-copied rule records drift from `Derivation.lean` | Count cross-check in sync-check Check 3 + coverage assertion in exe; records live adjacent to source |
| 4-param axioms (`linear_until`, `linear_since`) need θ | Include `θ` in the schematic atom set; `params` field records arity |
| Unicode metavariables (φ, ψ) in JSON | `escapeJsonString` passes non-ASCII through untouched (only escapes `\`, `"`, `\n`) — valid JSON; confirmed by existing pipeline usage of `prettyPrint` output |
| `FrameClass` serialization | Simple 3-case `toString` match (`Base`/`Dense`/`Discrete`) in the new module; do not derive from `Repr` output |
| sync-check runtime growth | Check 3 uses only jq/python on committed files + the two awk count scans; no lake invocation |
| New chapter backticks failing Check 1 | Prefer real Lean identifiers and path-like spans; whitelist the handful of tool-invocation spans |
| `noncomputable` contamination | The exporter touches only `Formula`, `Axiom`, `minFrameClass`, string serialization — all computable; no decision procedure involved (unlike BenchmarkAnchors' labeling step, which is *not* needed here) |

## Tactic Survey Results

Not applicable: this task creates no proof obligations (no theorems, no `sorry` risk). All
Lean additions are computable definitions, structures, and an `IO` main. The zero-debt gate
is satisfied structurally — the implicit-index extraction technique means the only way to
state a wrong axiom schema is a Lean type error.

## Suggested Phase Decomposition (for planner)

1. **Phase 1**: `MachineAppendixExport.lean` (entries for 42 axioms via `mkAxiomEntry`, 7 rule
   records, derived-operator entries, JSONL emission, coverage assertions) + `lakefile.lean`
   exe stanza. Verify: `lake exe machine_appendix` produces valid JSONL with correct counts.
2. **Phase 2**: `scripts/typst-machine-appendix.sh` (stamping, JSONL → `.typ` renderer,
   `--json` mode). Verify: script idempotent, generated `.typ` parses.
3. **Phase 3**: `chapters/ax-machine-appendix.typ`, `BimodalReference.typ` include,
   `p4-dataset-pipeline.typ` pointer subsection, whitelist entries. Verify: typst compile.
4. **Phase 4**: sync-check Check 3 + full verification sweep (lake build, typst compile,
   sync-check, double-run determinism) + commit generated artifacts.

## Key Files

- `Theories/Bimodal/ProofSystem/Axioms.lean` — 42-constructor `Axiom` inductive, `minFrameClass` (line 456)
- `Theories/Bimodal/ProofSystem/Derivation.lean` — 7-constructor `DerivationTree`
- `Theories/Bimodal/Syntax/Formula.lean` — ~21 derived-operator `def`s
- `Theories/Bimodal/Automation/DataExport.lean` — `Formula.toJson` tag schema (line 104), `prettyPrint`, `escapeJsonString`
- `Theories/Bimodal/Automation/DatasetExporter.lean` — metadata envelope precedent
- `Theories/Bimodal/Automation/DatasetExport.lean` — JSONL streaming + CLI precedent
- `Theories/Bimodal/Automation/BenchmarkAnchors.lean` — `allAxiomNames` (line 297), coverage-check idiom
- `scripts/typst-status-counts.sh` — commit-stamp generator pattern to replicate
- `scripts/typst-sync-check.sh` — checker to extend with Check 3
- `Theories/Bimodal/typst/BimodalReference.typ` — include point (after line 245, before References)
- `Theories/Bimodal/typst/chapters/p4-dataset-pipeline.typ` — pointer re-anchor target (task 319)
- `Theories/Bimodal/typst/generated/` — committed home for `machine-appendix.jsonl` + `.typ`
- `.gitignore` — `data/*.jsonl` exclusion forcing the typst/generated location
