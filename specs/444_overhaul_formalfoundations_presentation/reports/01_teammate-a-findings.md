# Teammate A Findings — Primary Approach for `typst/FormalFoundations.typ` Overhaul

**Scope**: primary skeleton, FIX-tag resolution, Lean verification, style specimen. Research
only — `typst/FormalFoundations.typ` was read but not edited.

---

## Key Findings

1. **11 FIX tags confirmed**, all catalogued below with line numbers, context, and a concrete
   resolution. Three of them (lines 135, 113, 231) are not stylistic — they identify a genuine
   mathematical error and two scope-narrowing decisions that reorganize the whole document.

2. **The atom-interpretation clause is factually wrong**, not just inelegant. The current text
   (`typst/FormalFoundations.typ:135-136`) states `|p| ⊆ H_F × D` (atoms as sets of world-history/time
   pairs). The paper defines atoms as subsets of **world states**: `def:BL-model`
   (`possible_worlds.tex:2876-2878`) gives `|p_i| ⊆ W`, and the atomic truth clause in
   `def:BL-semantics` (`possible_worlds.tex:2892`) is `M,τ,x ⊨ p_i` **iff** `τ(x) ∈ |p_i|` — truth
   at a time is mediated entirely through which world state the history occupies there, not
   through a direct history×time relation. This is exactly the point Dana's email
   (`other/dana.md:5`) says the paper is built to defend (partial histories as *restrictions* of
   total ones, world states occurring at times) — the current formula in the .typ document directly
   contradicts the architecture the FIX author is pointing at.

3. **A second, previously undetected discrepancy**: the Since/Until argument-order gloss at
   `typst/FormalFoundations.typ:117` labels the paper's own `S(φ,ψ)`/`U(φ,ψ)` notation as the
   "Burgess *event-first* convention" with φ the event and ψ the guard. This is backwards relative
   to the paper. `possible_worlds.tex:3816-3817` (footnote to `def:BLplus-semantics`) states
   explicitly: the paper's own surface notation `φ Since ψ` / `φ Until ψ` is **guard-first** (φ the
   guard, holding throughout the interval; ψ the event, true at the witness time) — it is the
   **Lean repository's** `snce`/`untl` constructors that are event-first, not the paper's `S`/`U`.
   The semantic clause itself, `def:BLplus-semantics` (`possible_worlds.tex:3820-3823`): `M,τ,x ⊨
   φSψ` iff `∃z<x. M,τ,z⊨ψ ∧ ∀y∈(z,x). M,τ,y⊨φ` — φ is the interval-wide guard, ψ the witnessed
   event. Since FIX-113 asks the document to align to the paper's own `BL^+` notation (not the
   Lean internal convention), this mislabel must be corrected, not merely reworded.

4. **The paper has moved on since task 443's research** (both were dated 2026-08-13, but the live
   paper now contains material the prior research reports do not mention): a full topology
   apparatus (`def:task-topology`, `possible_worlds.tex:2622-2632`) built from the frame's cones as
   a basis, with **T1** (`app:topology-t1`, :2653-2666) and **R0** (`app:topology-r0`, :2673-2680)
   proved for every frame. This is precisely what Dana's email flags as the motivating result
   (`other/dana.md:5`, "footnote 38... T1... appendix"). The current `.typ` document has *no*
   mention of the topology at all. Given the task's explicit framing ("review the email... regarding
   the paper") and Dana's own first paragraph being about exactly this material, the rewritten
   §1 (system layer) should add a short subsection or remark stating the topology and its T1/R0
   status as the formal payoff motivating the total-world-history restriction — this is new
   content relative to what task 443 planned for, not just a restyling of existing text.

