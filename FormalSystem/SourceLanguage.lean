/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.SourceLanguage.Sentence
import FormalSystem.SourceLanguage.SentenceTruth

/-!
# `FormalSystem.SourceLanguage` — the source sentence language and its verified elimination

This component is a **reference for a translation**, not a new logic. The companion ModelChecker
repository states an argument in a source language with a deliberately redundant operator set —
nine primitive operators and eight defined ones — and eliminates the defined ones into the six
primitives of `FormalSystem/Syntax/Formula.lean` before anything else in its pipeline runs. Every
later stage (encoder, solver, decoder, re-checker) consumes the *translated* formula, so the
elimination sits inside that pipeline's trust base while being covered by no theorem: a defect in it
means every downstream stage rigorously certifies a countermodel to a different argument than the
one that was written, and a round trip between two consumers of the translated formula cannot
detect it, because both read the same already-translated formula.

This component supplies the missing theorem. `Sentence` is the source AST with all seventeen
operators plus atoms; `tr` is the elimination; `Sat` is a native source-side truth evaluation
mirroring the source repository's own reference semantics clause for clause; and `sat_iff` proves
that the two agree at every frame, model, history and time.

## Modules

- `SourceLanguage.Sentence` — `Sentence` (18 constructors), `tr : Sentence → Formula`, the twelve
  push-through equations, the three deliberate `≠` results (`tr_cond_ne`, `tr_someFut_ne`,
  `tr_somePast_ne`), and `tr_not_injective`

## Semantic modules

- `SourceLanguage.SentenceTruth` — `Sat`, the native source-side evaluation; `sat_iff`, the
  agreement theorem against `Semantics.TruthAt` itself; and the `next`/`prev` characterizations
  `next_iff_covBy`, `prev_iff_covBy` (unconditional) with `next_iff_succ`, `prev_iff_pred` as
  corollaries on a discrete carrier

## What this component does and does not certify

It certifies the **encoding**: that the seventeen-operator source language, evaluated natively,
agrees with `TruthAt` of its six-primitive image. It is an independent verified reference the
source repository can validate its own implementation against — replacing agreement-with-itself by
agreement-with-a-theorem.

It does **not** certify that repository's implementation of the encoding. Nothing about its
memoization, its identity-keyed caches or its defined-operator expansion pass is inside the
theorem's scope; only the conformance channel of `BimodalTools/README.md` connects the theorem to
running code. Nor does this component discharge that repository's own verification obligation for
its translation, or license removing it: the obligation is an implementation obligation and stays
where it is.

## Module Invariant

**Syntax before semantics within this directory**, exactly as in the sibling language components.
`Sentence.lean` imports nothing from `FormalSystem/Semantics/`; `SentenceTruth.lean` beside it
does, and that edge is what gives the source language its meaning. Checkable by
`grep -rln 'import FormalSystem.Semantics' FormalSystem/SourceLanguage/`, whose only match must be
`SentenceTruth.lean`. `scripts/check-metalogic-cycles.sh` enforces it, reading each file's layer
from the per-file table in `scripts/measure-refactor-partitions.py`; **a new file in this directory
needs a row there.**

## References

* `FormalSystem/MinusLanguage/Translation.lean` — the "existential operators do NOT push through"
  precedent and the `≠` idiom this component follows
* `FormalSystem/PlusLanguage/PlusValidity.lean` `plusTruthAt_ofFormula`,
  `FormalSystem/QuantLanguage/QuantTruth.lean` `quantTruthAt_ofFormula` — the truth-transfer
  bridge template `sat_iff` follows
* `BimodalTools/SentenceExport.lean` and `Tests/fixtures/sentence-translation-fixtures.jsonl` — the
  mechanical conformance channel
* `FormalSystem/SourceLanguage/README.md` — the elimination table and the per-file inventory

## Tags

source-language · translation · elimination · truth-preservation · conformance
-/
