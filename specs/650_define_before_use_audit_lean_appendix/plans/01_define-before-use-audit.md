# Implementation Plan: Define-Before-Use Audit of the Lean Appendix

- **Task**: 650 - Define-before-use audit of the Lean appendix
- **Status**: [IMPLEMENTING]
- **Effort**: 9 hours
- **Dependencies**: 647, 648, 649 (all landed)
- **Research Inputs**: `specs/650_define_before_use_audit_lean_appendix/reports/01_define-before-use-audit.md`
- **Artifacts**: plans/01_define-before-use-audit.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The Lean appendix `typst/chapters/ax-lean-appendix.typ` is a finished 1351-line, fourteen-section
Lean 4 primer. A 140-row first-use ledger over it found 30 forward references, 44 items never
introduced at all, 8 named-but-unexplained items, and one outright naming defect. This plan
applies the ledger's repairs in reading order, adding and reordering introductions, glosses and
back-references only. Done means the reference manual compiles, the element-placement lint reports
no blocking findings, `scripts/typst-sync-check.sh` passes all four checks, and `typst/SYNC-MAP.md`
carries a dated entry.

The plan does not change what the appendix claims and does not widen its coverage. It adds no
appendix-local code formatting: every code block stays in `template.typ`'s `lean-code()`
environment, at its 63-column budget.

### Research Integration

The report supplies the complete ledger, so no phase below has to rediscover a first-use line. It
also supplies eleven Lean facts already verified by a `lake env lean` compile against the pinned
toolchain `leanprover/lean4:v4.33.0-rc1`, covering every definitional-equality claim the new prose
asserts: `Γ ⊢ φ` and `Γ ⊢[.Base] φ` are the same type by `rfl`, `Context` is `List Formula`,
`⊨ φ` is `Valid φ` is `ValidIn FrameClass.Base φ`, and `Axiom : Formula → Type` with
`Axiom.minFrameClass : {φ : Formula} → Axiom φ → FrameClass`. Those snippets can be lifted into the
appendix as written, inside the column budget.

Three findings drive the phase ordering. All three seeded gaps reproduce. Two unseeded gaps outrank
them in reader cost: `Context` is never revealed to be `List Formula`, which leaves `[]`, `∈` and
`⊆` unreadable, and `⊨` is used seven times without appearing in the notation table. One row is a
defect rather than an omission: line 651 calls the leading dot `.Dense` "anonymous constructor
notation", which collides with the correct use of that name for `⟨ ⟩` at line 1213.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap path was supplied in the dispatch context, and no roadmap phases are required.

## Goals & Non-Goals

**Goals**:
- Every ledger row classified `FWD`, `NONE` or `partial` is closed, by a one-clause gloss at first
  use with a pointer to the full treatment, by relocating a short introduction, or by adding an
  introduction where none exists.
- Each of the three seeded KNOWN GAPS is closed: the `[fc]` bracket is explained in full, the
  `FrameClass` apparatus (four tags, partial order, `Axiom.minFrameClass`, `DerivationTree.lift`)
  is introduced once and systematically, and the leading-dot shorthand plus the `Γ`/`φ` versus
  `G`/`p` variable switch are commented.
- The line-651 naming defect is corrected, with the two pieces of syntax carrying their two correct
  names and later uses back-referencing rather than re-explaining.
- The three author `TODO` comments at lines 286, 317 and 403 are resolved into rendered prose and
  removed as tags from a deliverable file.
- One canonical introduction per item, placed at or before first use; later uses point back by
  cross-reference label.

**Non-Goals**:
- Changing any claim the appendix makes, or widening its Lean coverage beyond what it already
  cites.
- Reintroducing appendix-local code formatting in place of `lean-code()`.
- Touching lines 122-126, the `FrameClass`-is-syntactic clarification the dispatch explicitly asks
  to keep.
- Introducing `noncomputable` or `fun`: neither occurs anywhere in the appendix, so there is
  nothing to introduce. Both are closed with a one-line note in the summary, never "fixed" anyway.
- Any edit to class (d), the presentation conventions. Every one of them is already introduced at
  lines 76-78, before its first use at line 112.
