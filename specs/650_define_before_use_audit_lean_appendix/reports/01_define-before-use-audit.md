# Research Report: Define-Before-Use Audit of the Lean Appendix

- **Task**: 650 - Define-before-use audit of the Lean appendix
- **Started**: 2026-09-29T00:00:00Z
- **Completed**: 2026-09-29T00:00:00Z
- **Effort**: ~3 hours
- **Dependencies**: 647, 648, 649 (all landed; verified in git history)
- **Sources/Inputs**:
  - `typst/chapters/ax-lean-appendix.typ` (1351 lines, the audited file)
  - `typst/template.typ` (the `lean-code()` environment and its fidelity policy)
  - `typst/sync-check-whitelist.txt`, `typst/SYNC-MAP.md`, `typst/README.md`
  - `FormalSystem/ProofSystem/Derivation.lean`, `Derivable.lean`, `Axioms.lean`
  - `FormalSystem/Syntax/Context.lean`, `FormalSystem/Semantics/Validity.lean`
  - `FormalSystem/Semantics/FrameClassValidity.lean`
  - Lean core `Init/Prelude.lean` at the pinned toolchain `leanprover/lean4:v4.33.0-rc1`
  - A scratch `lake env lean` run verifying eleven claims (see Appendix)
- **Artifacts**: `specs/650_define_before_use_audit_lean_appendix/reports/01_define-before-use-audit.md`
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- The audit is complete: a 140-row first-use ledger covers every notation, identifier, Lean
  keyword, syntactic glyph, tactic and presentation convention the appendix uses. 62 rows are
  clean, 30 are forward references, 44 are never introduced at all, and 4 seeded items do not
  reproduce.
- All three seeded KNOWN GAPS reproduce exactly as described. The `[fc]` bracket is never
  explained; the `FrameClass` partial order and `Axiom.minFrameClass` are used 689 and 1351 lines
  respectively before (or without) introduction; and the leading-dot shorthand plus the `Γ`/`φ`
  versus `G`/`p` variable switch are used without comment.
- Two gaps outrank the seeded ones in reader cost. `Context` is never revealed to be
  `List Formula`, which leaves `[]`, `∈` and `⊆` unreadable; and the validity turnstile `⊨` is
  used seven times without ever appearing in the notation table, while `Valid` is named once in
  passing at line 105 and never defined.
- One outright defect, not merely an omission: the appendix calls the leading dot `.Dense`
  "anonymous constructor notation" at line 651, then correctly calls `⟨"p", none⟩` the "anonymous
  constructor" at line 1213. Two different pieces of syntax carry one name. The leading dot is dot
  notation resolved against the expected type; `⟨ ⟩` is the anonymous constructor.
- Three author-written `TODO` comments already sit in the file at lines 286, 317 and 403. All
  three are define-before-use requests in substance and fall inside this task's scope. They are
  also `/fix-it`-visible tags in a deliverable file.
- Eleven Lean facts underpinning the recommended new prose were verified by compiling them with
  `lake env lean` against the current toolchain. Every one passed, so the recommended
  introductions can be written as stated without further checking.

## Context & Scope

The appendix is a from-basics Lean 4 primer, fourteen sections over 1351 lines, whose contract
(stated in its own header) is that every `#leansrc`-labelled block is verbatim live source up to
whitespace and every unlabelled block is a didactic example that compiles. Tasks 647, 648 and 649
built it, gave it a real appendix identity, and migrated its code blocks to `template.typ`'s
`lean-code()` environment. This audit is the improvement pass over the finished text.

Scope is deliberately narrow. The audit adds and reorders introductions, glosses and
back-references. It does not change what the appendix claims, does not widen its coverage, and
does not reintroduce appendix-local formatting in place of the `lean-code()` environment.

Method followed the dispatch exactly: a top-to-bottom walk recording first-use and introduction
lines for every item in the four named classes, then classification of each row, then verification
of every Lean fact against live non-Boneyard source before any of it was written down.

