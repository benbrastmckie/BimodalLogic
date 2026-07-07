# Research Report: Task #312 — Teammate B (Paper + Typst Infrastructure)

**Task**: 312 - Systematically revise Theories/Bimodal/typst/BimodalReference.typ to align with the
completed paper and the Lean 4 source
**Focus**: The completed paper (`possible_worlds.tex`) and the Typst authoring infrastructure —
NOT the Lean-source-vs-Typst mapping (Teammate A's scope)
**Sources/Inputs**: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
(3473 lines), `Theories/Bimodal/typst/**`

## Executive Summary

- The paper's title is **"The Construction of Possible Worlds"**; its core object language is
  $\mathcal{L} = \langle \mathrm{SL}, \bot, \rightarrow, \Box, \mathrm{Past}, \mathrm{Future}\rangle$
  (primitives: atom, ⊥, →, □, H/Past, G/Future) — this already matches
  `chapters/01-syntax.typ` and `chapters/02-semantics.typ` closely in notation and structure.
- The paper's **core "TM" axiom system** (lines 1087–1105 of the .tex) has only **12 schemata**:
  3 rules (MP, MN, TD) + 9 axioms (MK, MT, M5, MF, TK, T4, TB, TA, TL). It does **not** include
  M4 or MB as primitives (S5 is obtained from MT + M5 + MK alone), and it does **not** spell out
  K/S/EFQ/Peirce by name (CPL is simply assumed as the propositional base). The current
  `chapters/03-proof-theory.typ` presents a **15-axiom** system that adds M4, MB (redundant modal
  axioms not in the paper), promotes the paper's *derived theorem* TF to a primitive axiom, is
  **missing TB** (`◇⊤`/seriality) entirely, and states **TL with the wrong formula** (Typst has
  `always φ → G H φ`; the paper's TL is a linearity axiom over `future`-diamond conjunctions).
- The Task Frame definition in `chapters/02-semantics.typ` is missing one of the paper's three
  frame constraints: **Reflection** (`w ⇒ₓ u ⟹ u ⇒₋ₓ w`) is present in the paper (line 905) but
  absent from the Typst `definition("Task Frame")` (lines 34–38), which lists only Nullity and
  Compositionality. There is also no `leanReflection`-style notation macro in
  `bimodal-notation.typ` (only `leanNullity`, `leanCompositionality` exist), consistent with this
  being an actual content gap rather than a formatting omission.
- **Internal inconsistency already exists inside the Typst document**: `02-semantics.typ`'s Truth
  Conditions use **strict** temporal semantics (`y < x`, `x < y` — matching the paper exactly), but
  `04-metalogic.typ` and `06-notes.typ` extensively argue that the "current" implementation uses
  **reflexive** semantics (`y ≤ x`). These two chapters directly contradict each other on one of
  the most consequential semantic choices in the whole document. This must be resolved as part of
  the revision, and resolving it is a Lean-priority question (which does the current source
  actually implement?) that should be handed to whoever does the Lean-accuracy pass (Teammate A /
  the implementer).
- `chapters/06-notes.typ` already contains a "Discrepancy Notes" section attempting to reconcile
  paper vs. Lean axiom names, but it appears to reflect a **stale/earlier draft** of the paper: its
  "Paper Name" column lists M4 and MB as if the paper names them, which the current paper text does
  not do. This section needs a full rewrite once the true axiom system is settled.
- The Typst authoring infrastructure is a clean, modular system (`template.typ` for theorem
  environments, `notation/shared-notation.typ` + `notation/bimodal-notation.typ` for macros,
  `chapters/*.typ` included from `BimodalReference.typ`). It is mechanically easy to revise
  chapter-by-chapter without touching the template or notation files, **except** that new paper
  content (Reflection constraint, TB axiom, discrete/dense/complete extensions §2.3, `swap`/until
  since operators if ever added) will require new or reused notation macros.

## Context & Scope

I read the full paper in sections (front matter/macros, Introduction through the semantic
construction §2 "Possible Worlds" including Restricted Modalities/Bimodal Logic/Extensions, and
the section headers for the rest via `grep`), and all files under
`Theories/Bimodal/typst/` (main file, template, both notation files, all six chapter files, and
both READMEs). I did not re-derive the Lean-vs-Typst discrepancy table — that is Teammate A's
scope — but where the paper and Typst content diverge in ways relevant to Lean fidelity, I flag
the tension explicitly per the task's request.

## Findings

### Paper's Logical Spine (Section Structure)

```
§1 Introduction
§2 Primitive Worlds
  §2.1 World States        — critiques Prior/Thomason strict orderings of world states
  §2.2 Necessarily Always  — perpetuity principles motivated informally (SP1/SP2)
  §2.3 Absolute Time       — Montague/Kaplan two-dimensional semantics discussion
§3 Possible Worlds          <- core construction: task frames, world histories, models, truth, TM logic
  §3.1 Restricted Modalities  — Stability □^s, Openfuture, Openpast, Nomic operators (NOT in TM proper)
  §3.2 Bimodal Logic          — the TM axiom system itself (MP,MN,MK,MT,M5,MF,TD,TK,T4,TB,TA,TL)
  §3.3 Extensions             — TM_f/TM_d/TM_c/TM_dc via DF/DN/CO axioms (discrete/dense/complete time);
                                 Next/Previous, Since/Until operators; store/recall operators
§4 Tense and Modality
  §4.1 Open Future
  §4.2 Dynamical Systems
  §4.3 Conclusion
§Appendix
  Objective Modality, Two-Dimensional Semantics, Task Semantics (with all the appendix lemmas/theorems),
  Soundness, Proof Theory (extended TM+ with Since/Until — a DIFFERENT axiom set, prefixed TMP-*)
```

Section numbers/line anchors: Introduction (`possible_worlds.tex:413`), Primitive Worlds (`:494`),
Possible Worlds (`:879`), Bimodal Logic (`:1079`), Extensions (`:1162`), Tense and Modality
(`:1262`), Appendix (`:1545`), Task Semantics appendix (`:2256`), Soundness (`:2897`), Proof Theory
appendix (`:3085`).

**Important**: the appendix "Proof Theory" section (`:3085`–`:3473`) axiomatizes an *extended*
language `TM+` that adds Since/Until (`⊳`, `⊲`) with axiom labels `TMP-*` (e.g. `TMP-MK`,
`TMP-SE`, `TMP-CN`, `TMP-UE`, `TMP-NP`, `TMP-Z1`, ...). This is **not** the base TM system and
should not be confused with it when revising `03-proof-theory.typ` — the current Lean/Typst
`Formula` type (six primitives: atom, ⊥, →, □, H, G — `chapters/01-syntax.typ:12-18`) matches the
paper's **base** `TM` system (§3.2), not the `TM+` extension.

### Paper's Core TM Axiom System (the one the Typst reference should mirror)

From `possible_worlds.tex:1087-1105`, verbatim schema list ("closed under all instances of the
following axiom and rule schemata"):

| Label | Statement | Kind |
|---|---|---|
| MP | φ, φ→ψ ⊢ ψ | rule |
| MN | if ⊢φ then ⊢□φ | rule |
| MK | □(φ→ψ) → (□φ→□ψ) | axiom |
| MT | □φ → φ | axiom |
| M5 | ◇□φ → □φ | axiom |
| MF | □φ → □Gφ (bimodal interaction) | axiom |
| TD | if ⊢φ then ⊢φ with Past/Future swapped | rule |
| TK | G(φ→ψ) → (Gφ→Gψ) | axiom |
| T4 | Gφ → GGφ | axiom |
| TB | Fφ→⊤, i.e. `future⊤` (seriality) | axiom |
| TA | φ → G(Pφ) | axiom |
| TL | (Fφ∧Fψ) → [F(Fφ∧ψ)∨F(φ∧ψ)∨F(φ∧Fψ)] (linearity) | axiom |

The paper is explicit (`:1087`) that this is "the smallest extension of Classical Propositional
Logic (CPL)" — i.e. CPL is assumed, not spelled out with named Hilbert axioms. It derives **TF**
(`□φ → GBφ`... i.e. `□φ → □Fφ` wait: `□φ → G□φ`) as a **theorem**, not an axiom, at `:1127-1132`:
"We may also derive the following principle: **TF** □φ→G□φ. ... Composing yields □φ→Gφ□... " —
explicitly derived from MF + MT + TD, not primitive. The perpetuity principles P1–P6 follow at
`:1116-1154` (P1/P2 primary, P3–P6 derived using TF, M5, TK).

### Comparison: Typst `03-proof-theory.typ` vs. Paper's TM System

`Theories/Bimodal/typst/chapters/03-proof-theory.typ:12-109`:

- **Propositional** (K, S, EFQ, Peirce) — the paper never names these; it just assumes CPL. Not
  wrong per se (reflects how Lean encodes CPL as explicit combinators), but presenting them as
  "axiom schemata" of *TM* conflates the CPL substrate with the TM-specific schemata the paper
  actually names. Recommend reframing this subsection as "Propositional Base (implements CPL)"
  rather than implying parity with the paper's named axioms.
- **Modal (S5)**: lists MT, **M4**, **MB**, M5, MK (5 axioms) — paper's core system has only MT,
  M5, MK (3). M4 and MB are not named in the paper's TM axiomatization at all; the paper obtains
  S5 purely from MT+M5+MK+MN. `06-notes.typ:70-75` itself notes "M5 ... is derivable from the
  other S5 axioms (MB + M4) but is included as a primitive for proof convenience" — this
  acknowledges M4/MB are being treated as more fundamental than the paper does, which inverts the
  paper's presentation (paper: M5 primitive, 4/B not even mentioned).
- **Temporal**: TK, T4, TA present and TK/T4/TA formulas match the paper. **TB is entirely
  missing** (no seriality axiom `future⊤`/`F⊤` appears anywhere in `03-proof-theory.typ`). **TL is
  present but wrong**: Typst states `TL - Temporal L`: `always φ → G H φ`
  (`chapters/03-proof-theory.typ:68-70`), but the paper's TL (`:1103`) is
  `(Fφ∧Fψ) → [F(Fφ∧ψ)∨F(φ∧ψ)∨F(φ∧Fψ)]` — a completely different formula (linearity of future
  times, not an "always implies GH" introspection principle). This needs correction, contingent on
  what the actual Lean `Axiom.temp_l` constructor states (Teammate A / Lean-priority question).
- **Modal-Temporal Interaction**: MF matches the paper (`□φ→□Gφ`). **TF is listed as a primitive
  axiom** (`chapters/03-proof-theory.typ:78-80`), but the paper derives TF as a **theorem** from
  MF+MT+TD (`:1127-1132`). If Lean genuinely axiomatizes TF as primitive (rather than deriving
  it), that is a legitimate implementation choice, but the Typst reference should say so explicitly
  rather than silently presenting it as if it mirrors the paper's more economical axiomatization —
  or, if Lean also derives TF from MF/MT, the Typst doc should move TF out of "Proof Theory" into
  `05-theorems.typ` where the derivation is shown (paper style).
- **Missing**: TD (temporal duality *rule*) is correctly placed as a Rule (matches paper, see
  `chapters/03-proof-theory.typ:143-148` "Temporal Duality"), not an axiom — this part is fine.
  MP/MN are represented via "Modus Ponens"/"Necessitation" rules — also fine.

### Task Frame Definition Gap (Reflection axiom missing)

Paper (`possible_worlds.tex:902-907`):
```
F = ⟨W, D, ⇒⟩ where ⇒ satisfies:
  Nullity:          w ⇒₀ w
  Reflection:       if w ⇒ₓ u then u ⇒₋ₓ w
  Compositionality: if w ⇒ₓ u and u ⇒_y v then w ⇒_{x+y} v
```

Typst (`chapters/02-semantics.typ:34-38`):
```
definition("Task Frame")[
  cal(F) = (W, D, ⇒) satisfying:
  + Nullity: ...
  + Compositionality: ...
]
```

Reflection is entirely absent — not just unstated in prose but missing as a numbered constraint.
`notation/bimodal-notation.typ:88-95` defines `leanNullity` and `leanCompositionality` raw-Lean
cross-reference macros but no analogous `leanReflection` macro, consistent with the omission being
a real content gap rather than a stylistic choice. Whoever revises `02-semantics.typ` will need a
new macro (e.g. `#let leanReflection = raw("...")`) once Teammate A/the implementer confirms the
Lean identifier for this constraint (likely something like `TaskFrame.reflection` or similar,
possibly folded into a different name — this is exactly the kind of naming fact that should come
from the Lean-priority pass, not be guessed here).

### Internal Contradiction: Strict vs. Reflexive Temporal Semantics

This is the single most important structural issue I found, because it is not merely a
paper-vs-Typst mismatch but a **self-contradiction inside the current Typst document**:

- `chapters/02-semantics.typ:76-90` (`definition("Truth")`) states:
  ```
  M,τ,x ⊨ Hφ  iff  M,τ,y⊨φ for all y:D where y < x
  M,τ,x ⊨ Gφ  iff  M,τ,y⊨φ for all y:D where x < y
  ```
  — **strict** inequalities, matching the paper's own truth clauses exactly
  (`possible_worlds.tex:948-949`: "$y < x$" / "$x < y$").
- `chapters/04-metalogic.typ:154` footnotes "The T-axiom (`Gφ→φ`) is *not* valid in TM logic
  because G/H use strict semantics" — consistent with the above.
- But `chapters/06-notes.typ:99-345` ("Design Choices") spends an entire section
  (`definition("Reflexive Temporal Semantics (Current)")` at line 118, plus a large "Design
  Rationale for TM" discussion at lines 313-344) arguing at length that reflexive semantics
  (`y ≤ x`) is the **current** choice, citing specific task history ("Task 658: Confirmed
  reflexive... Task 991: Strict... Task 29: Reflexive (IRR proof broken under strict)") and
  claiming "This matches the truth conditions in @sec:truth" (`chapters/06-notes.typ:125`) — a
  cross-reference to the very `02-semantics.typ` section that in fact states the *strict* clauses.

This is a direct contradiction inside the current document: `02-semantics.typ` and the paper agree
on strict semantics; `04-metalogic.typ`/`06-notes.typ` claim reflexive semantics is current and
mis-cite `02-semantics.typ` as supporting that claim. Given the task's stated priority ("accuracy
with the substantially-changed Lean 4 source code as the first priority"), resolving this must be
the *first* fact established before revising any of these three chapters — whichever semantics the
current Lean source actually implements determines which of `02-semantics.typ` or
`04/06-*.typ` needs to change, and the design-choices narrative in `06-notes.typ` (Sections
"Algebraic Classification" through "Design Rationale for TM", ~150 lines) may need to be
discarded, rewritten, or kept depending on that answer. I flag this for both teammates and the
synthesis/implementer: **do not silently revise one side to match the other without first checking
the actual Lean truth-condition definitions** (`Semantics/` per `00-introduction.typ:88`).

### `06-notes.typ`'s Existing Discrepancy Section is Stale

`chapters/06-notes.typ:34-97` already contains a "Discrepancy Notes" section that attempts exactly
the kind of paper-vs-Lean reconciliation this task calls for, including an "Axiom Naming" table
(lines 46-68) with a "Paper Name" column. That column lists `MT (Modal T)`, `M4 (Modal 4)`,
`MB (Modal B)`, `MK`, `TK`, `T4`, `TA`, `TL`, `MF`, `TF` as if these are all axiom names used by
the paper. Per my reading of the current paper text, the paper's TM system (§3.2) does use MT, MK,
TK, T4, TA, TL, MF as primitive axiom names, but it does **not** use M4 or MB as axiom names at
all (S5 is obtained without them), and it explicitly derives TF as a theorem rather than naming it
as an axiom. This strongly suggests `06-notes.typ`'s discrepancy table was written against an
earlier draft of the paper that *did* axiomatize M4/MB/TF directly (plausible, since papers evolve)
and has not been updated since the paper reached its current, more economical axiomatization. The
entire "Discrepancy Notes" and "Design Choices" sections of `06-notes.typ` (lines 34-345, i.e. most
of the chapter) should be treated as a prime target for systematic revision, not incremental
patching — the underlying axiom-naming facts need to be re-verified from scratch against both the
current paper and current Lean source before this table is rewritten.

### Typst Authoring Infrastructure Mechanics

- **Entry point**: `BimodalReference.typ` imports `notation/bimodal-notation.typ` (which itself
  imports `notation/shared-notation.typ`) and `template.typ`, sets document/page/heading options,
  builds a title page (already correctly citing the paper's actual title "The Construction of
  Possible Worlds" and current PDF URL — `BimodalReference.typ:97-100`), then `#include`s the six
  chapter files in order (`:143-149`).
- **Theorem environments**: `template.typ` wraps `@preview/thmbox:0.3.0` (NOT `great-theorems` as
  `README.md:43` claims — the README's package-dependency line is itself stale/wrong and should be
  corrected as part of any infrastructure cleanup) into `definition`, `theorem`, `lemma`, `axiom`,
  `remark`, `proof` with AMS-style formatting (definitions upright, theorems/axioms italic body).
  Chapters use these directly, e.g. `#definition("Formula")[...]`, `#axiom("MT - Modal T")[...]`.
- **Notation macros** (`notation/shared-notation.typ` + `notation/bimodal-notation.typ`): connectives
  (`nec`=□, `poss`=◇, `imp`=→, `lneg`=¬, `falsum`=⊥), turnstiles (`proves`=⊢, `trueat`/`satisfies`=⊨,
  `ntrueat`/`notsatisfies`=⊭), temporal operators (`allpast`=H, `allfuture`=G, `somepast`=P,
  `somefuture`=F, `always`/`sometimes`=▵▽ triangles), frame/model structure (`taskframe`=𝓕,
  `Dur`=𝓓, `worldstate`=W, `taskrel`=R, `taskto(x)` builds the `⇒ₓ` arrow, `model`=𝓜), history
  (`history`=τ, `althistory`=σ, `domain`="dom", `histories`=H), and a small set of raw-Lean
  cross-reference identifiers (`leanTaskRel`, `leanTimeShift`, `leanRespTask`, `leanConvex`,
  `leanDomain`, `leanStates`, `leanNullity`, `leanCompositionality`). To add a Reflection macro,
  discrete/dense/complete-extension axioms, or Since/Until operators (if ever brought in from the
  paper's TM+ extension), new `#let` macros belong in `bimodal-notation.typ`, following the
  existing naming convention (plain-English descriptive names, not the paper's LaTeX command
  names).
- **Compilation**: `README.md:9-19` documents `typst watch BimodalReference.typ
  build/BimodalReference.pdf` for live preview and `typst compile ... build/BimodalReference.pdf`
  for production; a pre-existing `BimodalReference.pdf` sits at the top level of `typst/` (outside
  `build/`), which is inconsistent with the README's documented output path — worth normalizing
  (either delete the stray top-level PDF or update `.gitignore`/README to match actual practice).
  `chapters/README.md` and `notation/README.md` are simple content indices and don't need
  structural changes, only date-stamp/content refreshes if the chapter set or notation files
  change.

### Notation Alignment (Paper vs. Typst) — Mostly Consistent

Good news: most core notation already matches cleanly and needs no revision:

| Concept | Paper | Typst macro |
|---|---|---|
| World states | $W$ | `worldstate` = `$W$` (`bimodal-notation.typ:38`) |
| Temporal order | $\D$ | `Dur` = `$cal(D)$` (`:37`) |
| Task frame | $\F$ | `taskframe` = `$cal(F)$` (`:36`) |
| Task relation | $w \Rightarrow_x u$ | `taskto(x)` builds `⇒ₓ` (`:41-42`) |
| World history | $\tau$ | `history` = `$tau$` (`:49`) |
| Alt. history | $\sigma$ | `althistory` = `$sigma$` (`:50`) |
| Necessity | $\Box$ | `nec`/`square.stroked` (shared-notation.typ:14) |
| Possibility | $\Diamond$ | `poss`/`diamond.stroked` (:15) |
| Always/Sometimes | $\always$/$\sometimes$ (rotated triangles) | `always`/`sometimes` = stroked triangles (`bimodal-notation.typ:25-26`) |
| Temporal swap | $\varphi_{\langle P\vert F\rangle}$ | `swap` = `$chevron.l S chevron.r$` (`:29`) — note: paper writes this inline as a subscript notation, Typst uses a named `⟨S⟩` prefix operator; both are legitimate encodings of the same swap function, but if the revision quotes the paper's exact subscript style anywhere, be aware the Typst rendering convention differs by design (this was presumably a deliberate typesetting choice, not an error). |

No action needed on these unless the paper's *notation itself* changed since Typst was last
synced (I cannot tell from a single reading whether these were already revised to match a prior
draft — Teammate A/implementer should diff against git history if in doubt).

## Recommended Approach

1. **Resolve the strict-vs-reflexive semantics contradiction first**, by inspecting the actual Lean
   truth-condition definitions in `Semantics/`. This single fact determines which of
   `02-semantics.typ` (Truth Conditions) or `04-metalogic.typ`/`06-notes.typ` (Design Choices) is
   correct, and therefore which one to keep, rewrite, or delete. Given the task's Lean-priority
   framing, this should be settled before touching prose in either chapter.
2. **Rebuild `03-proof-theory.typ`'s axiom list from the actual Lean `Axiom` inductive type**
   (Teammate A's/implementer's territory), then reconcile against the paper's 12-schema TM system
   documented above (MP, MN, MK, MT, M5, MF, TD, TK, T4, TB, TA, TL). Expect to: add TB; fix or
   confirm TL's formula; decide whether M4/MB are genuinely present as separate Lean axiom
   constructors (if so, keep them but correct the "Paper Name" framing in `06-notes.typ` to not
   claim the paper names them); decide whether TF is a Lean axiom or a derived theorem (move to
   `05-theorems.typ` if the latter, mirroring the paper's own derivation at `:1127-1132`).
3. **Add the missing Reflection constraint** to `chapters/02-semantics.typ`'s Task Frame
   definition, with a new notation macro in `bimodal-notation.typ` once the Lean identifier is
   known.
4. **Rewrite `06-notes.typ`'s "Discrepancy Notes" and axiom-naming table wholesale** rather than
   patch it — it is demonstrably out of sync with the current paper text (references M4/MB as
   paper-named axioms; the paper does not name them).
5. **Decide scope on the paper's §3.3 "Extensions"** (discrete/dense/complete temporal orders;
   TM_f/TM_d/TM_c/TM_dc; DF/DN/CO axioms) and §3.1 "Restricted Modalities" (Stability, Openfuture,
   Openpast, Nomic operators) — neither is currently represented as reference content in any
   chapter (only tangential mentions of DF/DN in `06-notes.typ`'s unrelated
   strict-vs-reflexive discussion). If the Lean source formalizes any of these, they belong in
   new subsections of `02-semantics.typ`/`03-proof-theory.typ`; if not formalized, a one-line
   "not yet implemented" note (in the style already used in `06-notes.typ`'s status tables) is
   more honest than silence.
6. **Fix `README.md`'s stated package dependency** (`great-theorems` → `thmbox`, matching
   `template.typ:10`) and reconcile the stray top-level `BimodalReference.pdf` with the documented
   `build/` output convention.
7. Leave the notation macro system and chapter-inclusion mechanics untouched — they are sound and
   need no structural changes, only additive macros for new content.

## Risks & Mitigations

- **Risk**: Fixing chapter 02/04/06's semantics contradiction by editing prose alone (without
  checking Lean) could "fix" the document to be internally consistent but wrong relative to the
  actual formalization. **Mitigation**: treat this as a Lean-priority blocking question, not a
  prose-consistency question; get the answer from Teammate A/the Lean source before editing any
  of these three chapters.
- **Risk**: Correcting axiom lists (adding TB, fixing TL, resolving M4/MB/TF status) purely from
  the paper's text could contradict what the Lean source actually implements, if the Lean
  formalization is ahead of or diverged from the current paper draft (the task explicitly warns
  paper and Lean "may disagree," with Lean as the priority). **Mitigation**: every axiom-table
  change should be double-checked against the actual `Axiom` inductive constructors before landing,
  even where the paper is unambiguous — the paper drives narrative/exposition, Lean drives ground
  truth for what to assert is formalized.
- **Risk**: The paper's §3.3 Extensions and §3.1 Restricted Modalities represent substantial new
  content not currently in the Typst doc at all; adding full chapters for these could be a large
  scope increase beyond "revise for alignment." **Mitigation**: default to a scoped decision
  (documented in step 5 above) rather than open-ended expansion — a short "not currently
  formalized" note is an acceptable, low-risk outcome if Lean doesn't cover this territory.

## Context Extension Recommendations

- **Topic**: Paper-vs-Typst reference-manual synchronization workflow.
- **Gap**: There is no documented process (in `.claude/context/`) for keeping a Typst reference
  manual in sync with an evolving companion paper + Lean source across three parties (paper prose,
  Lean formalization, Typst exposition). This task surfaced a nontrivial three-way inconsistency
  that a lighter-weight periodic sync check might have caught earlier.
- **Recommendation**: Not urgent enough to spawn a context file for; a note in this task's
  implementation summary recommending periodic (e.g. per-major-paper-revision) `--lit`-assisted
  re-checks of `06-notes.typ`'s discrepancy tables against the paper would suffice.

## Appendix

### Search Queries / Commands Used

- `wc -l` and `find` to size the paper and enumerate the Typst directory tree.
- `grep -n '^\\section\|^\\subsection\|^\\subsubsection'` to extract the paper's structural spine.
- `grep -n 'aitem\['` to extract every named axiom/theorem label and its formula across the paper
  (both the base TM system at `:446-447`/`:1091-1104` and the extended TM+ system at
  `:3166-3262`).
- `grep -n '\\begin{definition}\|\\begin{Tthm}\|...'` to locate all numbered definitions/theorems.
- `grep -n 'Task Frame\|task relation\|world state\|world history\|Duration\|duration'` to locate
  the core semantic construction section.
- `grep -n 'Discrete\|Dense\|Complete\b\|DF\b\|CO\b\|TM_f\|TM_d\|TM_c\|Reflection'` across
  `chapters/*.typ` to confirm the Extensions material and Reflection constraint are absent from
  the current Typst chapters.

### Files Read in Full

- `possible_worlds.tex` lines 1-450, 899-1300 (in detail), plus targeted greps across the whole
  3473-line file for structure and axiom labels.
- `Theories/Bimodal/typst/BimodalReference.typ` (full)
- `Theories/Bimodal/typst/template.typ` (full)
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` (full)
- `Theories/Bimodal/typst/notation/shared-notation.typ` (full)
- `Theories/Bimodal/typst/notation/README.md`, `Theories/Bimodal/typst/README.md`,
  `Theories/Bimodal/typst/chapters/README.md` (full)
- `Theories/Bimodal/typst/chapters/00-introduction.typ` through `06-notes.typ` (all six, full)

## Confidence Level

**High** for: paper's core TM axiom list and its line citations; the presence of the
strict-vs-reflexive contradiction between `02-semantics.typ` and `04/06-*.typ`; the missing
Reflection constraint in the Task Frame definition; the missing TB axiom and mismatched TL formula
in `03-proof-theory.typ`; the Typst infrastructure mechanics (imports, template, notation,
compilation).

**Medium** for: whether M4/MB/TF are genuine primitive constructors in the current Lean `Axiom`
type (I read only the Typst-side claims about Lean identifiers, not the Lean source itself — this
is explicitly Teammate A's territory) and whether any part of the paper's §3.1/§3.3 material is
already formalized in Lean under different chapter framing than I searched for.

**Low/Flagged for follow-up**: whether the stray top-level `BimodalReference.pdf` and README's
`great-theorems` reference are meaningful signals of a needed infrastructure fix versus harmless
build artifacts — worth a quick confirmation but not central to the revision.
