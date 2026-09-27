# SourceLanguage — the source sentence language and its verified elimination

This directory is a self-contained component at the library root. It is a **reference for a
translation**, not a new logic.

The companion ModelChecker repository states an argument in a source language whose operator set is
deliberately redundant: nine primitive operators and eight defined ones, the defined ones being
abbreviations its own expansion pass rewrites before anything else runs. Everything downstream of
that rewrite — encoder, solver, decoder, re-checker — consumes the six-primitive `Formula` of
`../Syntax/Formula.lean`. So the rewrite is a translation between two languages, and it sits inside
that pipeline's trust base: a defect in it means every later stage rigorously certifies a
countermodel to a *different* argument than the one that was written, and a round trip between two
consumers of the translated formula cannot detect it, because both read the same already-translated
formula.

```
A, B ::= pᵢ | ⊥ | ¬A | A ∧ B | A ∨ B | □A | GA | HA | U(g, e) | S(g, e)      -- primitive
       | A → B | A ↔ B | ⊤ | ◇A | FA | PA | ○A | ●A                          -- defined
```

`Sentence` carries all seventeen operators plus atoms; `tr` eliminates them into the six `Formula`
primitives; `Sat` is a native source-side evaluation; and `sat_iff` proves the two agree at every
frame, model, history and time.

## The elimination table

Every row was checked by execution against the source repository's own pipeline (surface syntax →
defined-operator expansion → translation → JSON) and against `Formula.toJson` of the Lean image.
`A`, `B`, `g`, `e` abbreviate `tr` of the corresponding sub-sentence. Each row is pinned
independently by a `#guard` in `../../Tests/BimodalTest/Syntax/SentenceTranslationTest.lean`.

| Source surface | `Sentence` | Kind | `Formula` image |
|---|---|---|---|
| `\bot` | `bot` | primitive | `Formula.bot` |
| `p` | `atom a` | atom | `Formula.atom a` (base name only) |
| `\neg A` | `neg A` | primitive | `(tr A).neg` |
| `\wedge A B` | `wedge A B` | primitive | `(tr A).and (tr B)` |
| `\vee A B` | `vee A B` | primitive | `(tr A).or (tr B)` |
| `\Box A` | `box A` | primitive | `(tr A).box` |
| `\Future A` (`G`) | `allFut A` | primitive | `(tr A).allFuture` |
| `\Past A` (`H`) | `allPast A` | primitive | `(tr A).allPast` |
| `\Until g e` | `untl g e` | primitive | `Formula.untl (tr g) (tr e)` — positional identity, guard first |
| `\Since g e` | `snce g e` | primitive | `Formula.snce (tr g) (tr e)` — positional identity, guard first |
| `\rightarrow A B` | `cond A B` | defined | `((tr A).neg).or (tr B)` — **not** `Formula.imp` |
| `\leftrightarrow A B` | `bicond A B` | defined | `(((tr A).neg).or (tr B)).and (((tr B).neg).or (tr A))` |
| `\top` | `top` | defined | `Formula.bot.neg` (`= Formula.top`) |
| `\Diamond A` | `dia A` | defined | `(tr A).diamond` |
| `\future A` (`F`) | `someFut A` | defined | `((tr A).neg.allFuture).neg` — **not** `Formula.someFuture` |
| `\past A` (`P`) | `somePast A` | defined | `((tr A).neg.allPast).neg` — **not** `Formula.somePast` |
| `\next A` | `next A` | defined | `Formula.next (tr A)` (`= Formula.untl Formula.bot (tr A)`) |
| `\prev A` | `prev A` | defined | `Formula.prev (tr A)` (`= Formula.snce Formula.bot (tr A)`) |

## Three rows would be silently wrong written the obvious way

- **`\rightarrow` is not `Formula.imp`.** The source repository routes it through `¬A ∨ B`, and
  `Formula.or φ ψ` is `φ.neg.imp ψ`, so the antecedent is doubly negated. `Formula.imp (tr A) (tr B)`
  is semantically equivalent and is a *different formula*, hence a different subformula closure,
  hence a different certificate label domain. `tr_cond_ne` records the inequality by proof.
- **`\future`/`\past` are not `Formula.someFuture`/`Formula.somePast`.** The source repository
  defines them as `¬G¬` and `¬H¬`, a top-level `imp`; the `Formula` abbreviations are a top-level
  `untl`/`snce`. `tr_someFut_ne` and `tr_somePast_ne` record this.

No `Formula.imp` in the range of `tr` is the image of a source-level implication: `imp` occurs there
only inside the encodings of `neg`, `and`, `or`, `top` and the two universal tenses.

## `tr` is lossy on purpose

`tr_not_injective` proves `tr` is not injective: each defined operator is eliminated onto the very
abbreviation it stands for, so `tr (cond A B) = tr (vee (neg A) B)`, `tr top = tr (neg bot)`,
`tr (dia A) = tr (neg (box (neg A)))`, and likewise for the existential tenses. Discarding what
distinguishes an abbreviation from its expansion is what an elimination *is*. The consequence for
the conformance channel is that comparison runs forward only — a translated `Formula` does not
determine its source `Sentence`, so no inverse pass is checkable against this reference.

## `next`/`prev`: the one place the order structure matters