Baseline gate state, measured before any edit:

| Gate | Result |
|------|--------|
| `typst-element-lint.sh` on the appendix | PASS, 0 blocking, 0 warnings |
| Most recent SYNC-MAP entry for the appendix | 2026-09-17 addition, extended later |

## Findings

### The ledger: class (a), project notation

Verdict key: OK = introduced at or before first use; FWD = used before introduced (the number in
parentheses is the gap in lines); NONE = never introduced; N/A = seeded item that does not
reproduce.

| Item | First use | Introduced | Verdict |
|------|-----------|------------|---------|
| `Γ ⊢ φ` | 140 | 140 (table row) | OK |
| `⊢ φ` context-free | 140 | 149 | OK |
| `Γ ⊢[fc] φ` | 141 | none | NONE — seeded gap (i) |
| `⊢[fc] φ` context-free | 705 | 149 covers only context omission | NONE |
| `G \|-! p` | 142 | 142 (table row) | OK for the unfolding |
| the `!` mark in `\|-!` | 142 | none | NONE — seeded gap (i) |
| `G \|-![fc] p` | 143 | none | NONE |
| `⊨ φ` | 769 | none, and absent from the notation table | NONE |
| `Valid φ` | 105 | none | NONE |
| `ValidIn fc φ` | 1154 | none | NONE |
| `□` in `⊢ □p → p` | 169 | 923, one late mention | FWD (754) |
| `◇`, `▽`, `△`, `H`, `G` in the perpetuity2 comments | 706 | self-glossed inside the comment block | OK |
| mixing book notation and Lean in one line (`⊢ □p → p` at 169 against `⊢ p.box.imp p` at 173) | 169 | none | NONE |
| derived operators `neg` … `sometimes` | 173 | 221 | FWD (48) |
| `φ.reflectTime` | 259 | none (270 glosses the rule, not the operator) | NONE |

Seeded gap (i) is confirmed in full. The sentence at line 149 that follows the turnstile table
covers only omission of the context. Nothing in the file says what the brackets are, what may go
between them, that the bracket-free forms are exactly the `FrameClass.Base` instance, or what the
exclamation mark marks.

### The ledger: class (b), project identifiers

| Item | First use | Introduced | Verdict |
|------|-----------|------------|---------|
| `Formula` | 104 | 205-218 | OK (roadmap mention at 71 carries a pointer) |
| `DerivationTree` | 108 | 234-265 | FWD (126), but 108 carries an `@`-pointer |
| `Derivable` | 109 | 112-120 | OK |
| `Context` | 114 | none | NONE |
| `FrameClass` | 114 | 122-126 | OK — the seeded gap (ii) clarification is present and correct |
| tags `Base`/`Dense`/`ZTime`/`RTime` | 123 | 123 named, 860 ordered | partial |
| the `FrameClass` partial order and `≤` | 156 | 845-870 | FWD (689) — seeded gap (ii) |
| `Axiom` as a type | 174 | none (1056 counts its constructors in passing) | NONE |
| `Axiom.minFrameClass` | 156 | none; only ever called "the side condition" | NONE — seeded gap (ii) |
| `FrameClass.Sat` | 125 | 125 | OK — keep as written |
| `DerivationTree.axiom` | 174 | 178 | OK |
| `Axiom.modal_t` | 179 | 179 | OK |
| `DerivationTree.height` | 108 | 884 | FWD (776), both mentions in passing |
| `DerivationTree.lift` | 818 | 818 | OK |
| `Derivable.ofTree` | 191 | 191 | OK |
| `TemporalOrder` | 350 | 352-368 | OK |
| `TaskFrame.reflect`, `.Compositional`, `.Serial`, `.Saturation` | 393 | 424 glosses `reflect` only | partial |
| `TaskFrame` | 393 | 445-462 | FWD (52) |
| `F.Duration` | 374 | 460 | FWD (86) |
| `F.WorldState`, `F.TaskRel` | 391 | 460 | FWD (69) |
| `D.PositiveCone` | 392 | 423 | FWD (31), glossed on arrival |
| `PartialHistory` | 468 | 470-479 | OK |
| `WorldHistory` | 462 | 517-524 | FWD (55), glossed at 462 |
| `TaskModel` | 462 | 546-551 | FWD (84), glossed at 462 |
| `TruthAt` | 564 | 572-586 | OK, pointer at 564 |
| `Atom` | 275 | 277-283 | OK |
| `perpetuity1` | 728 | 741-746 | FWD (13), deliberate by the section's design |
| `contraposition` | 729 | 734-737 | OK |
| `SimpleCountermodel`, `Formula.next`, `Ultraproduct.Idx` | 1262, 1215, 1237 | same line | OK |
| `WeakCompleteness`, `StrongCompletenessBase` | 1149, 1228 | same line | OK |

