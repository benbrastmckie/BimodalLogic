// ============================================================================
// p4-dataset-pipeline.typ
// Part II chapter -- The BMLogic Dataset Pipeline
// Canonical narrative for docs/training/PIPELINE.md (which holds the
// operational quick-reference). Centerpiece chapter for the
// AI-training-practitioner audience.
// ============================================================================

#import "../template.typ": *

= The BMLogic Dataset Pipeline <sec:dataset-pipeline>

#chapter-header(
  description: [The dual-signal training-data pipeline that turns the formal decision procedure into machine-learning-ready datasets -- architecture, module map, the Tier-1 feasibility gate results (including the provability-ratio shortfall), and the Tier-2 response.],
  dependencies: [Chapter 2 (decidability, @sec:decidability-practice) for `decide` and its certificate/countermodel outputs.],
)


== The Practitioner Thesis, Restated

Decidable fragments (@sec:decidability-practice) are a target for full automation; the full logic is a target for training AI systems to reason proof-theoretically, because every enumerated formula's decision yields a *deterministically checkable* training signal -- a kernel-checked proof term or an explicit countermodel, never a merely-plausible label.
This chapter is the canonical narrative home of that pipeline; `docs/training/PIPELINE.md` holds the operational quick-reference.

== Dual-Signal Architecture

For each enumerated formula, the decision procedure (`decide`, @sec:decidability-practice) yields exactly one of two supervisory signals:

- *Positive signal -- proof traces (policy network)*: for a formula decided valid, a `ProofTrace` records derivation `height`, the `axioms_used`, and the `rules_applied`. "The policy network learns to predict *which axioms and rules to apply* at each step of a proof search."#footnote[`docs/training/PIPELINE.md:24-31`.]
- *Corrective signal -- countermodels (value network)*: for a formula decided invalid, a `SimpleCountermodel` records `trueAtoms`/`falseAtoms`/`formula`. "The value network learns to estimate the probability that a given proof state leads to a valid proof... they teach the network which formula shapes are *not* theorems."#footnote[`docs/training/PIPELINE.md:33-40`.]
- *Enriched corrective signal (Tier 2)*: `EnrichedCountermodel.lean` retains the full saturated tableau branch (which modal/temporal subformulas held or failed); the module is implemented and tested, and its integration into the main export path belongs to the pipeline's second tier.#footnote[`docs/training/PIPELINE.md:42-44`; `Automation/EnrichedCountermodel.lean` (211 lines per `Automation/README.md`).]

== Pipeline Flow and Module Map

`FormulaEnumerator.lean` enumerates formulas up to a depth/size bound; `DatasetGenerator.lean` labels each via `decide`, extracting a proof trace or countermodel; `DatasetExport.lean` (JSONL, feeding the `dataset_generator` executable) and `DatasetExporter.lean` (structured JSON, feeding a Python tensor-conversion script) export the labeled dataset.
The pipeline comprises seven Lean modules -- `DataExport.lean`, `FormulaEnumerator.lean`, `DatasetGenerator.lean`, `EnrichedCountermodel.lean`, `DatasetExporter.lean`, `DatasetExport.lean`, and `DatasetValidator.lean` -- with `DataExport.lean` serving as a shared dependency of the other six rather than a pipeline stage in its own right.#footnote[`docs/training/PIPELINE.md`, Module Reference section.]

=== Anatomy of a Dataset Record

Each exported JSONL line is a `DatasetRecord` (`Automation/DatasetExport.lean:130`), carrying the formula in several parallel encodings alongside its label and exactly one supervisory payload.
A representative valid-formula record, abridged from the schema documented at the head of `DatasetExport.lean`:

```json
{
  "id": "bmlogic-00001",
  "split": "train",
  "formula_str": "(□p → p)",
  "formula_ast": {"tag": "imp", "left": {"tag": "box", ...}, "right": ...},
  "frame_class": "Base",
  "label": "valid",
  "proof_trace": {"height": 0, "axioms_used": ["modal_t"], "rules_applied": []},
  "countermodel": null,
  "pattern_key": {"modalDepth": 1, ...},
  "metrics": {"complexity": 3, ...}
}
```

The record design encodes the dual-signal contract structurally: `proof_trace` (a `ProofTrace` of derivation `height`, `axioms_used`, `rules_applied`) is populated exactly when the label is `valid`, and `countermodel` (the `SimpleCountermodel` triple of `trueAtoms`/`falseAtoms`/`formula`) exactly when it is `invalid`.
The redundant formula encodings serve different consumers: `formula_str` for human inspection, `formula_ast` (the `Formula.toJson` tag schema) for tokenizer-free tree models, an S-expression and a prefix-notation token list for sequence models, and folded variants that restore derived-operator vocabulary ($not$, $and$, $or$, $diamond.stroked$) for models trained on the surface language.
`pattern_key` mirrors the structural features the proof-search learning layer uses (@sec:proof-automation), and `metrics` records difficulty measures (complexity, modal depth, temporal depth) that support curriculum ordering and stratified splits downstream.