- Any change under `FormalSystem/`. This task reads live Lean source; it never writes it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Line numbers in the ledger go stale as earlier phases insert prose | M | H | Every phase below names its edit site by anchor text or section label, not by absolute line number. Re-grep for the anchor immediately before each edit. |
| A new didactic example overflows the 63-column `lean-code()` budget | M | M | Lift the report's Appendix snippets, which were written inside the budget. Check 4 of `typst-sync-check.sh` catches an overflow; run it at every phase boundary. |
| New backticked identifier spans fail Check 1 name resolution | M | M | `ValidIn`, `SemanticConsequence`, `Axiom.minFrameClass`, `List Formula` were each confirmed to resolve today. Any further new span must be re-verified against live non-Boneyard source before it is written. |
| Whitelist category header goes factually stale in Phase 8 | L | H | Phase 8 owns the reword explicitly; it is a checklist item, not an aside. |
| A sibling task edits the working tree concurrently | M | M | Tasks 701 (no declared scope) and 703 (scoped under `FormalSystem/Metalogic/Decidability/`) are dispatched this cycle. Re-read every target file immediately before editing; stage individual file paths, never a directory or glob; treat an unexpected failure outside `typst/` as possibly a sibling's in-flight edit. |
| Appendix grows past its page budget | L | M | Growth is a page-budget question, not a lint question: the appendix carries no theorem-family elements, so the placement rule has nothing to bite on. Prefer a one-clause gloss plus a pointer over a new paragraph wherever both would work. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |

Phases within the same wave can execute in parallel. **This plan declares no parallel wave on
purpose.** Phases 1 through 8 all edit the single file `typst/chapters/ax-lean-appendix.typ`, so
concurrent dispatch would put two agents in the same file. Several phases are also content-coupled:
later glosses back-reference introductions that earlier phases create. The strictly linear chain
above is the correct dispatch order, not a missed parallelisation.

---

### Phase 1: Turnstile Notation and the `[fc]` Bracket [COMPLETED]

**Goal**: Close seeded gap (i) and the `⊨`/`Valid`/`ValidIn` rows by extending the notation table
and the prose that follows it in section A.2.

**Tasks**:
- [ ] Locate the notation `#figure(table(...))` in `@lean-appendix-types-props` by its
      `[*Notation*], [*Unfolds to*], [*Universe*]` header row.
- [ ] Add a table row for `⊨ φ` unfolding to `Valid φ` in `Prop`. Note in the accompanying prose
      that `Valid φ` is by definition `ValidIn FrameClass.Base φ`, and that a separate two-place
      `Γ ⊨ φ` for `SemanticConsequence` exists in the source but is never used in this appendix.
- [ ] Extend the prose after the table to state, keeping the existing sentence about omitting the
      context: (1) the brackets are literal tokens of project-defined `notation`, declared in
      `FormalSystem/ProofSystem/Derivation.lean` and `FormalSystem/ProofSystem/Derivable.lean`, not
      built-in Lean syntax; (2) what goes between them is any term of type `FrameClass`, either a
      concrete tag such as `.Dense`, giving a derivation in that one system, or a bound variable
      `fc`, giving a statement that holds in all four systems at once; (3) this is the Lean spelling
      of the subscripted turnstile of the paper's TM_d, TM_z and TM_r; (4) the bracket-free forms
      are exactly the `FrameClass.Base` instances, so `Γ ⊢ φ` and `Γ ⊢[.Base] φ` are the same type;
      (5) the exclamation mark in `|-!` marks the `Prop`-valued `Derivable` twin.
- [ ] Optionally add one didactic `lean-code` example demonstrating claim (4) by `rfl`, lifted
      verbatim from the research report's verification run so the column budget is already known to
      hold. Re-compile it with `lake env lean` from a scratch path outside `FormalSystem/` and
      `Tests/` before writing it in, per the appendix's own header contract.
- [ ] Add one sentence covering the variable-name switch: the `DerivationTree` side of the source
      spells its arguments `Γ` and `φ`, the `Derivable` side spells them `G` and `p`, each notation
      quotes its own source's names, and the difference is spelling rather than meaning. This closes
      the second half of seeded gap (iii).