The `FrameClass` clarification at lines 122-126 that seeded gap (ii) asks to KEEP is present,
accurate and well placed. It should survive this pass untouched. What is missing around it is the
rest of the apparatus: the tags are named but their order is not stated until section A.11, and
`Axiom.minFrameClass` is relied on at line 156 without ever being introduced as a function.

### The ledger: class (c), Lean surface syntax

| Item | First use | Introduced | Verdict |
|------|-----------|------------|---------|
| `_` placeholder | 174 | 178 | OK |
| `⟨ ⟩` anonymous constructor | 195 | 191 | OK, but re-explained at 1213 instead of back-referenced |
| leading dot `.Dense` / `.Base` | 153 | 649-652 | FWD (496) — seeded gap (iii) |
| `Γ`/`φ` versus `G`/`p` variable switch | 114 against 140 | none | NONE — seeded gap (iii) |
| dot/field notation `p.box.imp p` | 173 | 222 | FWD (49) |
| `h.minFrameClass`, `d.height`, `τ.state t` | 108 | 222 | FWD (114) |
| explicit binder `(x : T)` | 309 | table row only, no prose | partial |
| implicit binder `{x : T}` | 310 | 310, 330-332 | OK |
| instance binder `[C α]` | 311 | 311, 334-336 | OK |
| several names under one binder `(φ ψ : Formula)` | 247 | none | NONE |
| instance-bracket structure fields | 356 | 349 | OK |
| `:=` as definition | 115 | none | NONE |
| `:=` as a binder default | 1270 | 1266, 1276 | OK |
| `\|` in a constructor list | 210 | 203 | OK |
| `\|` as a match arm | 576 | 570 | OK, but the two roles are never distinguished |
| `=>` | 576 | 570 | OK |
| `match … with` | 850 | none | NONE |
| `∀` | 395 | none | NONE |
| `∃`, `∧`, `↔` | 395, 162, 434 | 162 for `∧`, 786 for `↔` | partial |
| `¬` | 707 | none | NONE |
| `→` as function type versus object implication | 152 | none | NONE |
| `Type` | 104 | 101-105 | OK |
| `Prop` | 105 | 101-105 | OK |
| `Type _` universe placeholder | 521 | none | NONE |
| `def` | 114 | 725, 913 | FWD (611) |
| `theorem` | 165 | 165, 773 | OK |
| `example` as a Lean keyword | 186 | 78 covers the convention, not the keyword | partial |
| `inductive` | 209 | 203 | OK |
| `structure` | 279 | 274 | OK |
| `class` | 334 | 334 | OK |
| `instance` as a declaration keyword | 361 | none | NONE |
| `abbrev` | 526 | none | NONE |
| `namespace` | 735 | 917 | FWD (182) |
| `open` | 918 | 918 | OK |
| `@[reducible]` | 451 | 460 | OK |
| `@[simp]` | 540 | none | NONE |
| `attribute [instance]` | 364 | 375 | OK |
| `deriving` | 216 | 336 | FWD (120) |
| `Repr`/`DecidableEq`/`BEq`/`Hashable`/`Countable` individually | 216 | 336 names them as instances only | partial |
| `termination_by` | 592 | 592 | OK |
| `noncomputable` | — | — | N/A, does not occur |
| `fun` | — | — | N/A, does not occur |
| `@` explicit-argument prefix | 332 | 332 | OK |
| `↑` coercion arrow | 429 | none (374 introduces `CoeSort`, not the glyph) | NONE |
| `//` subtype bar | 522 | 516 | OK — the model row for how this should read |
| `Set` and `{w \| … }` set-builder | 559 | none | NONE |
| `String`, `Nat`, `Option Nat`, `none` | 280 | none | NONE |
| `Bool` | 553 | none | NONE |
| `Nonempty` | 116 | none (191 names it without defining it) | NONE |
| `True` / `False` | 852, 577 | none | NONE |
| `\|y\|` absolute value on a duration | 395 | none | NONE |
| `0 < x` numerals on a `TemporalOrder` | 395 | none | NONE |
| subscripted names `fc₁ fc₂` | 822 | none | NONE, trivial |
| `by` | 663 | 657 | OK |
| `modal_search` | 664 | 670 | OK |
| `apply_axiom` | 671 | 671 | OK |
| `propDecide` | 672 | 672 | OK |
| `intro` | 687 | 687 | OK, never used in a snippet |
| `exact` | 680 | 688 | FWD (8) |
| `apply` | 671 | 689 | FWD (18) |
| `simp` | 120 | 690 | FWD (570) |
| `decide` tactic | 866 | 862 | OK |
| `decide` tactic against `Decidability.decide` the project `def` | 1270 | none | NONE, a name collision never flagged |
| `trivial` | 174 | none | NONE |
| `case` tactic | 680 | none | NONE |
| `refine ?_` | 671 | none | NONE |
| `rfl` | 1154 | none | NONE |
| `inferInstance` | 340 | 336 | OK |
| `le_trans` | 825 | 842 | OK |
| `#check` | 332 | 1311 | FWD (979) |
| `#print axioms` | 811 | 1312 | FWD (501) |
| `sorry` / `sorryAx` | 1328 | 1328 | OK |
| `Classical.em` | 1337 | 1337 | OK |
| `variable` | 922 | 922 | OK |