`Formula.next φ` is `Formula.untl Formula.bot φ`, whose unconditional meaning is "`φ` at some `s`
with nothing strictly between `t` and `s`" — exactly `∃ s, t ⋖ s ∧ …`. That is the **theorem**
(`next_iff_covBy`, `prev_iff_covBy`), stated over any temporal order. The source repository's
reference evaluator uses `t + 1`, which is the `Order.succ` reading; that is a **corollary**
(`next_iff_succ`, `prev_iff_pred`) requiring `[SuccOrder]` and `[NoMaxOrder]`. Promoting the
corollary to the statement would make this component silently false on a dense carrier, where
`next φ` is unsatisfiable — see `../Metalogic/DedekindNonCompactness.lean`. The source repository's
integer-time instantiation is what makes the corollary the operative reading there.

## The box clause: same time here, all times there

`Semantics.TruthAt`'s box clause quantifies over every world history at the **same** time. The
source repository's reference evaluators quantify over every history *and every position*, which is
`□△φ` here (`Semantics.Truth.box_always_iff`). The two coincide because the certificate framework's
history family is closed under time shift (`../Semantics/ShiftSet.lean`,
`../Semantics/TruthTransport.lean`'s `timeShift_preserves_truth`), but they are not the same clause.
This component uses `TruthAt`'s own clause; a future reader must not "fix" the Lean side to match a
Python evaluator that is only extensionally equivalent under a frame property.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/SourceLanguage -->
| File | Lines | Description |
|------|------:|-------------|
| `Sentence.lean` | 321 | `Sentence` — the source AST, 18 constructors (nine primitive operators, eight defined, plus atoms), `untl`/`snce` guard-first; `tr : Sentence → Formula`, the elimination into L's six primitives; the twelve `rfl` push-through equations; `tr_cond_ne`, `tr_someFut_ne`, `tr_somePast_ne` — the three rows that deliberately do not push through; `tr_not_injective` — the elimination is lossy by construction |
| `SentenceTruth.lean` | 253 | `Sat` — the native source-side truth evaluation, 18 clauses, mirroring the source repository's own reference evaluator with two recorded departures (`TruthAt`'s same-time box clause; `⋖` rather than `t ± 1`); `sat_iff` — the agreement theorem against `TruthAt` itself, over every frame, model, history and time; `next_iff_covBy`/`prev_iff_covBy` — unconditional; `next_iff_succ`/`prev_iff_pred` — the discrete corollaries |
<!-- END GENERATED -->

The sibling aggregator is `../SourceLanguage.lean`. The library root, the repository-root
`FormalSystem.lean`, is generated by `lake exe mk_all --lib FormalSystem` and imports that
aggregator and every module in this directory directly.

## The conformance channel

The theorem certifies the *encoding*; it says nothing about any particular implementation of it.
What connects the two is a mechanical channel, documented in `../../BimodalTools/README.md`:

- `Sentence.toJson` / `pSentence` in `../../BimodalTools/SentenceExport.lean` — the source-side
  extension of the existing tag vocabulary, with `untl`/`snce` on **named** `guard`/`event` fields so
  the wire stays order-free even though the constructor is not.
- `lake exe translate_sentence` — one source-sentence JSON object on stdin, one translated-formula
  JSON object on stdout.
- `../../data/sentence-translation-fixtures.jsonl` — the shared fixture list. The source repository
  asserts its own translation reproduces the expected field of every line; this repository asserts
  the same in `../../Tests/BimodalToolsTest/SentenceCodecTest.lean`.

Comparison must be on **parsed JSON, not bytes**.

## Not formalized

| Claim | Status |
|---|---|
| That the source repository's implementation of the elimination is correct | **Not formalized, and not formalizable from here.** The theorem certifies the encoding; the conformance channel is the only link to running code |
| A proof system, soundness or completeness result for `Sentence` | **Not formalized.** The component is a translation reference; the logic lives on the `Formula` side |
| A `TruthEnv`/`*Clauses` instance for `Sentence` | **Not formalized, by design.** The abstract clause layer is built for languages whose primitives are the shared five; eighteen constructors are not that shape, and the instance machinery would cost more than the `simp` proof it replaces |
| Consolidation with `../Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff` | **Not done, deliberately.** The duplication is recorded in `SentenceTruth.lean`'s docstring; importing `Metalogic` from this layer would be an upward edge |
| The stability modal `⊡` and the source repository's other non-bimodal operator families | **Out of scope.** Only the bimodal operator collection is covered |

## Module Invariants

**Syntax before semantics within this directory**, exactly as in the sibling language components.
`Sentence.lean` imports nothing from `FormalSystem/Semantics/`; `SentenceTruth.lean` does. Every
file here has a layer in the `LANGUAGE_FILE_LAYERS` table of
`../../scripts/measure-refactor-partitions.py` — 0 for a syntax file, 1 for a semantic module — and
`bash scripts/check-metalogic-cycles.sh` fails if a layer-0 file of any language directory imports a
layer-1 file of any of them, or anything under `FormalSystem/Semantics/`. **A new file in this
directory needs a row in that table.**

## References

* `../MinusLanguage/Translation.lean` — the "existential operators do NOT push through" precedent
* `../PlusLanguage/PlusValidity.lean` `plusTruthAt_ofFormula`,
  `../QuantLanguage/QuantTruth.lean` `quantTruthAt_ofFormula` — the truth-transfer bridge template
* `../Semantics/Truth.lean` — `TruthAt` and the per-operator characterization family the agreement
  proof runs on
* `../../BimodalTools/README.md` — the wire format and the conformance-channel contract

---

*Last verified: 2026-09-27*
