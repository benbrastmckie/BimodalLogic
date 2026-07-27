// ============================================================================
// ax-machine-appendix.typ
// Back-matter appendix -- The Machine-Readable Axiomatization
//
// All three tables below are rendered from generated/machine-appendix.typ,
// which is itself rendered from generated/machine-appendix.jsonl by
// scripts/typst-machine-appendix.sh. Nothing in the tables is hand-copied:
// the JSONL is produced by `lake exe machine_appendix`, whose schema
// formulas are extracted from the Axiom type index in Lean.
// Freshness is enforced by scripts/typst-sync-check.sh Check 3.
// ============================================================================

#import "../template.typ": *
#import "../generated/machine-appendix.typ": axiom-table, rule-table, derived-op-table, stamp-commit, stamp-date, machine-axiom-count, machine-rule-count, machine-derived-op-count

#pagebreak()
#heading(numbering: none)[Appendix: The Machine-Readable Axiomatization] <machine-appendix>

This appendix ships the complete *TM* axiomatization in machine-readable form: the #machine-axiom-count axiom schemata, the #machine-rule-count inference rules of `DerivationTree`, and the #machine-derived-op-count derived-operator definitions.
The raw artifact is a JSONL file committed alongside this book at `typst/generated/machine-appendix.jsonl`; the tables below are *rendered from that artifact* (via `scripts/typst-machine-appendix.sh`), never hand-copied.
It is intended for the AI-practitioner audience of @sec:dataset-pipeline: an agent or pipeline can consume the axiomatization directly, in the same formula encoding as the training datasets.

Each JSONL line is one JSON object tagged by a `kind` field: one `metadata` line (generator, version, commit stamps, counts), then one line per axiom (`kind: "axiom"`), inference rule (`kind: "inference_rule"`), and derived operator (`kind: "derived_operator"`).
Axiom lines carry the constructor `name`, source `layer`, schematic `params`, minimum `frame_class` (`Base`, `Dense`, or `Discrete`, per `Axiom.minFrameClass`), and the schema formula both as a display string (`schema_string`) and as a structured tree (`schema`).
Schemas and definitions are given over the six-constructor primitive basis, in the `Formula.toJson` tag encoding shared with the dataset pipeline:

#figure(
  table(
    columns: 2,
    stroke: none,
    align: (left, left),
    table.hline(),
    table.header([*Constructor (`tag`)*], [*JSON shape*]),
    table.hline(),
    [`atom`], [`{"tag": "atom", "name": "<base>"}`],
    [`bot`], [`{"tag": "bot"}`],
    [`imp`], [`{"tag": "imp", "left": <φ>, "right": <ψ>}`],
    [`box`], [`{"tag": "box", "child": <φ>}`],
    [`untl`], [`{"tag": "untl", "event": <φ>, "guard": <ψ>}`],
    [`snce`], [`{"tag": "snce", "event": <φ>, "guard": <ψ>}`],
    table.hline(),
  ),
  caption: [The `Formula.toJson` tag encoding (`Automation/DataExport.lean`), shared by the machine appendix and the dataset pipeline.],
)

Loading the artifact is two lines of Python:

```python
import json
records = [json.loads(line) for line in open("machine-appendix.jsonl")]
```

Derived operators are exported as *kernel-computed unfoldings*: each definition below is the real Lean `def` applied to schematic atoms, so the right-hand sides are the exact primitive-basis formulas the proof system manipulates.
Schematic metavariables (φ, ψ, χ, θ, p) are encoded as atoms with those base names.

#heading(level: 2, numbering: none)[The Axiom Schemata #text(size: 10pt, weight: "regular")[(#machine-axiom-count constructors, `ProofSystem/Axioms.lean`)]]

#[
#show figure: set block(breakable: true)
#figure(
  table(
    columns: (auto, auto, auto, auto, 1fr),
    stroke: none,
    align: (left, left, left, left, left),
    inset: (x: 4pt, y: 3pt),
    table.hline(),
    table.header([*Name*], [*Layer*], [*Params*], [*Class*], [*Schema (primitive basis)*]),
    table.hline(),
    ..axiom-table.map(((name, layer, params, fc, schema)) => (
      text(size: 8pt, raw(name)),
      text(size: 8pt)[#layer],
      text(size: 8pt)[#params],
      text(size: 8pt)[#fc],
      text(size: 8pt, raw(schema)),
    )).flatten(),
    table.hline(),
  ),
  caption: [The #machine-axiom-count axiom constructors of `Axiom`, in source order, with schemas extracted from the type index and frame classes from `Axiom.minFrameClass`.],
)
]

#heading(level: 2, numbering: none)[The Inference Rules #text(size: 10pt, weight: "regular")[(#machine-rule-count constructors, `ProofSystem/Derivation.lean`)]]

#[
#show figure: set block(breakable: true)
#figure(
  table(
    columns: (auto, auto, auto, 1fr),
    stroke: none,
    align: (left, left, left, left),
    inset: (x: 4pt, y: 3pt),
    table.hline(),
    table.header([*Name*], [*Premises*], [*Conclusion*], [*Side condition*]),
    table.hline(),
    ..rule-table.map(((name, premises, conclusion, side)) => (
      text(size: 8pt, raw(name)),
      text(size: 8pt)[#premises],
      text(size: 8pt)[#conclusion],
      text(size: 8pt)[#side],
    )).flatten(),
    table.hline(),
  ),
  caption: [The #machine-rule-count inference rules (constructors of `DerivationTree`). The three necessitation-style rules apply to theorems only (empty context).],
)
]

#heading(level: 2, numbering: none)[The Derived Operators #text(size: 10pt, weight: "regular")[(#machine-derived-op-count definitions, `Syntax/Formula.lean`)]]

#[
#show figure: set block(breakable: true)
#figure(
  table(
    columns: (auto, auto, 1fr),
    stroke: none,
    align: (left, left, left),
    inset: (x: 4pt, y: 3pt),
    table.hline(),
    table.header([*Name*], [*Params*], [*Definition (primitive basis)*]),
    table.hline(),
    ..derived-op-table.map(((name, params, definition)) => (
      text(size: 8pt, raw(name)),
      text(size: 8pt)[#params],
      text(size: 8pt, raw(definition)),
    )).flatten(),
    table.hline(),
  ),
  caption: [The #machine-derived-op-count derived operators, each unfolded to the primitive basis by the Lean kernel (the real `def` applied to schematic atoms).],
)
]

#v(0.5em)
#align(right)[
  #text(size: 9pt, style: "italic")[Generated from live source at commit #raw(stamp-commit) (#stamp-date) --- never hand-copied. Regenerate: `scripts/typst-machine-appendix.sh`.]
]