### The ledger: class (d), presentation conventions

| Item | First use | Introduced | Verdict |
|------|-----------|------------|---------|
| the `>` source-label line | 112 | 76-78 | OK |
| excerpt versus didactic example | 112, 171 | 76-78 | OK |
| docstring omission | 112 | 77, 920-921 | OK |
| line re-breaking to the column budget | 112 | 77 | OK |
| `lean-code()` as the single code environment (task 649) | 112 | 43-45 in a Typst comment, 76 in rendered prose | OK for the reader |
| module-qualified label spelling | 112 | 77 | OK |
| the `--` author comment lines inside an excerpt | 706 | 731 | OK |

Class (d) is the healthiest of the four. Every reader-facing presentation convention that task 649
settled is introduced at lines 76-78, before the first block that uses it at line 112. This part of
the appendix needs no repair.

### The terminology collision at line 651

Line 651 reads: "The leading dot is *anonymous constructor notation*: Lean already knows from the
declared type which inductive is being matched, so the type's name may be dropped." Line 1213
reads: "the *anonymous constructor* `⟨"p", none⟩`, which is `Atom`'s two fields written without
naming the structure."

These are two different pieces of syntax under one name. In Lean 4 the anonymous constructor is
`⟨ ⟩`, which builds a value of a structure or single-constructor inductive from its fields. The
leading dot is dot notation resolved against the expected type, which lets a constructor or
namespaced function be written without its namespace prefix. The explanation at 651 is otherwise
correct about the mechanism; only the name is wrong, and the wrong name collides with the correct
use 562 lines later. This is the one row in the ledger that is a defect rather than an omission,
and fixing it is a rename, not a claim change.

