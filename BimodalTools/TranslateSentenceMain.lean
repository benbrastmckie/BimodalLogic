/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.SentenceExport

/-!
# Source-sentence translation: the executable root

The root of `lake exe translate_sentence`: `main`, and nothing else. It reads one source-sentence
JSON object on stdin and prints one translated-formula JSON object on stdout. The codec and the
translation are `BimodalTools.SentenceExport` in `BimodalTools/SentenceExport.lean`; the wire schema
is in `BimodalTools/README.md`, beside the `Formula` wire format and the tableau bridge protocol.

The split exists because an executable root declares a root-namespace `main`, and two of those
cannot share one environment — so a test module could not import the codec if the logic lived here.
This mirrors the `CheckCertificateMain` / `CertificateImport` and `TableauBridgeMain` /
`TableauBridge` pairs.

## What a successful run means

The output is `Formula.toJson` of `FormalSystem.SourceLanguage.tr` applied to the parsed sentence,
and `FormalSystem/SourceLanguage/SentenceTruth.lean`'s `sat_iff` proves that translation preserves
truth at every frame, model, history and time. So this binary is a **verified reference
implementation of the elimination**, and a consumer that reproduces its output on
`data/sentence-translation-fixtures.jsonl` has agreement with a theorem rather than agreement with
itself.

It is not a certificate about the consumer's own code: nothing here inspects that code. And it does
not discharge the consumer's verification obligation for its own translation — that obligation is
about an implementation and stays where it is.

Comparison must be on **parsed JSON, not bytes**: the separator convention this emits is not a
promise.

## Usage

```bash
echo '{"tag": "cond", "left": {"tag": "atom", "name": "p"},
       "right": {"tag": "atom", "name": "q"}}' | lake exe translate_sentence
```
-/

/-- Main entry point for `translate_sentence`. Reads one source-sentence JSON object on stdin,
prints one translated-formula JSON line on stdout. Ignores command-line arguments. -/
def main (_args : List String) : IO Unit := do
  let stdin ← IO.getStdin
  let input ← stdin.readToEnd
  IO.println (BimodalTools.SentenceExport.translateSentenceLineToJson input)
