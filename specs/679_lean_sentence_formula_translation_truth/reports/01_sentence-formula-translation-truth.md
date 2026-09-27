# Research Report: Sentence-to-Formula Translation and Its Truth-Preservation Theorem

- **Task**: 679 - Lean Sentence-to-Formula translation, proved truth-preserving
- **Started**: 2026-09-27T10:07:00Z
- **Completed**: 2026-09-27T11:05:00Z
- **Effort**: ~1 hour research; implementation estimated 1 working session (3 phases, ~450 new Lean lines plus tests and one tooling entry point)
- **Dependencies**: None
- **Sources/Inputs**:
  - Lean codebase (this repository)
    - `FormalSystem/Syntax/Formula.lean` — the six primitives and every derived-operator `def`
    - `FormalSystem/Semantics/Truth.lean` — `TruthAt` and the derived-operator characterization family
    - `FormalSystem/Semantics/TruthClauses.lean` — the abstract clause layer and its classical bridges
    - `FormalSystem/MinusLanguage/Translation.lean` — the closest existing precedent for a syntactic translation with push-through equations
    - `FormalSystem/PlusLanguage/PlusValidity.lean`, `FormalSystem/QuantLanguage/QuantTruth.lean` — the two existing truth-transfer bridge theorems (the proof template)
    - `FormalSystem/Metalogic/DiscreteNonCompactness.lean` — the only existing semantic characterization of `Formula.next`
    - `BimodalTools/DataExport.lean`, `BimodalTools/JsonParse.lean`, `lakefile.toml` — the wire format and executable conventions
  - Consuming repository (`~/Projects/ModelChecker`)
    - `code/src/model_checker/theory_lib/bimodal/semantic/formula.py` — `translate`, the six-constructor mirror, the wire codec
    - `code/src/model_checker/theory_lib/bimodal/operators.py` — all 9 primitive operators' `true_at` and all 8 defined operators' `derived_definition`
    - `code/src/model_checker/theory_lib/bimodal/tests/unit/test_formula.py` — the differential property tests and negative controls that currently stand in for S4
    - `code/src/model_checker/theory_lib/bimodal/docs/TRUST_PIPELINE.md` — Stage 1, the trust-base list, the "what remains" table
  - Executed experiments (this session): a compiling Lean proof-of-concept of the full type, translation, evaluation and agreement theorem; a byte-level cross-check of the elimination table against the consumer's own `translate` output
- **Artifacts**:
  - `specs/679_lean_sentence_formula_translation_truth/reports/01_sentence-formula-translation-truth.md`
- **Standards**: report-format.md, subagent-return.md

## Project Context

- **Upstream Dependencies**: `FormalSystem/Syntax/Formula.lean`, `FormalSystem/Semantics/Truth.lean`, `FormalSystem/Semantics/TruthClauses.lean`, `FormalSystem/Init.lean`
- **Downstream Dependents**: none inside `FormalSystem`; the deliverable's consumers are `BimodalTools` (a new export entry point) and the ModelChecker repository's own conformance test
- **Alternative Paths**: none needed — the whole result is reachable from the existing `TruthAt` characterization family
- **Potential Extensions**: extend the same `Sentence` layer to `⊡` (the stability modal) once that line lands; reuse the translation as the front end of a proof-producing `check_certificate`

## Executive Summary