### The three author TODO comments

| Lines | Subject | Relation to this audit |
|-------|---------|------------------------|
| 286-292 | the `Atom` structure excerpt: `structure … where`, field lines, `String`/`Nat`/`Option Nat`, construction and field access, and the `deriving` clause handler by handler | In scope. Supplies ledger rows for `String`, `Nat`, `Option Nat`, `deriving` and the five derived classes, all of which the ledger independently marks NONE or FWD. |
| 317-328 | the three binders: uneven treatment, missing explicit-binder prose, and the variants `(φ ψ : Formula)`, `⦃x : T⦄`, `[inst : C α]`, `variable`, auto-bound implicits | In scope. Matches the ledger's partial verdict on the explicit binder and its NONE on several-names-under-one-binder. |
| 403-418 | the `worldNonempty` field: what `Nonempty α` is, proof irrelevance, the contrast with `Inhabited`, what the brackets and the `attribute` line each add, and the other proof fields of `FrameOver` | In scope. Matches the ledger's NONE on `Nonempty` and its partial on the `comp`/`serial`/`limit`/`saturation` fields. |

These were written by the repository author in the task-648 commit as markers for a later pass.
Their content is exactly "state the syntax before relying on it", which is this task's remit. They
should be resolved by this task rather than carried forward, and resolving them removes three
`TODO` tags from a deliverable file.

Their backticked spans are already whitelisted in `typst/sync-check-whitelist.txt` under a category
headed "editorial review TODO comments (`//`-prefixed Typst line comments, not rendered prose)".
Converting them to rendered prose keeps Check 1 of `scripts/typst-sync-check.sh` passing, because
the spans themselves stay whitelisted, but the category's header comment becomes factually wrong
and must be reworded to describe them as rendered generic-syntax illustrations.

### Lean facts verified

Every fact the recommended prose would assert was checked against live non-Boneyard source and,
where it is a claim about definitional equality, compiled. Results are in the Appendix. The
material findings:

- All eight turnstile notations are declared in `FormalSystem/ProofSystem/Derivation.lean` lines
  346-361 and `FormalSystem/ProofSystem/Derivable.lean` lines 77-92. They are project-defined
  `notation` commands, not built-in Lean syntax, so the brackets are literal tokens.
- The bracket-free forms are exactly the `FrameClass.Base` instances. `Γ ⊢ φ` and `Γ ⊢[.Base] φ`
  are the same type, confirmed by `rfl`.
- `Context` is `abbrev Context := List Formula` at `FormalSystem/Syntax/Context.lean` line 60.
- `⊨ φ` is `Valid φ` at `FormalSystem/Semantics/Validity.lean` line 391, and `Valid φ` is by
  definition `ValidIn FrameClass.Base φ` at line 385. There is also a two-place
  `Γ ⊨ φ` for `SemanticConsequence` at line 122, which the appendix never uses.
- `Axiom : Formula → Type` at `FormalSystem/ProofSystem/Axioms.lean` line 152, so `Axiom φ` is the
  type of witnesses that `φ` instantiates an axiom schema.
- `Axiom.minFrameClass {φ : Formula} : Axiom φ → FrameClass` at the same file line 665, defined by
  a match sending `density`, `dense_indicator` to `.Dense`, `prior_UZ`, `z1` to `.ZTime`,
  `prior_U_gap`, `sep` to `.RTime`, and everything else to `.Base`.
- `FrameClass` is declared at `Axioms.lean` line 550, with `LE` at 557, `DecidableRel` at 566 and
  `PartialOrder` at 569, which is what makes the appendix's `by decide` examples and its appeal to
  Mathlib's `le_trans` correct as written.