5. **Lean verification (all four flagship theorems and the newly-checked construction pieces
   re-confirmed live and matching their .typ citations)** — table in Section "Lean Verification"
   below. No overclaiming was found beyond the `|p|` error (finding 2) — the sorry/axiom counts in
   the current `.typ` document (lines 327, and elsewhere) match a fresh re-run of
   `scripts/typst-status-counts.sh --json` byte-for-byte (only `stamp_commit` moved,
   `f231a8775`/`c2b8da5d6`(task-443-baseline) → `2d57928fa`(now); every count identical:
   `sorry_total=5, sorry_total_excl_boneyard=1, sorry_algebraic=0, sorry_bxcanonical=0,
   sorry_bundle=0`). The document's status claims are current and can be re-stamped rather than
   re-derived.

---

## Recommended Approach

### A. FIX-tag resolution (all 11, verbatim, in file order)

**1. Line 93** — `// FIX: no indent here, and smaller font, creating an environment as appropriate`
   Context: precedes `*Abstract.*` set as plain bold-italic paragraph text at `:94-105`, inheriting
   the document's `first-line-indent: 1.8em` and 11pt body size.
   **Resolution**: wrap the abstract in a dedicated block, e.g. `#block(inset: (x: 0.3em))[#set
   par(first-line-indent: 0em); #set text(size: 10pt); *Abstract.* ...]` — matches the common
   AMS-article convention (no first-line indent, one point size down from body). No existing
   `template.typ` macro does this; a 3-line local `#let abstract-block(body) = {...}` at the top of
   `FormalFoundations.typ` (not `template.typ`, since this is a standalone-report convention, not
   shared with the book) is the right scope for the change.

**2. Line 113** — align notation/definitions with the paper; use `BL^+` as the paper's own symbol
   throughout, drop `BL` to at most a grounding footnote with the arXiv-style link.
   **Resolution**: restructure §1 (`= The System, Compressed`) so the *primary* exposition is
   `BL^+` (Since/Until as the two primitive tense operators, per the task's own reiterated
   instruction at line 231), with `BL` (Past/Future primitive) demoted to a single footnote citing
   `def:BL-language` (`possible_worlds.tex:2583-2585`) plus the link
   `https://benbrastmckie.com/publications/possible_worlds.pdf`. This also resolves the "Burgess
   event-first" mislabeling (finding 3): once the exposition centers `BL^+`'s own guard-first `S`/`U`
   convention, the footnote can state the Lean-vs-paper argument-order distinction *correctly*, in
   the direction the paper itself states it (repository event-first, paper guard-first), if it is
   mentioned at all — for a reader unfamiliar with the Lean internals (Dana), it may be simplest to
   drop the Lean-argument-order footnote entirely and just present the paper's own guard-first
   clause, which is materially simpler for a first-time reader.

**3. Line 123** — the converse convention deserves its own definition; so do fiber/cone/segment,
   indented for visual clarity.
   **Resolution**: split the current run-on paragraph (`:124`) defining temporal order, task
   relation, converse convention, fiber, cone, segment all in one sentence into: `#definition("Temporal
   Order")` (`def:temporal-order`), `#definition("Task Relation")` (`def:task-relation`, itself with
   indented labeled clauses for Fiber/Cone/Segment exactly as the paper's own `enumerate` at
   `possible_worlds.tex:2593-2597` does), and a short standalone remark or definition-clause for the
   converse convention. This mirrors the paper's own presentation almost exactly, which already
   separates the notions cleanly — the .typ document is compressing what the paper keeps distinct.

**4. Line 126** — the Frame definition feels scrunched; expand into indented elements "and similarly
   throughout what follows as appropriate."
   **Resolution**: the existing `#definition("Frame")[...]` block (`:127-129`) already uses inline
   prose for the four axioms (Compositionality/Seriality/Limit/Spherical) where the paper uses a
   labeled `enumerate`. Replace with an indented list inside the `#definition` block — Typst's
   `template.typ` `items`/`item` helpers (`template.typ:126-139`) are the exact fit already used
   elsewhere in the book (grep `04-metalogic.typ`/`02-semantics.typ` for precedent before inventing
   new list styling). Apply the same treatment to `def:world-history` (currently one dense sentence
   at `:133`, should separate partial/world/total/possible-world/`H_F` as the paper's own definition
   does at `possible_worlds.tex:2707-2714`) and to `def:constraints`/segment apparatus if retained.