- The deliverable is **feasible and small**. A proof-of-concept covering all 17 source operators — the inductive `Sentence` type, the translation into the six primitives, a native source evaluation, and the agreement theorem — was written and **compiles clean** against the current build (`lake env lean`, no errors, no warnings). Every case of the induction closes with `simp [Sat, tr, ih]`, two of them with a trailing `tauto`. No sorry, no axiom, no new mathematics.
- The reason it is small is that the hard content **already exists**: `FormalSystem/Semantics/Truth.lean` already proves a `@[simp, truth_norm]` characterization for every derived operator the translation produces (`neg_iff`, `and_iff`, `or_iff`, `top_true`, `diamond_iff`, `box_iff`, `future_iff`, `past_iff`, `untl_iff`, `snce_iff`). The task is to assemble these into one statement over an explicit source syntax, not to prove them.
- The elimination table was **verified empirically against the consumer**, not inferred: for all 16 operators that the consumer's pipeline can currently handle, the Lean image's `Formula.toJson` is byte-identical (modulo JSON whitespace) to `to_json(translate(sentence))` computed by running ModelChecker's real `Syntax`/`translate` path. The table is recorded in the Appendix.
- Two source operators do **not** push through to the "natural" Lean operator, and both would be silently wrong if written the obvious way. The consumer's `\rightarrow` is `¬A ∨ B`, so its image is `Formula.or (neg A) B` — **not** `Formula.imp A B`. The consumer's `\future` is `¬\Future¬`, so its image is `(allFuture (neg A)).neg` — **not** `Formula.someFuture A` (which is a top-level `untl`). This is the same phenomenon `FormalSystem/MinusLanguage/Translation.lean` already documents and proves for `tr_someFuture_ne`; the precedent and its proof idiom transfer directly.
- `\next`/`\prev` are the one genuine semantic subtlety. Their image `untl ⊥ φ` has no "successor" reading over an arbitrary `TemporalOrder`; unconditionally it means "φ at some `s` with the open interval `(t,s)` empty", i.e. `∃ s, t ⋖ s ∧ φ at s`. The consumer's intended meaning is literally `t + 1`. Both statements were proved in the PoC: the unconditional `CovBy` form, and the `Order.succ` form under `[SuccOrder F.Duration] [NoMaxOrder F.Duration]`. The plan must state both and say which one the interface claims.
- What the theorem buys over the consumer's passing property tests is specific and worth naming plainly (see Findings): the tests compare one hand-written Python evaluator against a second hand-written Python evaluator over 7 time points and a fixed corpus; the theorem compares the translation against `TruthAt` itself — the same definition every other soundness result in this repository is stated against — at every frame, model, history and time.

## Context & Scope

Researched: what it takes to define, in Lean, the elimination of the consuming repository's defined operators into this repository's six `Formula` primitives, and to prove that the source sentence's own evaluation agrees with `TruthAt` of its translation; and how to expose that so the consumer can check its own `translate` mechanically.

The dispatch's three revised premises were taken as given and confirmed against the sources:

- **Premise 1 (no argument-order mismatch)** — confirmed. `UntilOperator.true_at(self, guard_arg, event_arg, eval_point)` and `Untl(guard=..., event=...)` are guard-first, matching `Formula.untl`'s documented "Argument 1 is the guard, argument 2 is the event". `translate`'s `\Until`/`\Since` rules are positional identity. Nothing in the deliverable should be designed around a swap.
- **Premise 2 (both halves already have test coverage)** — confirmed. `tests/unit/test_formula.py` carries `TestTranslateTruthPreservation` (tense half, hand-built valuations) and `TestTranslateTruthPreservationBox` (box half, hand-built multi-lasso families), plus `TestNegativeControlsHaveTeeth` and `TestAsymmetryIsGenuine`, which are real non-vacuity controls. This task supplies a proof where a test stands.
- **Premise 3 (delegation infeasible)** — confirmed structurally. Every primitive operator's `true_at` in `operators.py` is `_bit(self.semantics, eval_point, <translated Formula>)`: the translation runs inside the truth predicate of every operator, not only at export. There is nothing to relocate into. The deliverable is an independent verified reference, and the report scopes it that way.

Out of scope: fixing anything in the consumer; the stability modal `⊡`; the A1/A2/A3 (ADEQ) chain.

## Findings

### The source language, exactly