- `Nonempty` is `class inductive Nonempty (α : Sort u) : Prop where | intro (val : α) : Nonempty α`
  at `Init/Prelude.lean` line 792 of the pinned toolchain, and `F.worldNonempty.some` is genuinely
  used in live source at `Semantics/Validity.lean` lines 290 and 303, `Semantics/Correspondence/Rigidity.lean`
  line 296 and `Semantics/ConvexTruth.lean` lines 355-356. The TODO at line 403 is accurate.

## Decisions

- Treat the three author TODO comments as in-scope ledger rows rather than as out-of-scope
  content, because their substance is define-before-use and the whitelist category that shields
  them was written to be temporary.
- Prefer a one-clause gloss at first use plus a pointer to the full treatment over relocating a
  whole section, in every case where the full treatment is long and sits in a section that earns
  its position. This applies to the `FrameClass` order, `#check`, `#print axioms`, `simp` and
  `deriving`.
- Prefer relocation over a gloss only where the introduction is short and its current position is
  arbitrary. This applies to the leading-dot shorthand and to the `Context` definition.
- Do not touch lines 122-126. The `FrameClass` clarification that seeded gap (ii) asks to keep is
  correct and well placed.
- Close `noncomputable` and `fun` with a one-line note rather than introducing them: neither glyph
  occurs anywhere in the appendix, so there is nothing to introduce.
- Treat the line 651 naming error as a correction rather than a scope widening. Renaming a piece of
  syntax to its actual name does not change what the appendix claims.

## Recommendations

Ordered by reader cost. Each names the line where the introduction belongs.

1. **Extend the notation treatment after the turnstile table, at lines 140-149.** This is the
   single highest-value change and it closes seeded gap (i) plus four other NONE rows. Add two rows
   to the table for `⊨ φ` unfolding to `Valid φ` in `Prop`, and state in the prose that follows:
   the brackets are literal tokens of project-defined notation declared in `Derivation.lean` and
   `Derivable.lean`, not built-in Lean syntax; what goes between them is any term of type
   `FrameClass`, either a concrete tag such as `.Dense`, giving a derivation in that one system, or
   a bound variable `fc`, giving a statement holding in all four at once; this is the Lean spelling
   of the subscripted turnstile of the paper's TM_d, TM_z and TM_r; the bracket-free forms are
   exactly the `FrameClass.Base` instances, so `Γ ⊢ φ` and `Γ ⊢[.Base] φ` are the same type; and
   the exclamation mark marks the `Prop`-valued `Derivable` twin. Keep the existing sentence about
   omitting the context.

2. **Introduce `Context` at line 114, where it first appears.** One clause: `Context` is an
   `abbrev` for `List Formula`, which is why the empty context is written `[]`, why the
   `assumption` rule's hypothesis is `φ ∈ Γ`, and why `weakening` reads `Γ ⊆ Δ`. This closes the
   `Context`, `[]`, `∈` and `⊆` rows at once, all with one sentence, and it has to precede the
   `DerivationTree` excerpt at 237 which uses all three.

3. **Gloss the leading dot at line 153, its first use, and fix the name at 651.** At 153 a
   half-sentence suffices: `.Dense` abbreviates `FrameClass.Dense`, because Lean resolves a leading
   dot against the type it expects there, with a pointer to the fuller treatment in section A.7. At
   651, rename "anonymous constructor notation" to dot notation against the expected type, and have
   it back-reference the gloss at 153 rather than introduce the idea afresh. Correspondingly, have
   line 1213 point back to line 191 for the anonymous constructor rather than re-explain it.

4. **Comment the variable-name switch, at line 140 or 114.** The `DerivationTree` side of the
   source spells its arguments `Γ` and `φ`; the `Derivable` side spells them `G` and `p`. The
   turnstile table shows both spellings in adjacent rows with no word about it. One sentence saying
   the two notations quote their own source's variable names, and that the difference is spelling
   and not meaning, closes seeded gap (iii)'s second half.