**5. Line 135** — `|p| ⊆ H_F × D` is wrong and "offends the most fundamental ideas" of the paper;
   requires a full-document faithfulness pass.
   **Resolution** (the load-bearing fix): replace with `|p_i| ⊆ #worldstate` (i.e. `W`, using the
   existing `#worldstate` notation macro), and correct the atomic truth clause to `#truthat(M, tau,
   x, p_i)` iff `tau(x) in |p_i|` — matching `def:BL-model`/`def:BL-semantics` exactly (see Finding
   2). This propagates: every place the .typ document currently paraphrases atom valuation, model
   structure, or the Box clause (`:136`, roughly right already — "iff M,σ,x⊨φ for every σ∈H_F" does
   match `def:BL-semantics`'s Box clause at `possible_worlds.tex:2899`) needs a fresh line-by-line
   check against `def:BL-model`/`def:BL-semantics`/`def:frame-validity`/`def:logical-consequence`
   (`possible_worlds.tex:2876-2904, 3053-3055, 3576-3580`) rather than trusting the existing prose.
   I did this cross-check for the system layer (§1 of the target skeleton below); it is otherwise
   sound once `|p|` is corrected — the Box clause, frame-validity clause, and logical-consequence
   clause all match the live paper text.

**6. Line 174** — the correspondence table (DF/DN/CO ↔ Discrete/Dense/Complete) is "poorly stated
   and confusing"; the section needs to "drill down to the Henkin constructions" instead.
   **Resolution**: this table belongs to §2 (Key Theorems) and is fine to keep *compressed* per the
   task description's own remit (task 443's research report explicitly flags these as NOT the
   "give in full" exceptions) — but the FIX is really asking for something the current document
   never delivers anywhere: a genuine walk-through of the **canonical-model construction**. That
   content belongs in the construction section (§6 of the current document, FIX at line 285, below),
   not here. Resolution for *this* specific FIX: keep the correspondence table compact (statement +
   one-line idea, as task 443's research already scoped it) but delete the vague framing prose
   around it and let §6 carry the actual formal weight the FIX is asking for.

**7. Line 189** — remove all self-referential meta-commentary ("Stated Exactly, Unsoftened");
   write like an advanced textbook, not commentary on itself; the completeness/decidability section
   has "virtually no substance."
   **Resolution**: rename the section heading from `== Completeness -- Stated Exactly, Unsoftened`
   to plain `== Completeness`; delete every self-referential aside throughout the document in this
   register (a systematic pattern — see the "Structural Audit" section below for a full inventory
   of this voice problem, which recurs far beyond this one heading). Replace the current
   `#theorem("Completeness")[...]` block, which is one dense dump-everything paragraph naming five
   systems and five completeness/incompleteness facts in a single sentence, with a numbered
   statement-per-system-class structure (see target skeleton §2).

**8. Line 208** — Pain Point One (contingency of the temporal axioms) is poor quality; "EVERY ISSUE
   should be introduced through a formal lens."
   **Resolution**: the current section already contains the raw material (the irregular-worlds
   quote is transcribed correctly and verbatim per task 443's citation package) but wraps it in
   editorializing headers ("*The worry, at full strength.*", "*The price, stated exactly*") that
   read as stage directions rather than mathematics. Rewrite as: a `#definition` for irregular
   worlds/coset domains (currently only inside a block quote, never formalized as an actual
   definition environment), a `#remark` stating the necessity-if-true argument formally (frame
   validity closed under necessitation — this is a one-line formal fact, not a paragraph of prose),
   and a `#theorem`-or-`#proposition` stating "The Price" as an actual four-part logical claim (DN
   valid nowhere; DF fails over `ℚ ×_lex ℤ`; the three correspondences collapse; `□` is displaced
   from `Str^O_L`-status) rather than narrated prose bullets.

**9. Line 231** — drop the TM-level split-validity section entirely; focus exclusively on `BL^+`
   with Since/Until as the only primitive tense operators.
   **Resolution**: this is the single largest structural decision in the whole rewrite. Delete
   current §4 (`= Pain Point Two: Split Validity and TM's Semantic Incompleteness`) as a *named
   pain point*, but do not discard its content outright — the (DD) split-validity phenomenon is the
   load-bearing example that motivates the three-way case split driving the actual completeness
   *construction* (§6 of the current document explicitly says so at `:317`, "the same discrete/dense
   dichotomy… is what the BL⁺ completeness architecture case-splits on"). Fold a compressed version
   of (DD) — stated for `BL^+` directly via `¬Next⊤`, not via the TM-level schema — into the
   completeness-construction section as the motivating example for the three-way split, rather than
   as an independent "pain point." This both satisfies FIX-231 (TM-level material dropped) and
   FIX-285 (the construction section needs the discreteness-indicator case split motivated
   formally, not asserted).

**10. Line 285** — the completeness-construction section needs to be "completely rewritten,"
    presenting the Henkin construction in precise formal detail, citing literature, removing
    "pointless declarations."
    **Resolution**: this is the section that should absorb the request from FIX-174 (drill into
    Henkin mechanics) and FIX-231 (motivate via the `¬Next⊤` split, not TM's split-validity). Write
    it as: (i) a `#definition` of MCS/Lindenbaum via `set_lindenbaum`
    (`Metalogic/Core/MaximalConsistent.lean`); (ii) a `#theorem`("Three-Way Case Split") stating the
    trichotomy on `□(¬Next⊤)`/`¬□(¬Next⊤)`/mixed, with the mixed case eliminated by
    `mcs_mixed_case_absurd` (verified live, see Lean Verification table); (iii) per-branch
    `#definition`+`#theorem` pairs for the dense (Burgess chronicle over `ℚ`, `singletonChronicle →
    omegaChain → limit_chronicle`) and discrete (Reynolds/Doets over `ℤ`,
    `countermodel_discrete_reynolds_v2`) canonical models, each with the actual truth-lemma shape
    (what does the Box case need — BFMCS `modal_forward`/`modal_backward` coherence) rather than
    naming the module and moving on. Cite Burgess 1982 and Reynolds 1992/Doets 1987 (already in
    `bibliography.bib` per task 443's audit) at the relevant construction, not just in a trailing
    footnote list. Delete the "Terminology, settled project-wide" paragraph defining "strong
    completeness" — the FIX explicitly calls this "entirely obvious" and it does not need a
    paragraph; fold the one substantive fact (finite `Context` ⇒ weak/consequence-completeness
    coincide) into a single parenthetical where consequence-completeness is first used, if at all.

**11. Line 337** — the representation-theorem section needs the same treatment: precise formal
    mechanics only, remarks reserved for the most substantive reflection points.
    **Resolution**: cut the historical-waypoint subsection (`== A Superseded Waypoint, Heeded`,
    `:339-341`) down from a four-point defect list to at most one sentence + footnote — a reader
    like Dana does not need four numbered defects of an unpublished, non-`\input`-ed draft; state
    only that an earlier sketch is superseded and why the live architecture differs (BFMCS
    coherence vs. hand-waved global agreement), one sentence. Keep the algebraic-layer inventory
    (`Metalogic/Algebraic/`) as a `#definition`/`#remark` pair stating precisely what exists
    (Lindenbaum–Tarski algebra, ultrafilters, interior operators — sorry-free) vs. targets
    (shift-set, Jönsson–Tarski), and compress the "Way Forward" six-point list (a)-(f) into the
    two or three points the task description itself calls out as substantive: the *Spherical*
    discharge-pattern analysis and the group-structure-as-crux argument (task 443's research §8
    already flags these explicitly as "this report's own analysis... squarely the job of the
    report to write"). The remaining points (disjoint-union closure, algebraic-vs-shift-set,
    adequacy standard, foreclosure) can be compressed into a single closing remark rather than five
    separate lettered blocks.

### B. Structural audit of the current document

Actual section skeleton (headings only, with line numbers):

```
Title/Abstract                                              :77-107
1  The System, Compressed                                   :109
  1.1 Languages                                              :111
  1.2 Task-Frame Semantics                                   :121
  1.3 Proof Systems                                          :138
2  Key Theorems, Completeness Status, and Decidability       :160
  2.1 Existence, Soundness, Correspondence                   :162
  2.2 Perpetuity and the Collapse Theorems                   :183
  2.3 Completeness -- Stated Exactly, Unsoftened             :190
  2.4 Decidability -- Faithfully Open                        :200
3  Pain Point One: Contingency of the Temporal Axioms        :206
4  Pain Point Two: Split Validity and TM's Semantic Incompl.  :229
5  Pain Point Three: Axiomatizing the Strongest Obj. Modality :271
6  The Completeness Construction as Implemented Here         :283
7  Early Representation Work and the Way Forward             :335
  7.1 A Superseded Waypoint, Heeded                          :339
  7.2 What Actually Exists: The Algebraic Layer, and Only It :343
  7.3 The Way Forward                                        :376
```

**Where the narrative arc breaks, specifically:**

- **§1→§2 has no bridge.** §1 ends with a table of axiom systems (`:144-158`) and a terminology
  paragraph distinguishing TM from BX. §2 opens `== Existence, Soundness, Correspondence` with zero
  transition sentence connecting "here is the system" to "here is what we can prove about it." A
  reader arriving at §2 does not know *why* soundness/correspondence/completeness is the next
  natural question, because §1 never states what completeness *would* buy epistemically.
- **§2.3's theorem block is an information dump, not an argument.** The single `#theorem`
  (`:192-194`) states five systems' soundness, non-completeness, and (separately) which BL⁺ variant
  carries completeness, all in one unbroken sentence — this is the section FIX-189 flags as having
  "virtually no substance," and it is right: naming five systems in one clause is compression
  without exposition. There is no walk from "why would TM fail to be complete" to "here is the
  actual failure" (that walk exists, but three sections later, in §4).
  the reader has no cognitive bridge until §4, three sections later.
- **§3, §4, §5 are three independent "pain points" with no ordering logic given.** Nothing in the
  prose explains *why* contingency (§3) comes before split-validity (§4) comes before objective
  modality (§5) — they read as an enumerated list of separate worries rather than a developing
  argument. (§3's closing line does gesture at §4 — "@sec:split-validity develops exactly why" — but
  only in one direction and only at the very end.) Per FIX-231, §4 is slated for removal as an
  independent section anyway, which will partially fix this — but §3 and §5 still need an explicit
  connective tissue statement for why *these two* and *only these two* remain, once §4's content is
  folded into §6.
- **§6 (the actual completeness construction — the mechanical heart of the whole report) arrives
  fifth, after all three pain points**, even though it is the section that actually explains *how*
  the systems that are complete get proved complete. A reader who wants "the core mechanics of the
  existing completeness results" (the task's own payload #1) has to read through three pain-point
  sections first to reach it. This is the single biggest structural fix: **move the construction
  section forward**, immediately after the completeness/decidability status statement (current §2),
  so the reader sees *what is proved* and then immediately *how* — pain points (contingency,
  objective modality) come after, as open philosophical/technical costs, not before.
- **§7 (representation) is the only section that states a clear forward-looking payload** ("what
  actually exists" vs. "what is a target" vs. "what is archived") — this is actually the
  best-organized section in the current document, and the target skeleton below should treat it as
  the model to emulate for the others (live/target/archived status-marking discipline), not just
  the section that happens to close the document.

### C. Proposed target skeleton

Ordered to land the three payloads named in the task (completeness mechanics, decidability status,
representation direction) as directly as possible, following `BL^+` throughout per FIX-113/231.

| # | Section | Role in arc | Must contain | Approx. length |
|---|---|---|---|---|
| 1 | **The System** | Ground the reader in `BL^+`, task frames, and the paper's own semantics with zero drift from `possible_worlds.tex` | `def:temporal-order`, `def:task-relation` (Fiber/Cone/Segment as separate labeled clauses), `def:frame` (four axioms as an indented list), `def:world-history` (partial/total/possible-world), brief mention of the T1/R0 topology result (Finding 4) as the payoff motivating the total-history restriction, `def:BL-model`/`def:BL-semantics` corrected per Finding 2, `def:BLplus-language`/`def:BLplus-semantics` (Since/Until, paper's own guard-first clause) as primary, `BL` demoted to one footnote. | ~1.5 pages |
| 2 | **What Is Proved: Completeness and Decidability, Stated Exactly** | Land payload #1 (status) and payload #2 (decidability) immediately, before any pain point | Soundness (one theorem, all five systems, compressed); the three correspondence theorems (table, compressed, as now); completeness stated **per-system, not one dense paragraph** (TM/TM_f/TM_d/TM_c/TM_dc sound-not-complete; `BL^+` variants' completeness broken out by frame class with sorry-free status cited); decidability stated as open with the FMP retraction and the two witnesses (DF over ℤ, CO over `ℤ ×_lex ℤ`) given as actual formal facts, not narrated. | ~1.5 pages |
| 3 | **The Completeness Construction** *(moved forward from current §6)* | Land payload #1's mechanics directly — this is the section a reader who wants "how" reads | MCS/Lindenbaum; the `¬Next⊤` three-way case split (absorbing the compressed (DD)-for-`BL^+` example per FIX-231/174, motivating *why* the split is needed rather than asserting it); dense path (Burgess chronicle over ℚ) and discrete path (Reynolds/Doets over ℤ) each as definition+theorem pairs with the actual truth-lemma mechanism (BFMCS coherence) stated, not just named; Dedekind path; sorry/axiom status table (re-measured). | ~2.5 pages |
| 4 | **Two Costs of the Semantics** *(merges current §3 and §5)* | The philosophical/technical costs Dana is specifically asking about (contingency, per `other/dana.md:7`) | (a) Contingency: irregular worlds, formalized as an actual `#definition`, the quoted price as a `#proposition`/`#theorem`, defense argument compressed to the closure-under-necessitation fact. (b) Strongest objective modality: `Str^O_L`, existence/uniqueness, the Stability-operator orthogonality point. Both written as formal statements with remarks only where they expose the substantive tension, per FIX-208/337's register demand. | ~2 pages |
| 5 | **Toward a Representation Theorem** *(current §7, kept as the strongest-organized section, tightened per FIX-337)* | Land payload #3 directly | Live algebraic layer (Lindenbaum–Tarski, ultrafilters) marked live; shift-set and Jönsson–Tarski marked target/archived explicitly; the two-or-three substantive way-forward points (Spherical discharge patterns, group-structure-as-crux) stated formally rather than six lettered prose blocks; adequacy standard quoted once. | ~1.5 pages |

Total: roughly the same ~9-page budget as the current document's stated "~10 pages" target, but with
the construction promoted ahead of the pain points and the pain-point count reduced from three
named sections to two, per FIX-231's explicit instruction.

### D. Lean Verification

| Theorem/claim in `.typ` | Lean declaration | File:line | Status |
|---|---|---|---|
| `completeness_dense` (dense-frame weak completeness) | `theorem completeness_dense` | `FormalSystem/Metalogic/BXCanonical/Completeness.lean:250` | Proved, `[propext, Classical.choice, Quot.sound]` — sorry-free |
| `completeness_discrete` (discrete-frame weak completeness) | `theorem completeness_discrete` | `FormalSystem/Metalogic/BXCanonical/Completeness.lean:291` | Proved, sorry-free (calls the reynolds_v2 path below) |
| `mcs_mixed_case_absurd` (mixed-case elimination) | `theorem mcs_mixed_case_absurd` | `FormalSystem/Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean:42` | Proved, used at `MCSMixedCase.lean:77` |
| `completeness_dedekind_engine` (Dedekind-class completeness) | `theorem completeness_dedekind_engine` | `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean:585` | Proved; file's own `#print axioms` call at line 605 confirms `[propext, Classical.choice, Quot.sound]` |
| `countermodel_discrete_reynolds_v2` (live discrete-branch countermodel) | `theorem countermodel_discrete_reynolds_v2` | `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:936` | Proved, sorry-free; file's own docstring (`:34-44`) states the dead-code `countermodel_discrete` chain in `Transfer.lean` was superseded by this declaration |
| `completeness` (general Base-frame theorem) | `theorem completeness` (same module as `completeness_dense`) | `FormalSystem/Metalogic/BXCanonical/Completeness.lean` | Carries `sorryAx`, traced to the dead-code `Transfer.lean` dependency — **the document's current framing of this as "outstanding" is accurate, do not upgrade it** |
| `sorry_total=5, sorry_total_excl_boneyard=1, sorry_algebraic=0, sorry_bxcanonical=0, sorry_bundle=0` | `scripts/typst-status-counts.sh --json` | (script, not a Lean file) | Re-run 2026-08-13 at commit `2d57928fa` — **identical** to the counts already cited in the current `.typ` document at `:327` (only `stamp_commit` moved); no correction needed to these numbers, only re-stamping the commit hash |
| `|p| ⊆ H_F × D` (atom valuation) | — (this is a claim about the *paper*, not Lean) | `possible_worlds.tex:2876-2878` (`def:BL-model`), `:2892` (atomic clause) | **Overclaim/error**: paper states `|p_i| ⊆ W`, truth clause `τ(x) ∈ |p_i|` — see Finding 2 |
| "Burgess event-first convention" gloss on the paper's own `S`/`U` | — (claim about the paper) | `possible_worlds.tex:3816-3817` | **Mislabeled**: paper's own notation is guard-first; event-first is the *Lean* convention — see Finding 3 |

No other major-theorem overclaims were found in the spot-checked declarations; the document's
existing sorry/axiom bookkeeping (§6/§9 of the current file) is accurate and just needs re-dating.

### E. Style Specimen

Two passages in the target register, using the file's existing macros (`#definition`, `#theorem`,
`#remark`, `#worldstate`, `#Dur`, `#taskframe`, `#taskto`, `#satisfies`, `#allpast`/`#allfuture`
etc. from `notation/bimodal-notation.typ` and `template.typ`). These replace the corresponding
material at `:127-136` and `:190-198` respectively.

```typst
#definition("Frame")[
  A #emph[frame] is a structure $#taskframe = (#worldstate, #Dur, arrow.r.double.long_(dot.c))$
  where $#worldstate$ is a nonempty set of world states, $#Dur = (D, +, 0, lt.eq)$ is a
  temporal order, and $arrow.r.double.long$ is a task relation satisfying, for all $x, y gt.eq 0$:

  #items[
    - *Compositionality.* $w arrow.r.double.long_(x+y) v$ iff $w arrow.r.double.long_x u$ and
      $u arrow.r.double.long_y v$ for some $u in #worldstate$.
    - *Seriality.* Some $u, v in #worldstate$ satisfy $w arrow.r.double.long_x u$ and
      $v arrow.r.double.long_x w$.
    - *Limit.* $inter.big_(x>0) (w)_x = {w}$, where $(w)_x := union.big_(|y|<x) "Fib"(w,y)$.
    - *Spherical.* $inter.big cal(S) eq.not emptyset$ for every directed family $cal(S)$ of
      nonempty fibers and segments.
  ]
]#footnote[`def:frame`. @brastmckie2026possibleworlds]

A model $#model = (#worldstate, #Dur, arrow.r.double.long_(dot.c), |dot.c|)$ interprets each
atom $p_i$ as a set of world states, $|p_i| subset.eq #worldstate$ -- *not* as a relation on
histories or times. Truth at a possible world $tau in H_(#taskframe)$ and time $x in D$ is then
determined pointwise through the state $tau(x)$ the history occupies:
$ #model, tau, x #satisfies p_i quad "iff" quad tau(x) in |p_i|. $
#footnote[`def:BL-model`, `def:BL-semantics`. @brastmckie2026possibleworlds]
```

```typst
#theorem("Three-Way Discreteness Split")[
  Let $M$ be a maximal $#taskframe$-consistent set. Exactly one of the following holds:
  $ square.stroked not "Next" top in M, quad not square.stroked not "Next" top in M. $
  Consequently every canonical-model construction resolves into a dense branch
  ($square.stroked not "Next"top in M$) or a discrete branch ($not square.stroked not "Next" top
  in M$); no third, mixed branch is consistent.
]#footnote[`mcs_mixed_case_absurd`, `FormalSystem/Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean:42`.]

#remark[
  This is the same discrete/dense dichotomy responsible for the split-validity phenomenon in the
  base language $op("BL")$: the sentence $not "Next" top$ names discreteness directly in
  $op("BL")^+$, where $op("BL")$ has no such sentence and must instead disjoin over schemas. The
  fact that breaks completeness at the $op("BL")$ level is exactly the fact the $op("BL")^+$
  canonical-model construction case-splits on to go through.
]
```

---

## Evidence/Examples

- `typst/FormalFoundations.typ:135-136` vs. `possible_worlds.tex:2876-2878,2892` — the `|p| ⊆ H_F ×
  D` error (Finding 2), the report's single highest-priority correctness fix.
- `typst/FormalFoundations.typ:117` vs. `possible_worlds.tex:3816-3817` — the event/guard mislabel
  (Finding 3), newly identified in this pass (not flagged by task 443's research).
- `possible_worlds.tex:2622-2680` (`def:task-topology`, `app:topology-t1`, `app:topology-r0`) vs.
  `other/dana.md:5` — the T1 topology content Dana's email opens with is entirely absent from the
  current `.typ` (Finding 4).
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean:250,291`,
  `FormalSystem/Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean:42`,
  `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean:585`,
  `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:936` — all four
  spot-checked Lean declarations underlying the document's flagship claims confirmed present,
  proved, and correctly characterized as sorry-free (Lean Verification table).
- `scripts/typst-status-counts.sh --json` (re-run this session, commit `2d57928fa`) — sorry/axiom
  counts identical to the document's existing claims at `typst/FormalFoundations.typ:327`.
- `typst/template.typ:70-92` (`definition`/`theorem`/`remark`/`items`/`item` macros),
  `typst/notation/bimodal-notation.typ:29-113` (`#worldstate`, `#Dur`, `#taskframe`, `#taskto`,
  `#satisfies`, `#truthat`, Lean-identifier raw helpers) — the macro inventory the style specimen
  and target skeleton draw on; no new `#let`s are needed.

## Confidence Level

**High** on the FIX-tag catalogue, the `|p|` error, the structural-arc diagnosis, and the Lean
verification table — all directly cross-checked against primary sources (the live paper, the live
Lean tree, the live gate script). **Medium** on the Since/Until event/guard mislabel (Finding 3) —
I am confident in the paper's own stated convention (quoted directly), but have not independently
re-derived what the *Lean* `snce`/`untl` constructors' actual argument order is from the Lean
source itself; I am relying on the paper's footnote's characterization of the Lean convention. If
another teammate's territory includes the Lean tense-operator constructors, this is worth an
independent spot-check. **Medium** on the T1/R0 topology material's appropriate placement/depth in
the target skeleton — I recommend including it because Dana's email opens with it, but have not
seen prior task guidance on how much topology apparatus (vs. a one-line pointer) belongs in a
report whose stated focus is completeness/decidability/representation rather than the topological
motivation for the world-history definitions.