- [ ] Leave lines 122-126 untouched.

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts it closes six ledger rows (`Γ ⊢[fc] φ`, `⊢[fc] φ`, the `!`
mark, `G |-![fc] p`, `⊨ φ`, `Valid φ`) plus the `Γ`/`φ` versus `G`/`p` row, and that the
`⊢`/`⊢[.Base]` identity example fits the 63-column budget. Confirm at implementation time by
re-reading each cited first-use site after the edit and by running Check 4 of
`scripts/typst-sync-check.sh`, which fails on a column overflow.

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - extend the notation table and the prose following it in section A.2

**Verification**:
- `typst compile --root .. BimodalReference.typ build/BimodalReference.pdf` from `typst/` succeeds.
- `bash scripts/typst-sync-check.sh` passes all four checks.
- `bash .claude/scripts/typst-element-lint.sh --verbose typst/chapters/ax-lean-appendix.typ`
  reports no blocking findings.
- Any new didactic example compiled with `lake env lean` before insertion.

---

### Phase 2: Syntactic Prerequisites at First Use in A.2 and A.3 [COMPLETED]

**Goal**: Introduce `Context`, `Nonempty`, the leading-dot shorthand and the `Axiom` /
`Axiom.minFrameClass` pair at their first use, closing the highest-cost remaining ledger rows and
the rest of seeded gaps (ii) and (iii).