5. **Introduce `Axiom` and `Axiom.minFrameClass` at line 156.** `Axiom φ` is an inductive family
   whose inhabitants witness that `φ` instantiates one of the axiom schemata, and
   `Axiom.minFrameClass` maps such a witness to the weakest frame class that licenses it. Add a
   one-clause gloss that `≤` here is the `FrameClass` partial order, with a pointer to section A.11
   where the order is shown. This closes seeded gap (ii)'s remaining half without moving the order
   discussion out of the section where it earns its place.

6. **Resolve the three author TODO comments** at 286-292, 317-328 and 403-418, following their own
   specifications, which this audit has verified as accurate. Then reword the corresponding
   whitelist category header in `typst/sync-check-whitelist.txt` so it no longer describes the
   spans as living in Typst line comments.

7. **Gloss the five long-range forward references at their first use**, each in a clause with a
   section pointer: `simp` at 120 pointing to A.8; `deriving` at 216 pointing to A.5; `#check` at
   332 and `#print axioms` at 811 pointing to A.14; `def` versus `theorem` at 114 pointing to A.10.

8. **Introduce `Nonempty` at line 116**, where `Derivable`'s body first uses it, rather than only
   naming it at 191. This also lets the TODO at 403 be discharged as a back-reference plus the
   field-specific material, which is shorter than the TODO's own plan.

9. **Add a short syntax-glyph paragraph covering the remaining NONE rows.** The economical place is
   section A.2 or A.3, covering `:=`, `→` as a function arrow against object-level implication,
   `∀`, `∃`, `¬`, `True`/`False`, and `↑` as the coercion arrow. Then gloss in place the ones tied
   to a single site: `Type _` at 521, `match … with` at 850, `Set` and set-builder at 559, `rfl` at
   1154, `trivial` at 174, `case` at 680, `abbrev` at 526, `@[simp]` at 540, and `instance` as a
   declaration keyword at 361.

10. **Flag the `decide` name collision**, one clause at 1270: the project's `decide` is a `def`
    returning a `DecisionResult` and is unrelated to the `decide` tactic used at 866.

11. **Leave class (d) alone.** Every presentation convention is already introduced before first
    use. Adding to it would be scope widening.

Sizing note for the planner. Recommendations 1 through 5 and 10 are prose insertions of one to six
sentences each, all inside sections A.2 and A.7. Recommendation 6 is the largest single piece of
work, roughly three paragraphs plus a worked example, and it is the only one that touches a file
outside the appendix. Recommendations 7 through 9 are many small edits with low individual risk.
A four-phase plan tracking that grouping would size each phase to one agent run.

## Risks & Mitigations

- **Column-budget overflow.** `lean-code()` fixes a 63-column budget. Any new didactic example, for
  instance the `Γ ⊢ φ` equals `Γ ⊢[.Base] φ` demonstration, must fit. Mitigation: the verification
  snippets in the Appendix were written inside the budget and can be lifted as written.
- **Check 1 drift from new identifier spans.** New prose naming `ValidIn`, `SemanticConsequence`,
  `Axiom.minFrameClass` or `List Formula` introduces backticked spans that Check 1 of
  `scripts/typst-sync-check.sh` resolves against live source. Mitigation: every one of these
  resolves today, verified above. Run the sync check before declaring the phase green.
- **Whitelist category going stale.** Recommendation 6 makes the whitelist's own header comment
  false. Mitigation: it is named explicitly in recommendation 6 so it is not forgotten.
- **Length growth against the element lint.** The lint passes today with zero remarks and the
  appendix carries no theorem-family elements, so the placement rule has nothing to bite on.
  Growth is a page-budget question rather than a lint question. Mitigation: re-run the lint at each
  phase boundary anyway, since it is cheap.
- **Territory.** Two sibling tasks are dispatched this cycle. Task 703's declared scope is entirely
  under `FormalSystem/Metalogic/Decidability/` plus four named files, none of which this task
  touches. Task 701 declares no scope at all, so the working tree must be re-read immediately
  before each edit and staging must name individual files.

## Tactic Survey Results