Two `lake exe` executables compile from this pipeline:#footnote[`docs/training/PIPELINE.md:428-437`, quoting the `lakefile.lean` executable declarations.]

#items[
  #item[`dataset_generator` (root `Bimodal.Automation.DatasetExport`) -- the main JSONL export executable.]
  #item[`dataset_validator` (root `Bimodal.Automation.DatasetValidator`) -- validates exported datasets against the schema contract.]
]

== BimodalHarness Integration: Artifact-Only

"The integration between the two repositories is *artifact-only*: BimodalHarness never calls Lean at runtime. Instead, it reads JSONL files exported by `lake exe dataset_generator` and synced via a sync command."#footnote[`README.md:183-184` and `docs/training/PIPELINE.md:14`, near-identical wording in both places; sync mechanism detailed at `docs/training/PIPELINE.md:612`.]
The sync mechanism is a plain file-sync step: generate JSONL in BimodalLogic, a sync command copies `data/` to the BimodalHarness data directory, and BimodalHarness's Python side reads the synced files -- no cross-repository Lean dependency at training or inference time.

== The Tier-1 Feasibility Gate

A small-config gate (modal depth 2, temporal depth 2, max size 8, 3 atoms) ran 30/30 conformance tests successfully and produced 254,252 distinct formulas, but the feasibility criteria were *not* all met:

#figure(
  table(
    columns: 4,
    stroke: none,
    align: (left, left, left, left),
    table.hline(),
    table.header([*Criterion*], [*Target*], [*Actual*], [*Result*]),
    table.hline(),
    [Distinct formulas], [$gt.eq$ 1,000], [254,252], [PASS],
    [Provability ratio], [0.15--0.70], [0.033 (3.2% valid)], [FAIL],
    [Proof height variance], [$gt$ 2.0], [0.0], [FAIL],
    [$gt.eq$ 3 categories $gt$ 10%], [$gt.eq$ 3], [4], [PASS],
    [$lt$ 80% trivially propositional], [$lt$ 80%], [35.9%], [PASS],
    [$lt$ 90% same decision], [$lt$ 90%], [92.6%], [FAIL],
    table.hline(),
  ),
  caption: [Tier-1 feasibility gate results (`docs/training/PIPELINE.md:687-740`): overall gate decision *FAILED*, 3 of 6 hard criteria not met.],
)

This is the "sizable remaining project" the introduction's practitioner thesis points to: the raw enumeration over-produces non-theorems (92.6% invalid, only 3.2% valid against a 15% minimum target), so a naive dataset is imbalanced and low-variance on the policy side.

== The Tier-2 Response: Theorem Mining

The recommended response is *not* to abandon the dual-signal approach but to change how formulas are sourced for labeling: "Generate formulas by composing known axiom instances (apply modus ponens closure to BX axiom schemata). This guarantees new valid formulas at higher complexity."#footnote[`docs/training/PIPELINE.md:744-762`, "Priority 1: Address Provability Ratio (Gate Blocker)."]
Complementary approaches noted in the same source: biased enumeration (a two-pass valid-template-plus-random-padding strategy) and restricting to smaller formula sizes.
The pipeline's second tier therefore comprises two components: the theorem-mining generator, sourcing valid formulas by axiom composition as above, and the wiring of `EnrichedCountermodel.lean` into the main export path, activating the richer corrective signal noted earlier.
`EnrichedCountermodel.lean` itself is implemented and tested; the generator and the wiring constitute the second tier's engineering scope.

== Shipped Machine-Readable Axiomatization

The axiomatization itself -- every axiom schema, inference rule, and derived-operator definition -- is shipped with this book as a machine-readable JSONL artifact at `typst/generated/machine-appendix.jsonl`, rendered as tables in the back-matter appendix (#link(<machine-appendix>)[_Appendix: The Machine-Readable Axiomatization_]).
The formula encoding is the same `Formula.toJson` tag schema emitted by `dataset_generator`, so the shipped axiomatization and the training datasets above share one encoding.
The artifact is regenerated commit-stamped via `scripts/typst-machine-appendix.sh` (which wraps `lake exe machine_appendix`, extracting each schema from the `Axiom` type index rather than transcribing it), and `scripts/typst-sync-check.sh` enforces its freshness against live Lean source.

== Operational Pointer

`docs/training/PIPELINE.md` holds the build/run commands and configuration knobs; this chapter is the canonical architecture narrative.