The consumer declares 9 `syntactic.Operator` primitives and 8 `syntactic.DefinedOperator`s (`operators.py`'s `bimodal_operators` collection). `Sentence.update_types` expands the defined ones via `derived_definition` before `translate` ever sees them, so the consumer's `translate` only has 9 rules. A Lean `Sentence` type that is to be a *reference for the whole elimination* must carry all 17 as constructors, plus atoms — the defined operators are precisely the part the consumer's own `translate` never covers, and precisely the part the task names ("negation, conjunction, disjunction, the derived tense operators, next, prev").

### The elimination table is correct, and was checked by execution

Both halves of the consumer's pipeline (`derived_definition` expansion, then `translate`) were composed and run for one atomic instance of each operator, and the resulting `to_json` compared against `Formula.toJson` of the corresponding Lean term. All 16 runnable cases match byte-for-byte modulo JSON whitespace. The full table is in the Appendix; the two entries worth pulling forward:

- `\rightarrow A B ↦ Formula.or (Formula.neg (tr A)) (tr B)`. The consumer routes `\rightarrow` through `¬A ∨ B`, and `Formula.or φ ψ := φ.neg.imp ψ`, so the image is `((A → ⊥) → ⊥) → B` — a doubly negated antecedent. `Formula.imp (tr A) (tr B)` is semantically equivalent but a **different formula**, hence a different subformula closure, hence a different certificate label domain. Writing the obvious rule here would produce a reference that disagrees with the consumer on every conditional.
- `\future A ↦ (Formula.allFuture (Formula.neg (tr A))).neg`, not `Formula.someFuture (tr A)`. `someFuture φ = untl ⊤ φ` is a top-level `untl`; the consumer's image is a top-level `imp`. Same for `\past`.

No Lean primitive `imp` is ever the image of a source-level implication: `Formula.imp` appears in the range of the translation only inside the encodings of `neg`/`and`/`or`/`top` and of the two universal tenses. That is a useful invariant to state and, following `MinusLanguage/Translation.lean`'s `tr_ne_untl`, cheap to prove.

### The agreement theorem needs no new mathematics — verified by a compiling PoC

`FormalSystem/Semantics/Truth.lean` already carries, tagged `@[simp, truth_norm]`, exactly the per-operator characterizations the induction needs. The PoC (full text reconstructible from the Appendix's tactic notes; artifacts in the session scratchpad) defines an 18-constructor `Sentence`, `tr : Sentence → Formula`, a `Sat` evaluation mirroring the consumer's reference semantics clause for clause, and proves

```
theorem sat_iff (M : TaskModel F) (φ : Sentence) :
    ∀ (τ : WorldHistory F) (t : F.Duration), Sat M τ t φ ↔ TruthAt M τ t (tr φ)
```

by `induction φ`, `intro τ t` per case. Result: compiles with no diagnostics. Every case is `simp [Sat, tr, ih]`; `cond` and `bicond` need a trailing `tauto` (they are the two cases where the source clause is a `→`/`↔` and the image is a disjunction/conjunction, so the classical step is not a rewrite).

Two structural notes on the proof:

- Generalizing over `τ` *and* `t` is required, not optional: the `box`/`dia` cases need the hypothesis at a different history, and the four tense cases plus `untl`/`snce`/`next`/`prev` need it at a different time. `PlusLanguage/PlusValidity.lean`'s `plusTruthAt_ofFormula` and `QuantLanguage/QuantTruth.lean`'s `quantTruthAt_ofFormula` both do this; they are the template to imitate, including the `∀ τ t` after the colon rather than as binders.
- The existential-tense cases (`someFut`, `somePast`, `dia`) are the classical ones. They discharge through the already-proved `diamond_iff` / the `¬∀¬ ↔ ∃` step, so `simp` closes them; `TruthClauses.someFuture_iff_of_allFuture` exists but is stated for tense-primitive languages (its `AllFutureClause` instance), so it is *not* directly reusable for `Formula` — the `Formula` route is `Truth.future_iff` plus `neg_iff` under `simp`.

### `next`/`prev` are the one place where the order matters

`Formula.next φ := untl ⊥ φ`. Unconditionally, `TruthAt M τ t (next φ)` says: there is `s > t` with `φ` at `s` and nothing strictly between — that is exactly `∃ s, t ⋖ s ∧ TruthAt M τ s φ`. The repository's only existing characterization, `Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff`, assumes `[SuccOrder F.Duration] [NoMaxOrder F.Duration]` and its own module docstring says its "natural eventual home" is elsewhere. The consumer's reference evaluator uses `t + 1` outright, over `range(-3, 4)`, so its finite discrete domain cannot see the distinction.

Both forms were proved in the PoC and both compile:

- `next_iff_covBy` / `prev_iff_covBy` — unconditional, over any `TemporalOrder`.
- `next_iff_succ` — `TruthAt M τ t (next φ) ↔ TruthAt M τ (Order.succ t) φ` under `[SuccOrder F.Duration] [NoMaxOrder F.Duration]`, proved from the `CovBy` form via `Order.covBy_succ` and antisymmetry.

This is a live divergence risk rather than a bug: on a dense order `next φ` is unsatisfiable, so a reference that claimed the `succ` reading unconditionally would be false, and one that only ever states the `CovBy` reading would not visibly certify the consumer's actual `t + 1` intent. The plan should state the `CovBy` form as the theorem and the `succ` form as a named corollary, and say in the module docstring that the consumer's ℤ-time instantiation is what makes the corollary the operative one.

### What a theorem buys over the consumer's passing property tests

This is the question Revised Premise 2 asks to be answered plainly. Four specific things, each grounded in the tests as they actually stand:

1. **The comparison target changes.** `TestTranslateTruthPreservation*` compares `_eval_mc_ast` (a hand-written evaluator for the source AST) against `_eval_lean_formula` (a hand-written evaluator for the six primitives). Both live in the same test file. A shared misreading of a clause — e.g. both writing the `untl` witness as `s ≥ t` — makes the differential pass while both diverge from Lean's `TruthAt`. The theorem is stated against `TruthAt` itself, the definition `Metalogic/Soundness.lean` and `check_certificate`'s soundness chain are stated against, so agreement is with the trusted semantics rather than with a second transcription of it.
2. **Quantification over structures replaces a corpus.** The tests range over 11 + 9 hand-written ASTs, a generated corpus, 5 valuation patterns, 7 time points and a fixed family list. The theorem ranges over every `TaskFrame`, every `TaskModel`, every `WorldHistory`, every `Duration`, and every `Sentence`.
3. **It reaches the cases a finite ℤ-window cannot state.** The `next`/`prev` distinction above is the concrete instance: no test over `range(-3, 4)` can distinguish "at the successor" from "at some covering point", because on that domain they coincide.
4. **It covers `\top`, which the tests deliberately exclude.** `_BOX_TEST_CORPUS` filters out the `top` tag with an in-source comment citing a pre-existing `TopOperator` bug in `Sentence.update_types`'s extremal-operator branch. That bug reproduces: `Syntax(["\\top"], ...)` yields a node with `operator = \neg` and `arguments = None`, and `translate` raises `ValueError: not enough values to unpack (expected 1, got 0)`. **This is known and documented on the consumer side, not a new discovery** — but it is a real hole in S4 coverage, and it is one the Lean side can cover for free: `Sentence.top` gets a translation and a truth case unconditionally, and including `\top` in the conformance fixtures turns the consumer's excluded corpus row into a visible mechanical diff.

Conversely, the honest limits of the theorem: it certifies the *encoding*, not the consumer's Python implementation of it. Nothing about `translate`'s memoization, its `WeakKeyDictionary` identity keying, or `update_types`'s expansion is inside the theorem's scope. Only the conformance fixture channel below connects the theorem to the running code.

### The box clause coincides with the consumer's only modulo shift-closure

`TruthAt`'s box clause is `∀ σ : WorldHistory F, TruthAt M σ t φ` — all histories, the *same* time. The consumer's reference evaluators (`_eval_mc_ast`'s and `_eval_lean_formula`'s `box` cases) quantify over every lasso **and every position**, which is `□△φ`, characterized here by `Truth.box_always_iff`. The two coincide because the certificate framework's `H_F` is closed under time shift (`Semantics/ShiftSet.lean`, `Semantics/TruthTransport.lean`'s `timeShift_preserves_truth`, and `NecessityOperator`'s own docstring citing `ADEQUACY.md` Corollary 2.2), but they are not the same clause. The Lean theorem should use `TruthAt`'s own box clause and the module docstring should record this, so a future reader does not "fix" the Lean side to match a Python evaluator that is only extensionally equivalent under a frame property.

### Where the code goes, and how the interface is coordinated

- **Module placement.** The repository's established shape for "another language plus its translation into `Formula`" is a directory: `MinusLanguage/` has `Formula.lean`, `MinusTruth.lean`, `Translation.lean` and a `README.md`; `PlusLanguage/`, `StarLanguage/`, `QuantLanguage/`, `OpenLanguage/`, `HybridLanguage/` follow suit. Following that precedent: a new `FormalSystem/SourceLanguage/` (name to be fixed in planning) with `Sentence.lean` (type + translation + push-through equations), `SentenceTruth.lean` (the evaluation + the agreement theorem + the `next`/`prev` corollaries), and `README.md`; plus a directory aggregator `FormalSystem/SourceLanguage.lean` and the corresponding entries in the flat `FormalSystem.lean` aggregator. Every module must transitively import `FormalSystem.Init` (`scripts/CheckInitImportsMain.lean`, `lake exe checkInitImports` enforces this).
- **Mechanical cross-check channel.** The wire format already exists and is already a documented fixed contract: `Formula.toJson` (`BimodalTools/DataExport.lean`) and `pFormula` (`BimodalTools/JsonParse.lean`), tags `atom`/`bot`/`imp`/`box`/`untl`/`snce` with `untl`/`snce` carrying **named** `event`/`guard` fields (which is why the wire is order-free even though the constructor is not). The natural deliverable is a `Sentence`-side extension of the same codec plus a small `lean_exe` (a `translate_sentence` reading source-sentence JSON on stdin and emitting translated-formula JSON), mirroring `check_certificate`'s one-line-in/one-line-out convention in `lakefile.toml`. The consumer then asserts `to_json(translate(s))` equals the Lean binary's output for a shared fixture list. Comparison must be on parsed JSON, not bytes: `Formula.toJson` emits `", "`/`": "` separators, which `json.dumps`'s defaults happen to match but which nothing guarantees.
- **Fixture list.** Should include, at minimum: one atomic instance of each of the 17 operators (the Appendix table is exactly this list, and its Lean side is already computed); the `\top` case (currently excluded consumer-side); one asymmetric `\Until`/`\Since` instance whose operand swap changes meaning, so a future regression to event-first fails the fixture rather than passing silently; and one nested `\future`/`\Future` pair, since those are the two that do not push through.

## Decisions

- Model the source language as **one 18-constructor inductive** carrying all 17 operators plus atoms, rather than composing two translations (defined→primitive, primitive→`Formula`). Rationale: the consumer's `derived_definition` expansion is what has the live `\top` defect, so a reference that assumes it has already run would cover less than the task asks. A two-stage variant is recoverable later as a factorization theorem if wanted.
- State the agreement theorem against `TruthAt` directly, in the shape `∀ τ t, Sat … ↔ TruthAt …` after the colon, following `plusTruthAt_ofFormula` / `quantTruthAt_ofFormula`. Do not introduce a `TruthEnv`/`*Clauses` instance for `Sentence`: the abstract clause layer is built for languages whose primitives are the shared five, and `Sentence`'s 17 constructors are not that shape. The instance machinery would cost more than the `simp` proof it replaces.
- State `next`/`prev` in the unconditional `CovBy` form as the theorem, with the `Order.succ` form as a corollary under `[SuccOrder] [NoMaxOrder]`. Do not assume discreteness globally.
- Mirror the consumer's `\rightarrow` as `or (neg A) B` and `\future`/`\past` as the double-negated universal tense, and record both as deliberate with a `≠` proof in the `MinusLanguage/Translation.lean` idiom, so a later "simplification" to `Formula.imp` / `Formula.someFuture` fails a test rather than silently changing the closure.
- Deliver the mechanical interface as a `lean_exe` over the existing JSON tag vocabulary, not a new format.
- Zero-debt: no `sorry`, no new axiom. The PoC establishes this is achievable; nothing in the plan should carry a deferral.

## Recommendations

Prioritized, each sized to one agent run per `--hard` H8:

1. **Phase 1 — `FormalSystem/SourceLanguage/Sentence.lean`**: the inductive type (18 constructors, guard-first `untl`/`snce`, docstrings naming each consumer surface name), `tr`, the `rfl` push-through equations for the operators that do commute, the two deliberate `≠` results for `\rightarrow` and `\future`/`\past`, and `tr` injectivity. ~200 lines. Verification: `lake build FormalSystem.SourceLanguage.Sentence` green, plus `#guard` rows pinning `tr` on the Appendix's fixture list.
2. **Phase 2 — `FormalSystem/SourceLanguage/SentenceTruth.lean`**: `Sat`, `sat_iff`, and the `next`/`prev` `CovBy` and `succ` results. ~180 lines, proof route already validated. Verification: build green; `lake exe checkInitImports` clean; `#print axioms` on `sat_iff` showing only the standard three.
3. **Phase 3 — the conformance channel**: `Sentence` JSON codec beside `Formula`'s in `BimodalTools`, a `translate_sentence` `lean_exe` in `lakefile.toml`, the fixture list committed as a data file, and a `Tests/BimodalTest/…` round-trip test. Verification: the executable reproduces the Appendix table; fixtures parse back through `pFormula`.
4. **Hand-off note (not a phase)**: the consumer-side assertion belongs in the ModelChecker repository and must not be written from here. The report's Appendix table plus the fixture file is what that work consumes.

## Risks & Mitigations

- **Risk**: the Lean translation drifts from the consumer's as the consumer evolves, and the theorem then certifies the wrong encoding. **Mitigation**: the Phase 3 fixture channel is the only defense that does not rely on reading; make it a committed data file compared by both sides, and say so in both module docstrings.
- **Risk**: a future reader "simplifies" `\rightarrow`'s image to `Formula.imp`. **Mitigation**: the `≠` result plus a `#guard` on the fixture row; both fail loudly.
- **Risk**: the `succ` corollary gets promoted to the main statement, making the module silently false on dense orders. **Mitigation**: keep the `CovBy` form as the theorem and put the reason in the docstring, citing that `next φ` is unsatisfiable on a dense carrier (`Metalogic/DedekindNonCompactness.lean` already records this).
- **Risk**: over-claiming in the module docstring — writing that this discharges S4, or that the consumer may now delete its obligation. **Mitigation**: Revised Premise 3 is settled; the docstring should say "independent verified reference for the consumer to validate against", and the consumer's `TRUST_PIPELINE.md` row stays.
- **Risk**: the box-clause difference (same-time vs. all-times) is mistaken for a defect. **Mitigation**: the docstring note and the `box_always_iff` / shift-closure citation recorded in Findings.
- **Risk (process)**: three sibling research dispatches (677, 680, 681) share this working tree with no declared `file_scope`. **Mitigation**: nothing was written outside this task's own `specs/679_…` directory during research; implementation should re-read before editing and stage only its own files, per the dispatch's concurrency note.

## Tactic Survey Results

Measured by compiling the proof-of-concept, not estimated. `lean_multi_attempt` was not used; whole-file `lake env lean` runs gave decisive answers faster.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `sat_iff`, atom / bot cases | `exact Iff.rfl` | success | definitional |
| `sat_iff`, neg / wedge / vee / box / allFut / allPast / untl / snce / top / dia / someFut / somePast / next / prev cases | `simp [Sat, tr, ih]` | success | the `@[simp, truth_norm]` family in `Semantics/Truth.lean` (`neg_iff`, `and_iff`, `or_iff`, `top_true`, `diamond_iff`, `box_iff`, `future_iff`, `past_iff`, `untl_iff`, `snce_iff`) |
| `sat_iff`, cond / bicond cases | `simp [Sat, tr, ih]` alone | insufficient | leaves a propositional goal |
| `sat_iff`, cond / bicond cases | `simp [Sat, tr, ih]; tauto` | success | classical propositional closure |
| `next_iff_covBy` / `prev_iff_covBy` | `simp only [Formula.next, Truth.untl_iff, Truth.bot_false]` then `constructor` + `rintro`/`exact` | success | unfolds to the `CovBy` conjunction directly; `CovBy` is an `And`, so no `CovBy.*` API needed |
| `next_iff_succ` | `rw [next_iff_covBy]` then `Order.covBy_succ` + `le_antisymm`/`not_lt` | success | `[SuccOrder F.Duration] [NoMaxOrder F.Duration]` |
| `next_iff_succ` | `(Order.covBy_succ t).unique hcov` | fail | `CovBy` is an `And` here, so `And.unique` does not exist; use the two `not_lt` projections instead |
| whole `sat_iff` induction without `generalizing`/`∀ τ t` after the colon | — | not attempted | ruled out on inspection: box needs a different history, the tense cases a different time; both existing bridge theorems generalize |

## Context Extension Recommendations

- **Topic**: the cross-repository translation contract (source `Sentence` AST, the 17-operator elimination table, the JSON fixture channel).
- **Gap**: `BimodalTools/README.md` documents the `Formula` wire format as a fixed external contract, but there is no context file recording the *source-side* operator surface names, their elimination images, or the fact that `\rightarrow` and `\future`/`\past` do not push through. That table currently exists only inside the consumer's Python docstrings and in this report.
- **Recommendation**: after implementation, add `.claude/context/project/lean4/domain/sentence-translation-contract.md` (source store first, per the source-store/deploy boundary rule) carrying the Appendix table, the two non-push-through facts, the `next`/`prev` order caveat, and the box same-time-vs-all-times note. It is the thing a future dispatch on either side of the boundary will need and cannot currently find.

## Appendix

### The elimination table, verified by execution

Each row was produced by running the consumer's real pipeline (`Syntax([surface], [], bimodal_operators).premises[0]`, then `translate`, then `to_json`) and the Lean term's `Formula.toJson`, and comparing. All rows below matched byte-for-byte modulo JSON whitespace. `A`, `B` abbreviate `tr` of the corresponding sub-sentence.

| Consumer surface | Kind | Lean image |
|---|---|---|
| `\bot` | primitive | `Formula.bot` |
| `p` (sentence letter) | atom | `Formula.atom a` (base name only; fresh-indexed atoms are rejected at the wire, both sides) |
| `\neg A` | primitive | `(tr A).neg` |
| `\wedge A B` | primitive | `(tr A).and (tr B)` |
| `\vee A B` | primitive | `(tr A).or (tr B)` |
| `\Box A` | primitive | `(tr A).box` |
| `\Future A` (G) | primitive | `(tr A).allFuture` |
| `\Past A` (H) | primitive | `(tr A).allPast` |
| `\Until g e` | primitive | `Formula.untl (tr g) (tr e)` — positional identity, guard first |
| `\Since g e` | primitive | `Formula.snce (tr g) (tr e)` — positional identity, guard first |
| `\rightarrow A B` | defined | `((tr A).neg).or (tr B)` — **not** `Formula.imp` |
| `\leftrightarrow A B` | defined | `(((tr A).neg).or (tr B)).and (((tr B).neg).or (tr A))` |
| `\top` | defined | `Formula.bot.neg` (= `Formula.top`) — consumer path currently raises; see Findings |
| `\Diamond A` | defined | `(tr A).diamond` |
| `\future A` (F) | defined | `((tr A).neg.allFuture).neg` — **not** `Formula.someFuture` |
| `\past A` (P) | defined | `((tr A).neg.allPast).neg` — **not** `Formula.somePast` |
| `\next A` | defined | `Formula.next (tr A)` (= `Formula.untl Formula.bot (tr A)`) |
| `\prev A` | defined | `Formula.prev (tr A)` (= `Formula.snce Formula.bot (tr A)`) |

### The source evaluation clauses, as the consumer's reference evaluator writes them

Taken from `_eval_mc_ast` (`tests/unit/test_formula.py`), which is the consumer's own statement of the intended meaning of each operator, and which the Lean `Sat` should mirror clause for clause — with two deliberate departures recorded in Findings: `box` uses `TruthAt`'s same-time quantifier rather than the evaluator's all-positions one, and `next`/`prev` use `CovBy` rather than `t ± 1`.

### Commands used

- `lake env lean <file>` on three scratch files (the agreement PoC; the `next`/`prev` characterizations; the `toJson` table) — all clean.
- The consumer-side table was produced with `python3` against `~/Projects/ModelChecker/code/src` on `PYTHONPATH`; no consumer file was modified.

### References

- `FormalSystem/MinusLanguage/Translation.lean` — the "existential operators do NOT push through" section and `tr_someFuture_ne`; the precedent this deliverable's two `≠` results follow.
- `FormalSystem/PlusLanguage/PlusValidity.lean` `plusTruthAt_ofFormula`; `FormalSystem/QuantLanguage/QuantTruth.lean` `quantTruthAt_ofFormula` — the truth-transfer bridge template.
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` `truthAt_next_iff` — the existing (discreteness-assuming) `next` characterization, whose docstring already flags that its home is elsewhere.
- `~/Projects/ModelChecker/.../docs/TRUST_PIPELINE.md` Stage 1 and "What remains" — the obligation this task answers, and the row that stays.