- Not applicable. This task writes Typst prose about Lean, not Lean proofs, so no proof goal was
  available to survey tactics against. The one Lean artifact produced was a verification file of
  `rfl` examples and `#check` commands, which compiled without any tactic beyond `rfl`.

## Context Extension Recommendations

- **Topic**: define-before-use auditing of expository documents.
- **Gap**: the repository has `standards/chapter-quality.md` and a Typst element lint, but no
  recorded method for the first-use ledger this task's description specifies. The method generalizes
  to any chapter that introduces notation.
- **Recommendation**: after this task lands, consider a short context file capturing the ledger
  procedure, the four item classes, and the three verdicts, so a later audit of another chapter does
  not re-derive them.

## Appendix

### Verification run

Compiled with `lake env lean` against `leanprover/lean4:v4.33.0-rc1` at the session scratch path,
outside `FormalSystem/` and `Tests/`, exactly as the appendix header contract requires of its
didactic examples. The run produced no errors and no warnings; its only output was the three
`#check` results shown below.

```lean
import FormalSystem
open FormalSystem FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Semantics

example (G : Context) (p : Formula) : (G ⊢ p) = (G ⊢[FrameClass.Base] p) := rfl
example (G : Context) (p : Formula) : (G ⊢ p) = (G ⊢[.Base] p) := rfl
example (p : Formula) : (⊢ p) = ([] ⊢[.Base] p) := rfl
example (G : Context) (p : Formula) : (G |-! p) = (G |-![.Base] p) := rfl
example (G : Context) (p : Formula) : (G |-! p) = Derivable FrameClass.Base G p := rfl
example : Context = List Formula := rfl
example (p : Formula) : (⊨ p) = Valid p := rfl
example (p : Formula) : Valid p = ValidIn FrameClass.Base p := rfl

#check @Axiom.minFrameClass
#check @Axiom
#check @Nonempty.intro
```

Output:

```
@Axiom.minFrameClass : {φ : Formula} → Axiom φ → FrameClass
Axiom : Formula → Type
@Nonempty.intro : ∀ {α : Sort u_1} (val : α), Nonempty α
```

### Source locations consulted

| Fact | Location |
|------|----------|
| The four `⊢` notations | `FormalSystem/ProofSystem/Derivation.lean` 346, 351, 356, 361 |
| The four `\|-!` notations | `FormalSystem/ProofSystem/Derivable.lean` 77, 82, 87, 92 |
| `Context` | `FormalSystem/Syntax/Context.lean` 60 |
| `Axiom` | `FormalSystem/ProofSystem/Axioms.lean` 152 |
| `FrameClass`, `LE`, `DecidableRel`, `PartialOrder` | `FormalSystem/ProofSystem/Axioms.lean` 550, 557, 566, 569 |
| `Axiom.minFrameClass` | `FormalSystem/ProofSystem/Axioms.lean` 665 |
| `FrameClass.Sat` | `FormalSystem/Semantics/FrameClassValidity.lean` 151 |
| `SemanticConsequence` notation, `ValidIn`, `Valid`, `⊨` | `FormalSystem/Semantics/Validity.lean` 122, 348, 385, 391 |
| `Nonempty` | `Init/Prelude.lean` 792, pinned toolchain |
| `Inhabited` | `Init/Prelude.lean` 776, pinned toolchain |
| `F.worldNonempty.some` in live use | `Semantics/Validity.lean` 290, 303; `Semantics/Correspondence/Rigidity.lean` 296; `Semantics/ConvexTruth.lean` 355 |
| `lean-code()` and its column budget | `typst/template.typ` 125-213 |
| The TODO whitelist category | `typst/sync-check-whitelist.txt` 236-249 |

### Ledger totals

| Verdict | Count |
|---------|-------|
| OK, introduced at or before first use | 62 |
| FWD, used before introduced | 30 |
| NONE, never introduced | 44 |
| partial, named but not explained | 8 |
| N/A, seeded item that does not reproduce | 4 |