**Tasks**:
- [ ] At the first appearance of `Context` (the `Derivable` excerpt's `(G : Context)` binder), add
      one clause: `Context` is an `abbrev` for `List Formula`, which is why the empty context is
      written `[]`, why the `assumption` rule's hypothesis reads `φ ∈ Γ`, and why `weakening` reads
      `Γ ⊆ Δ`. This closes the `Context`, `[]`, `∈` and `⊆` rows at once and must precede the
      `DerivationTree` excerpt, which uses all three.
- [ ] At the first appearance of `Nonempty` (inside `Derivable`'s body), introduce it: a `Prop`
      recording *that* an element exists while forgetting *which*, so an inhabitant is a proof
      rather than data. Keep it short; Phase 8 back-references this introduction rather than
      repeating it.
- [ ] At the first use of the leading dot (the `h.minFrameClass ≤ fc` discussion's neighbourhood,
      where `.Dense` and `.Base` first appear), add a half-sentence: `.Dense` abbreviates
      `FrameClass.Dense`, because Lean resolves a leading dot against the type it expects at that
      position. Point forward by `@`-reference to the fuller treatment in
      `@lean-appendix-recursion`.
- [ ] At the `h.minFrameClass ≤ fc` side-condition sentence, introduce `Axiom` and
      `Axiom.minFrameClass`: `Axiom φ` is an inductive family (`Axiom : Formula → Type`) whose
      inhabitants witness that `φ` instantiates one of the axiom schemata, and
      `Axiom.minFrameClass` maps such a witness to the weakest frame class that licenses it. Add a
      one-clause gloss that `≤` here is the `FrameClass` partial order, with an `@`-reference to
      `@lean-appendix-derivations-as-data` where the order is shown. Do not move the order
      discussion out of that section.
- [ ] Verify every new backticked span resolves in live non-Boneyard source before writing it.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that one sentence about `Context` closes four ledger rows
(`Context`, `[]`, `∈`, `⊆`) and that `Axiom`, `Axiom.minFrameClass` and the `FrameClass` order each
need only a gloss plus a pointer rather than a relocated section. Confirm by re-reading the
`DerivationTree` excerpt and the `@lean-appendix-derivations-as-data` order discussion after the
edit and checking no later site now re-explains the same item.

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - add introductions for `Context`, `Nonempty`, the leading dot, `Axiom` and `Axiom.minFrameClass` in sections A.2 and A.3

**Verification**:
- Reading A.2 top to bottom, no item in the `DerivationTree` or `Derivable` excerpts is used before
  it is introduced.
- `bash scripts/typst-sync-check.sh` passes; new spans resolve under Check 1.
- The manual compiles and the element lint reports no blocking findings.

---

### Phase 3: Terminology Corrections and Back-References [COMPLETED]

**Goal**: Fix the one defect in the ledger, the `anonymous constructor` name collision, and convert
the two affected later sites into back-references.

**Tasks**:
- [ ] At the leading-dot explanation in `@lean-appendix-recursion` (currently "The leading dot is
      *anonymous constructor notation*"), rename the construct to dot notation resolved against the
      expected type. Keep the rest of the sentence, which correctly describes the mechanism.
- [ ] Have that site back-reference the Phase 2 gloss rather than introduce the idea afresh.
- [ ] At the `⟨"p", none⟩` site in `@lean-appendix-reading-source`, keep "anonymous constructor" as
      the name, and replace its re-explanation with a back-reference to the existing anonymous-
      constructor introduction in A.3 (the `Derivable.ofTree` / `⟨boxPImpP p⟩` passage).
- [ ] At the decision-procedure site, add one clause flagging the name collision: the project's
      `decide` is a `def` returning a `DecisionResult`, unrelated to the `decide` tactic used in
      `@lean-appendix-derivations-as-data`.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the appendix contains exactly two sites naming "anonymous
constructor" and one `decide` collision site. Confirm at implementation time by grepping the file
for `anonymous constructor` and for `decide`, and reconcile the hit count against this assertion
before editing.

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - rename the leading-dot construct, convert two sites to back-references, flag the `decide` collision

**Verification**:
- `grep -n "anonymous constructor" typst/chapters/ax-lean-appendix.typ` shows the name attached
  only to `⟨ ⟩`.
- The manual compiles; all `@`-references resolve with no unresolved-label warning.
- Element lint and sync check clean.

---

### Phase 4: Long-Range Forward-Reference Glosses [COMPLETED]

**Goal**: Close the five longest-range `FWD` rows with a one-clause gloss plus a section pointer at
each first use, leaving the full treatments where they earn their position.

**Tasks**:
- [ ] `simp` at its first use in the `Derivable` wrapper paragraph: gloss plus pointer to
      `@lean-appendix-tactics`.
- [ ] `deriving` at its first use in the `Formula` inductive excerpt: gloss plus pointer to
      `@lean-appendix-structures`. Name what the clause generates rather than leaving the reader to
      infer it.
- [ ] `#check` at its first use in the binder section: gloss plus pointer to
      `@lean-appendix-reading-source`.
- [ ] `#print axioms` at its first use in `@lean-appendix-derivations-as-data`: gloss plus pointer
      to `@lean-appendix-reading-source`.
- [ ] `def` versus `theorem` at their first use in A.2: one clause distinguishing a definition from
      a theorem, with a pointer to the naming-conventions section that treats them fully.
- [ ] Verify that each gloss points at a section that actually contains the full treatment, by
      opening the referenced label.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts exactly five long-range forward references need glossing
and that each named target section carries the full treatment. Confirm by opening each `@`-target
after the edit and checking the treatment is there.

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - add five first-use glosses with section pointers

**Verification**:
- Each of the five items carries a gloss at first use and a resolving `@`-reference.
- The manual compiles with no unresolved references.
- Element lint and sync check clean.

---

### Phase 5: Syntax-Glyph Paragraph and Single-Site Glosses [NOT STARTED]

**Goal**: Close the remaining `NONE` rows in class (c) with one economical paragraph for the
recurring glyphs, and an in-place gloss for each item tied to a single site.

**Tasks**:
- [ ] Add a short syntax-glyph paragraph in `@lean-appendix-types-props` or
      `@lean-appendix-props-as-types`, whichever reads better given the Phase 1 and 2 additions,
      covering `:=` as definition, `→` as the function arrow against object-level implication, `∀`,
      `∃`, `¬`, `True` / `False`, and `↑` as the coercion arrow.
- [ ] Distinguish the two roles of `|` where both appear: separating constructors in an `inductive`
      and separating match arms.
- [ ] Gloss in place, each at its single site: `Type _` as a universe placeholder; `match … with`;
      `Set` and `{w | … }` set-builder; `rfl`; `trivial`; the `case` tactic; `refine ?_`; `abbrev`;
      `@[simp]`; `instance` as a declaration keyword; `|y|` absolute value on a duration; `0 < x`
      numerals on a `TemporalOrder`; and the basic types `String`, `Nat`, `Option Nat`, `none`,
      `Bool` where they first appear.
- [ ] Gloss the derived formula operators and dot/field notation at their first use, and the `□`
      glyph at its first appearance in `⊢ □p → p`, noting that the line mixes book notation with
      Lean.
- [ ] Gloss `φ.reflectTime` at its first use as an operator, distinct from the rule the surrounding
      prose already explains.
- [ ] Prefer a clause inside an existing sentence over a new paragraph wherever both would work.

**Timing**: 1.75 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts it closes the remaining class (c) `NONE` and `partial`
rows not already handled by Phases 1 through 4. Confirm at implementation time by walking the
research report's class (c) table row by row and marking each row closed, deferred with a reason,
or already handled by an earlier phase. Rows left open must be named explicitly in the phase
commit message rather than silently dropped.

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - add one syntax-glyph paragraph and roughly a dozen single-site glosses

**Verification**:
- Every class (c) ledger row is closed or has a named, reasoned exclusion.
- The manual compiles; element lint and sync check clean.
- No new backticked span fails Check 1.

---

### Phase 6: Resolve the `Atom` Structure TODO [NOT STARTED]

**Goal**: Convert the author `TODO` at the `Atom` excerpt into rendered prose, following its own
specification, and remove the tag.

**Tasks**:
- [ ] Walk the `Atom` excerpt line by line in rendered prose: the `structure … where` header; each
      `name : Type` field line, saying what `String`, `Nat` and `Option Nat` are and why
      `freshIndex` is optional.
- [ ] Explain how an `Atom` value is built (anonymous-constructor brackets, the
      `{ base := ..., .. }` structure-instance form, and the generated `Atom.mk`) and how its fields
      are read back (`a.base`, `a.freshIndex`).
- [ ] Explain what the `deriving` clause generates, one handler at a time: `Repr`, `DecidableEq`,
      `BEq`, `Hashable`. Back-reference the Phase 4 `deriving` gloss rather than re-introducing it.
- [ ] Delete the `//`-prefixed TODO comment block once its content is rendered.
- [ ] Re-use the Phase 2 and Phase 5 introductions by back-reference wherever they already cover an
      item this passage would otherwise explain again.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the `Atom` TODO's specification is accurate and complete as
written, which the research verified. Confirm by re-reading the excerpt against the new prose and
checking each named item is covered.

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - replace the `Atom` TODO comment with rendered prose

**Verification**:
- No `TODO` tag remains at the `Atom` excerpt.
- The manual compiles; element lint and sync check clean.
- Backticked spans formerly shielded by the whitelist still pass Check 1 in their new rendered-prose
  position.

---

### Phase 7: Resolve the Three-Binders TODO [NOT STARTED]

**Goal**: Make the binder discussion clear, systematic and complete, in the same order and shape for
all three binders, as the author TODO specifies.

**Tasks**:
- [ ] Treat each of the three binders (explicit `(x : T)`, implicit `{x : T}`, instance `[C α]`) in
      the same five-part shape: what is written at the declaration site; what the caller writes or
      omits at the use site; how Lean fills the argument in when omitted (unification for implicit,
      instance synthesis for instance) and what error appears when it cannot; how to override the
      default (`@f`, named arguments such as `(fc := .Dense)`); and one worked example from
      `FormalSystem/` per binder, ideally a single signature using all three, shown once as declared
      and once as called.
- [ ] Give the explicit binder its own prose; it currently has none beyond the table row.
- [ ] Cover the variants the reader will meet: several names under one binder `(φ ψ : Formula)`,
      strict-implicit `⦃x : T⦄`, anonymous instance binders `[DecidableEq α]` against named ones
      `[inst : DecidableEq α]`, `variable` declarations that add binders invisibly, and auto-bound
      implicits.
- [ ] Verify the chosen worked-example signature against live non-Boneyard source before writing it.
      If any new example is a didactic block rather than an excerpt, compile it with `lake env lean`
      and keep it inside the column budget.
- [ ] Delete the `//`-prefixed TODO comment block once its content is rendered.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts a single live `FormalSystem/` signature exists that uses
all three binder kinds and is short enough for the column budget. Confirm by locating one at
implementation time; if none fits, fall back to one worked example per binder and record the
substitution in the phase commit message.

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - rewrite the binder subsection and remove its TODO comment

**Verification**:
- All three binders receive the same five-part treatment, in the same order.
- Any new excerpt is verbatim up to whitespace against live source; any new didactic example
  compiles with `lake env lean`.
- The manual compiles; element lint and sync check clean.

---

### Phase 8: Resolve the `worldNonempty` TODO and Reword the Whitelist Category [NOT STARTED]

**Goal**: Complete the third author TODO and bring `typst/sync-check-whitelist.txt` back into
agreement with reality now that all three TODO comments are gone.

**Tasks**:
- [ ] Explain the `worldNonempty` field per its TODO: that the line has the same `name : Type` shape
      as every other field; what `Nonempty α` is, back-referencing the Phase 2 introduction rather
      than repeating it, and noting that the field's value is a proof rather than data, encoding the
      requirement that the set of world states be nonempty; that by proof irrelevance
      (`@lean-appendix-types-props`) any two such proofs are equal, so the field singles out no
      particular world state; the contrast with `Inhabited α`, which stores a specific default; and
      how the source obtains an element when it needs one (`F.worldNonempty.some`, noncomputable and
      resting on choice).
- [ ] Explain what the square brackets add at the construction site and what the
      `attribute [instance]` line adds at the use site, as the TODO specifies.
- [ ] Gloss the other proof fields the prose currently passes over: `comp`, `serial`, `limit` and
      `saturation`, including how to read the `∀ w u, (∀ x, 0 < x → ∃ y, ...) → u = w` statement of
      `limit`.
- [ ] Delete the `//`-prefixed TODO comment block.
- [ ] Reword the `typst/sync-check-whitelist.txt` category header that currently describes these
      spans as living in `//`-prefixed Typst line comments. The spans themselves stay whitelisted;
      only the header's description changes, to name them as rendered generic-syntax illustrations.

**Timing**: 1.25 hours

**Depends on**: 7

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts one whitelist category covers all three TODO blocks' spans
and that no whitelisted span becomes unnecessary once the comments become prose. Confirm by running
`scripts/typst-sync-check.sh` after the reword and checking Check 1 still passes with the category
intact.

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - replace the `worldNonempty` TODO with rendered prose
- `typst/sync-check-whitelist.txt` - reword the category header describing the former TODO spans

**Verification**:
- `grep -n "TODO" typst/chapters/ax-lean-appendix.typ` returns nothing.
- `bash scripts/typst-sync-check.sh` passes all four checks.
- The whitelist header describes the spans accurately.
- The manual compiles; element lint clean.

---

### Phase 9: Final Gates, Ledger Reconciliation and SYNC-MAP Entry [NOT STARTED]

**Goal**: Run the complete gate set, reconcile the finished file against the research ledger row by
row, and record the pass in `typst/SYNC-MAP.md`.

**Tasks**:
- [ ] Walk the research report's four ledger tables row by row against the edited file. Mark each
      previously non-`OK` row closed, or record it as a reasoned exclusion with evidence.
- [ ] Record the four `N/A` seeded rows as closed with a one-line note, confirming that
      `noncomputable` and `fun` still do not occur anywhere in the appendix and so were correctly
      not introduced.
- [ ] Run `bash scripts/typst-status-counts.sh` if any count-bearing prose changed, then
      `bash scripts/typst-sync-check.sh` and confirm all four checks pass.
- [ ] Run `bash .claude/scripts/typst-element-lint.sh --verbose typst/chapters/ax-lean-appendix.typ`
      and confirm no blocking findings.
- [ ] Build the manual with the invocation documented in `typst/README.md`:
      `typst compile --root .. BimodalReference.typ build/BimodalReference.pdf`, run from `typst/`.
      Confirm it completes with no warnings, matching the zero-warning state the most recent
      SYNC-MAP entry records.
- [ ] Add a dated entry to `typst/SYNC-MAP.md` describing the audit, the categories of change, the
      three resolved TODO comments, the whitelist reword, and the gate results. Cite durable anchors
      (file names, section labels), never task numbers.
- [ ] Confirm no task-number reference was introduced into any file outside `specs/`.

**Timing**: 1 hour

**Depends on**: 8

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts every ledger row is closed or excluded with evidence, and
that the gate set is exactly the four gates named above. Confirm by producing the reconciled ledger
and by capturing each gate's exit status in the phase record.

**Files to modify**:
- `typst/SYNC-MAP.md` - add a dated entry recording this audit pass
- `typst/generated/status.typ` - regenerate only if count-bearing prose changed

**Verification**:
- All four gates green: `typst compile`, `typst-sync-check.sh`, `typst-element-lint.sh`, and the
  ledger reconciliation.
- `typst/SYNC-MAP.md` carries the dated entry.
- `bash .claude/scripts/check-task-references.sh` clean for `typst/`, or an equivalent grep
  confirming no task-number reference outside `specs/`.

---

## Lean Challenge Statements

This plan commits to no new Lean declarations. Its deliverable is Typst prose about existing Lean
source, and its `- **Goals**:` bullets name no Lean identifiers to prove, so the identifier set
declared here is empty and equals the Goals identifier set, as this section's cross-validation
requirement demands. Any Lean code the phases above introduce is either a verbatim excerpt of an
already-proved live declaration or a didactic `example` compiled with `lake env lean` for
illustration; neither is a proof obligation this plan takes on.

## Testing & Validation

- [ ] `typst compile --root .. BimodalReference.typ build/BimodalReference.pdf` from `typst/`
      completes with zero errors and zero warnings.
- [ ] `bash scripts/typst-sync-check.sh` passes all four checks: backtick name resolution, count
      freshness, machine-appendix freshness, and code-environment discipline.
- [ ] `bash .claude/scripts/typst-element-lint.sh --verbose typst/chapters/ax-lean-appendix.typ`
      reports no blocking findings.
- [ ] Every didactic `lean-code` block added or changed compiles with `lake env lean` against the
      pinned toolchain, run from a scratch path outside `FormalSystem/` and `Tests/`.
- [ ] Every `lean-code(source: (module, name))` excerpt added or changed is verbatim up to
      whitespace against live non-Boneyard source.
- [ ] Every ledger row from the research report is closed, or excluded with a named reason and
      evidence.
- [ ] `grep -n "TODO" typst/chapters/ax-lean-appendix.typ` returns nothing.
- [ ] No task-number reference appears in any file outside `specs/`.

## Artifacts & Outputs

- `typst/chapters/ax-lean-appendix.typ` - the audited and repaired appendix
- `typst/sync-check-whitelist.txt` - reworded category header
- `typst/SYNC-MAP.md` - dated entry for this audit pass
- `typst/generated/status.typ` - regenerated only if count-bearing prose changed
- `specs/650_define_before_use_audit_lean_appendix/summaries/01_define-before-use-audit-summary.md` -
  execution summary including the reconciled ledger

## Rollback/Contingency

Every phase is a self-contained, independently revertible edit to a prose file, committed on its own
green sub-step. A phase that fails its gates is reverted by `git revert` of that phase's commit,
which leaves earlier phases intact.

Before any risky edit, take a durable, non-reverting checkpoint with
`bash .claude/scripts/git-snapshot.sh 650 --no-revert`. Do not emit a bare default-mode
`git-snapshot.sh 650` as a routine start-of-phase precaution: the default mode reverts the working
tree. For a genuine whole-tree rollback, follow the rollback rung in
`.claude/context/contracts/recovery.md` for the exact invocation shape, including its
out-of-scope override flag.

Because sibling tasks 701 and 703 are dispatched on this same working tree, stage individual file
paths only, never a directory or glob, and re-read each target file immediately before editing it.
