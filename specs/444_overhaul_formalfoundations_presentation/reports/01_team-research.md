# Research Report: Overhaul of `typst/FormalFoundations.typ` for Dana Scott

- **Task**: 444 - Overhaul FormalFoundations.typ presentation
- **Started**: 2026-08-13T21:55:37Z
- **Completed**: 2026-08-13T22:02:00Z
- **Effort**: ~4 agent-hours (4 parallel teammates + synthesis)
- **Dependencies**: None blocking. Builds on task 443, which authored the current document.
- **Mode**: Team Research (4 teammates: Primary, Alternatives, Critic, Horizons)
- **Sources/Inputs**:
  - Target: `typst/FormalFoundations.typ` (390 lines, 11 FIX tags)
  - Brief: `other/dana.md` (the email to Dana Scott)
  - Paper: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (4258 lines)
  - Ground truth: `FormalSystem/` (Lean 4), `scripts/typst-status-counts.sh`
  - Prior art in-repo: `typst/chapters/p2-frame-classes.typ`, `typst/chapters/p3-vlach-blstar.typ`, `typst/chapters/04-metalogic.typ`, `typst/template.typ`, `typst/notation/bimodal-notation.typ`, `typst/bibliography.bib`, `typst/SYNC-MAP.md`, `typst/sync-check-whitelist.txt`
  - Strategy: `specs/ROADMAP.md`, `specs/TODO.md`
  - Prior task artifacts: `specs/443_formal_foundations_report_completeness_and_representation/`
- **Artifacts**:
  - `specs/444_overhaul_formalfoundations_presentation/reports/01_teammate-a-findings.md` (primary skeleton, FIX catalogue, Lean verification, style specimens)
  - `specs/444_overhaul_formalfoundations_presentation/reports/01_teammate-b-findings.md` (prior art, alternative architectures, reusable in-repo material)
  - `specs/444_overhaul_formalfoundations_presentation/reports/01_teammate-c-findings.md` (correctness audit, email/scope mismatch, rewrite risks)
  - `specs/444_overhaul_formalfoundations_presentation/reports/01_teammate-d-findings.md` (roadmap alignment, strategic bet, the Scott question)
  - `specs/444_overhaul_formalfoundations_presentation/reports/01_team-research.md` (this synthesis)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

- **One genuine mathematical error was found**, and it is load-bearing: `typst/FormalFoundations.typ:135-136` states `|p| ⊆ H_F × D`, but the paper defines atoms as sets of world states (`|p_i| ⊆ W`, truth clause `τ(x) ∈ |p_i|`, `possible_worlds.tex:2876-2892`). This contradicts precisely the architecture Dana's email is asking about. It is the highest-priority fix and it propagates through every paraphrase of model structure in the document.
- **The Lean-fidelity floor is otherwise unusually solid.** Two teammates independently audited every load-bearing claim against `FormalSystem/` and found no theorem stated flatly that rests on a live `sorry`. The sole non-Boneyard structural `sorry` (`WeakCanonical/Transfer.lean:1084`) is confirmed dead code, and the document already says so at file:line precision. The sorry/axiom counts need re-stamping to commit `2d57928fa`, not correction. **The risk in this task is scope and rewrite mechanics, not smuggled-in false theorems.**
- **The task's three-part decomposition misses Dana's most-developed question.** The email spends roughly 40% of its content on whether partial histories should be identified with restrictions of total histories, grounded in the T1-ness of the task topology (`app:topology-t1`), `thm:extension`, and `cor:occurrence`. The T1 topology appears nowhere in `FormalFoundations.typ`. Decidability, conversely, is not mentioned in the email at all. This mismatch must be resolved deliberately — by addressing the question or by scoping it out in one explicit line — not by silent omission.
- **The single biggest structural defect is ordering**: the completeness construction, the mechanical heart of the report, arrives fifth, after three "pain point" sections. A reader wanting "how completeness works" must wade through unrelated philosophical material to reach it.
- **The representation section should commit, not enumerate.** It currently offers six open forks (a)-(f) with no recommendation. The evidence supports committing to the algebraic route — it is the only route with live, sorry-free Lean groundwork (`Metalogic/Algebraic/`) — and closing with one precisely-posed open question: whether *Spherical* admits a neighbourhood-semantic reformulation surviving infinite carriers.
- **Substantial in-repo material is reusable rather than rewritable**: `p3-vlach-blstar.typ`'s correctly-scoped Kamp treatment, `p2-frame-classes.typ`'s worked density/discreteness validity proofs, and `Metalogic/Algebraic/README.md`'s five-step mathematical overview.

## Context & Scope

The document is a standalone ~10-page report (not a chapter of `BimodalReference.typ`, though it imports the book's notation and template modules so notation cannot drift — `typst/FormalFoundations.typ:11-15`). It was authored by task 443 and has since accumulated 11 FIX tags from the author.

The brief has three stated payloads — completeness mechanics, decidability status, representation-theorem direction — plus a style mandate (advanced textbook; precise definitions and theorems; terse motivation; no vague glosses) and a diagnosis (no detectable narrative arc).

Two constraints bound the rewrite:

- **The sync gate.** `typst/sync-check-whitelist.txt:94,113,128` reference `FormalFoundations.typ` by name, confirming it is inside `scripts/typst-sync-check.sh`'s scanned tree. Any new backticked Lean identifier must resolve under `FormalSystem/` (excluding `Boneyard/`) or be added to the whitelist with a reason.
- **The build baseline.** `typst/FormalFoundations.pdf` exists alongside the source, so the document compiles today; any post-rewrite compile failure is attributable to the rewrite.

## Findings

### F1. The atom-interpretation error (high confidence, corroborated)

`typst/FormalFoundations.typ:135-136` states `|p| ⊆ H_F × D`. The paper's `def:BL-model` (`possible_worlds.tex:2876-2878`) gives `|p_i| ⊆ W`, and `def:BL-semantics` (`:2892`) gives the atomic clause `M,τ,x ⊨ p_i` iff `τ(x) ∈ |p_i|`. Truth at a time is mediated entirely through the world state the history occupies there.

This is not a typo with local scope. It contradicts the architecture the email defends (partial histories as restrictions; world states occurring at times), and FIX-135's own wording ("offends the most fundamental ideas") demands a full-document faithfulness pass. Teammate A cross-checked the remaining system-layer clauses — the Box clause, frame-validity, and logical-consequence clauses all match the live paper text — so the propagation is bounded but must be done line-by-line rather than assumed.

### F2. The correctness floor is solid; only re-stamping is needed (high confidence, independently corroborated)

Teammates A and C audited separately and agree:

| Claim | Lean declaration | Status |
|---|---|---|
| Dense-frame weak completeness | `BXCanonical/Completeness.lean:250` | Proved, sorry-free |
| Discrete-frame weak completeness | `BXCanonical/Completeness.lean:291` | Proved, sorry-free |
| Mixed-case elimination | `Chronicle/MCSMixedCase.lean:42` | Proved |
| Dedekind-class completeness | `CompletenessDedekind.lean:585` | Proved, `#print axioms` confirms |
| Live discrete countermodel | `IntegerModel/ReynoldsBridge.lean:936` | Proved, sorry-free |
| General Base-frame `completeness` | `BXCanonical/Completeness.lean` | Carries `sorryAx` — **document's "outstanding" framing is accurate; do not upgrade** |

A fresh re-run of `scripts/typst-status-counts.sh --json` at commit `2d57928fa` returns counts identical to those already in the document (`sorry_total=5`, `sorry_total_excl_boneyard=1`, `sorry_algebraic=0`, `sorry_bxcanonical=0`, `sorry_bundle=0`). Only `stamp_commit` moved.

The sole non-Boneyard structural `sorry` is `countermodel_discrete` at `WeakCanonical/Transfer.lean:1084`, confirmed dead code — not on the path `completeness_discrete` uses. The ~209 other `sorry` grep hits are inside `Boneyard/**` or are the word appearing in prose describing sorry-*freedom*.

### F3. The email/task scope mismatch (high confidence)

Dana's email raises three substantive questions, in this order and weight:

- **(a) Most developed (~40% of content).** Whether identifying partial histories with restrictions of total histories is the right foundational choice, grounded in three results: the task topology is T1 (`app:topology-t1`, `def:task-topology`, `possible_worlds.tex:2622-2680`), every partial history extends to a total one (`thm:extension`), and every world state occurs at some time in some total history (`cor:occurrence`).
- **(b) Medium.** Whether the necessity-if-true of temporal structure is a real problem or is exactly analogous to ordinary frame-validity-closed-under-necessitation phenomena (the Kripke B/symmetry precedent).
- **(c) Explicitly flagged as "the last and furthest from complete issue."** What it would take to get a representation theorem going, including whether metric tense operators are needed.

Mapping onto the task's three payloads: (b) matches the contingency section well; (c) matches the representation section; **(a) has no target section at all.** `thm:extension`/`cor:occurrence` appear in passing at `:133-134` as background setup, and the T1 result Dana explicitly cites as his justification appears nowhere in the document. The definitional question he is actually putting to Scott — partial-histories-as-restrictions vs. defined-independently — is not posed as a live question anywhere.

Conversely, **decidability is not mentioned in the email at all**; it is an addition from the task description, reasonable as adjacent context but not something Dana asked about.

The paper has also moved since task 443's research: the full topology apparatus (`def:task-topology` with cones as a basis, T1 at `:2653-2666`, R0 at `:2673-2680`) is not mentioned in the prior task's reports. This is new content relative to what task 443 planned for.

### F4. Structural diagnosis: the arc breaks in four identified places (high confidence)

Current skeleton: §1 System → §2 Key Theorems/Completeness/Decidability → §3 Pain Point One (contingency) → §4 Pain Point Two (split validity) → §5 Pain Point Three (objective modality) → §6 The Completeness Construction → §7 Representation.

- **§1→§2 has no bridge.** §1 ends with an axiom-system table; §2 opens with no transition connecting "here is the system" to "here is what we can prove about it." The reader never learns what completeness *would* buy.
- **§2.3's theorem block is an information dump.** One `#theorem` (`:192-194`) states five systems' soundness, non-completeness, and which `BL⁺` variant carries completeness in a single unbroken sentence. FIX-189's "virtually no substance" charge is correct: naming five systems in one clause is compression without exposition.
- **§3/§4/§5 have no ordering logic.** Nothing explains why contingency precedes split-validity precedes objective modality. They read as an enumerated list of separate worries, not a developing argument.
- **§6 arrives fifth.** The section that actually explains *how* the complete systems get proved complete sits behind all three pain points. This is the single biggest fix.

§7 is, by contrast, the best-organized section in the document — its live/target/archived status discipline is the model the others should emulate.

### F5. The eleven FIX tags decompose into three classes

Teammate A catalogued all 11 verbatim with resolutions (lines 93, 113, 123, 126, 135, 174, 189, 208, 231, 285, 337). They sort into:

- **One correctness fix**: FIX-135 (F1 above).
- **Two structural decisions**: FIX-231 (drop TM-level split-validity; focus exclusively on `BL⁺` with Since/Until primitive) and FIX-285 (rewrite the construction section completely, in precise formal detail, citing literature).
- **Eight presentation fixes**: abstract formatting (93), notation alignment to the paper's `BL⁺` (113), splitting run-on definitions (123, 126), compressing the correspondence table (174), removing self-referential meta-commentary (189), formalizing the contingency section through a formal lens (208), and cutting the superseded-waypoint material (337).

FIX-231 is the largest structural decision in the rewrite and carries a trap — see R2.

### F6. Reusable in-repo material (high confidence)

- `typst/chapters/p3-vlach-blstar.typ:108-128` — Kamp's theorem correctly scoped (strict operators, Dedekind-complete flows), the standard miscitation corrected, exact Lean status given. Textbook-quality; portable with compression.
- `typst/chapters/p2-frame-classes.typ:105-179` — worked validity arguments for the density schema and the discreteness/Prior-Z1 layer, the `ℤ ×_lex ℤ` non-density/non-discreteness witness, and the precise unfillable-gap statement. Directly relevant to Dana's question (b).
- `FormalSystem/Metalogic/Algebraic/README.md` — a five-step mathematical overview (Lindenbaum → Boolean algebra → interior operators → ultrafilter-MCS correspondence → representation-via-ultrafilters) that already reads as draft prose for the representation section.
- `FormalSystem/Boneyard/UltrafilterFrame/README.md` — states the exact archival reason and names the revival gate, which is the honest obstruction statement the representation section needs.
- `possible_worlds.tex:899-1070` — the paper's own semantics-first exposition order, close to a ready-made outline.

### F7. Bibliography and Typst mechanics gaps

`typst/bibliography.bib` has 46 entries including `blackburnderijkevenema2001`, `gabbayhodkinsonreynolds1994`, `reynolds1992`, and `thomason1984`. **Absent and required if cited**: Goldblatt *Logics of Time and Computation*, Chagrov–Zakharyaschev, Jónsson–Tarski (1951/52), Stone (1936), Scott "Advice on Modal Logic" (1970).

Two notable citation opportunities are currently unexploited: the Reynolds-named Lean construction (`ReynoldsBridge.lean`) directly implements the Gabbay–Hodkinson–Reynolds step-by-step technique, already in the bib but uncredited in the construction section; and `thomason1984` is the one source in the bib about *this exact* tense+alethic combination but is not used for the representation question.

Underused Typst mechanics: `#leansrc(module, name)` (`template.typ:97-98`) renders a citation into actual Lean source and would visually separate machine-checked from paper-side claims; `proposition` and `corollary` environments (`template.typ:89-90`) are imported but unused.

### F8. Roadmap position (medium-high confidence)

`specs/ROADMAP.md:49-54` gates the expensive strong-completeness program (ultraproduct carrier, Łoś lemma, compactness, per-class strong completeness) behind the shift-set representation theorem landing sorry-free: that work is "not authorized and deliberately not created as tasks" until then. The representation section of this document is currently the only prose account of that gate's two candidate routes. Overhauling it is on the critical path, not adjacent to it, at the one point where an outside collaborator's judgment is being solicited before the project spends the expensive budget.

Three routes exist and are not equally positioned:

| Route | Lean status | Standing |
|---|---|---|
| Algebraic (Lindenbaum–Tarski, ultrafilters, interior operators) | `Metalogic/Algebraic/` — live, measured sorry-free | Only route with a verified asset today |
| Jónsson–Tarski completion (`TenseS5Algebra`, `UltrafilterFrame`) | Archived to `Boneyard/`, named revival gate | Blocked on Spherical at infinite carriers |
| Shift-set / ultraproduct | Design document only, zero live identifiers | Roadmap's sanctioned next feasibility gate |

## Decisions

Conflicts between teammates were resolved as follows.

- **D1 — Document ordering: adopt the payload-first skeleton, with a semantics-first §1.** Teammate A proposed System → What Is Proved → Construction → Costs → Representation. Teammate B proposed matching the email's question order (semantics/T1 → contingency → completeness → representation). *Resolution*: A's ordering, because the task description is the authoritative brief and names its three payloads explicitly; it also fixes the diagnosed defect (F4) of burying the construction. B's semantics-first argument is nonetheless correct about §1's internal order and is adopted there: frames and the task relation before the axioms that correspond to them, matching the paper's own order (`possible_worlds.tex:899-1070`). B's ordering claim and A's are not fully reconcilable at the top level; the plan phase must lock this explicitly rather than inheriting it by default.
- **D2 — Kamp material goes in the construction section, not the representation section.** Teammate B recommended porting `p3-vlach-blstar.typ`'s Kamp treatment into the representation section for Dana's question (c); Teammate D argued Kamp is already-exploited machinery used *inside* discrete weak completeness and would misstate its role if presented as a forward-looking direction. *Resolution*: D, and B's own reasoning supports it — B independently observes that expressive completeness is "a genuinely different target from a representation theorem, which needs a duality." Port the material, but split it: the machinery into the construction section, and a short note in the representation section explaining why expressive completeness is not representation. That distinction is exactly what justifies Dana's own hedge about metric operators, so it earns its place.
- **D3 — Commit to the algebraic route in the representation section, without making the document algebra-first.** Teammate D recommended committing rhetorical weight to the algebraic route; Teammate B warned against algebra-first as overpromising; Teammate C demanded an actual editorial recommendation instead of six open forks. *Resolution*: these are compatible once the scope is distinguished. B objects to algebra as the *document's* spine (rejected); D recommends leading *the representation section* with it (adopted). The section opens with the live algebraic layer, presents the three-tier status table honestly (F8), and closes with the Spherical question. C's demand is satisfied; C's warning against false consensus is honored by keeping the tier table's "archived" and "design-only" labels explicit.
- **D4 — Address Dana's question (a) rather than scoping it out silently.** Given F3, the T1/topology/partial-history-as-restriction material should get a short, precise treatment in §1 — stating the topology, its T1/R0 status, and the definitional question as a live one. If the author decides it is out of scope, that must be one explicit line, not omission.
- **D5 — The Scott personal anchor is optional and limited to one sentence.** Scott is cited in the paper's own genealogy as Prior's source for Next/Previous (`possible_worlds.tex:1308`) and thanked in the acknowledgments (`:395`). Both B and D independently converged on "one sentence, not a section." It has no open-problem content and is the author's call on register.

## Recommendations

Prioritized. Owner is the implementation phase unless noted.

1. **Fix the atom-interpretation clause and run a full faithfulness pass** (F1). Replace `|p| ⊆ H_F × D` with `|p_i| ⊆ W` and the truth clause with `τ(x) ∈ |p_i|`, then re-check every paraphrase of model structure, atom valuation, and the modal clauses line-by-line against `def:BL-model`/`def:BL-semantics`/`def:frame-validity`/`def:logical-consequence`. This is the one item that is a correctness defect rather than a presentation defect.
2. **Reorder to the five-section skeleton**, promoting the construction ahead of the pain points: (1) The System, semantics-first, with the T1/topology material and corrected semantics; (2) What Is Proved — completeness and decidability stated per-system rather than in one dense paragraph; (3) The Completeness Construction; (4) Two Costs of the Semantics, merging the contingency and objective-modality sections; (5) Toward a Representation Theorem. Approximate budget ~1.5 / 1.5 / 2.5 / 2 / 1.5 pages, holding the existing ~10-page target.
3. **Execute FIX-231 by folding, not deleting** (see R2). Drop the TM-level split-validity section as a *named pain point*, but restate the (DD) phenomenon compactly — for `BL⁺` directly via `¬Next⊤`, not via the TM-level schema — inside the construction section as the motivating example for the three-way case split. This satisfies FIX-231 and FIX-285 simultaneously.
4. **Rewrite the construction section at book-chapter formality**: MCS/Lindenbaum via `set_lindenbaum`; a theorem stating the three-way case split with the mixed case eliminated by `mcs_mixed_case_absurd`; per-branch definition+theorem pairs for the dense (Burgess chronicle over ℚ) and discrete (Reynolds/Doets over ℤ) canonical models, each with the actual truth-lemma mechanism (BFMCS coherence) stated rather than named; the Dedekind path; the re-stamped status table. Credit Gabbay–Hodkinson–Reynolds and Reynolds 1992 at the construction itself. Writing it at this formality makes it liftable into `typst/chapters/04-metalogic.typ`, where a reuse channel already exists (`FormalFoundations.typ:269`), advancing the reference-book work at no extra cost.
5. **Restructure the representation section** per D3: open with the live algebraic layer; give the three-tier status table; state the task-424 gate exactly as `ROADMAP.md:49-54` has it; compress the six lettered forks to the two substantive ones (the Spherical discharge-pattern analysis and the group-structure-as-crux argument); close with the Spherical/neighbourhood-semantics question posed formally. Cut the superseded-waypoint subsection to at most one sentence plus a footnote.
6. **Strip the self-referential register throughout** (FIX-189, FIX-208, FIX-337). Rename headings like "Completeness — Stated Exactly, Unsoftened" to plain "Completeness"; convert stage-direction prose ("The worry, at full strength.", "The price, stated exactly") into actual `#definition`/`#proposition`/`#remark` environments. Formalize the irregular-worlds material as a definition rather than leaving it only inside a block quote.
7. **Thread the machine-verification discipline through every major result**, one line per result, rather than confining it to one paragraph. Use `#leansrc` for headline theorems so machine-checked and paper-side claims are visually distinct.
8. **Add any newly cited sources to `typst/bibliography.bib`** before citing (F7) — the shared bib, not a local one, to avoid drift with `BimodalReference.typ`.
9. **Re-stamp the status counts** to the current commit; do not re-derive them (F2).

## Risks & Mitigations

- **Deleting the split-validity section breaks two other sections' arguments.** `@sec:construction:317` calls the structural rhyme "this report's single most illuminating connection" and `@sec:contingency:227` points at that section by name for why the unrestricted class is not validity-closed. Deleting it wholesale silently breaks both arguments, not merely a `#ref` link. *Mitigation*: R3's fold-don't-delete approach, plus an explicit cross-reference sweep after the restructure.
- **The correspondence-theorem claims could be dropped along with the table.** FIX-174 demotes the DF/DN/CO ↔ Discrete/Dense/Complete table, but the contingency section depends on those correspondences ("a dense frame makes DN necessary" presupposes DN ↔ Dense). *Mitigation*: compress the table, keep the claims.
- **The sync gate will reject unresolvable Lean identifiers.** Any new backticked identifier introduced during the rewrite must resolve under `FormalSystem/` excluding `Boneyard/`, or be whitelisted with a reason. *Mitigation*: run `scripts/typst-sync-check.sh` as a required post-rewrite gate, alongside `typst compile`.
- **Scope creep from adding the topology material.** D4 adds content the current document does not have, against a fixed page budget. *Mitigation*: hold the ~10-page target; the material displaced by FIX-231, FIX-337, and the meta-commentary strip should more than cover it.
- **The rewrite may outrun its verification.** The document's credibility with this reader rests on the exactness of its status claims. *Mitigation*: treat F2's table as the baseline and re-verify any claim whose wording changes.

## Gaps Identified

Four items neither teammate could close; each needs a targeted check during planning or implementation.

- **G1 — The BX/TM⁺ axiom-set identification is asserted where the analogous case is hedged.** The Lean results are attributed to `TM⁺_d`/`TM⁺_f`/`TM⁺_c`, silently identifying Lean's `FrameClass`-parameterized `BX` with the paper's BX. The document elsewhere explicitly flags the general BX-vs-paper correspondence as open. The paper's `def:BX` has 17 named keys; `SYNC-MAP.md` lists Lean's BX Temporal layer as 22 constructors under different names (BX1–BX13′). No file states these axiomatizations are checked to prove the same theorems. *Needed*: a Lean-side check of `FrameClass.Dense`'s axiom set against `def:BX`'s list. Then either make the definitional argument explicit in one sentence, or hedge it exactly as carefully as the TM case is hedged — an inconsistent hedging posture is worse than either choice.
- **G2 — The Since/Until argument-order gloss is likely backwards.** `FormalFoundations.typ:117` labels the paper's `S`/`U` as the "Burgess event-first convention," but `possible_worlds.tex:3816-3817` states the paper's surface notation is guard-first (φ the interval guard, ψ the witnessed event) and that event-first is the *Lean repository's* `snce`/`untl` convention. Teammate A flagged this at medium confidence, relying on the paper's characterization of the Lean side. *Needed*: an independent read of the `snce`/`untl` constructors in the Lean source. The simplest resolution may be to drop the Lean-convention footnote entirely and present only the paper's own clause.
- **G3 — How much topology apparatus belongs is unsettled.** F3/D4 establish that the T1 material must be addressed; its depth (a remark, a subsection, or a full definition-plus-theorem treatment) is a judgment call nobody had grounds to settle. The author is best placed to decide.
- **G4 — Out-of-scope acknowledgments.** Complexity (as distinct from decidability), interpolation, and finite axiomatizability are absent. These are reasonable exclusions at this length, but for a reader of Scott's caliber a one-line acknowledgment that they are known-open and out of scope would read as more sophisticated than silence.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|---|---|---|---|
| A | Primary — skeleton, FIX catalogue, Lean verification, style specimens | completed | high (FIX catalogue, `\|p\|` error, structural diagnosis, Lean table); medium (Since/Until gloss, topology depth) |
| B | Alternatives — prior art, architectures, reusable material, Typst mechanics | completed | high (bibliography gaps, reusable material, three-tier status, Typst inventory); medium (Scott personal anchor, axiomatics-first diagnosis) |
| C | Critic — correctness audit, email/scope mismatch, rewrite risks | completed | high (Lean audit, email mismatch); medium (BX/TM⁺ identification, out-of-scope items) |
| D | Horizons — roadmap alignment, strategic bet, the Scott question | completed | medium-high (roadmap, reuse path); medium (neighbourhood-semantics framing); low-medium (email timing) |

Conflicts found: 3 (ordering, Kamp placement, algebraic emphasis). Conflicts resolved: 3 — see Decisions. Gaps identified: 4 — see above. No second wave was triggered; the four angles covered the brief without leaving a dimension unexamined.

## Appendix

### Primary source anchors

- `typst/FormalFoundations.typ` — FIX tags at lines 93, 113, 123, 126, 135, 174, 189, 208, 231, 285, 337; scope rationale at `:11-15`; reuse channel footnote at `:269`; Spherical obstruction at `:378`
- `possible_worlds.tex` — `def:BL-model` `:2876-2878`; atomic clause `:2892`; Box clause `:2899`; `def:task-topology` `:2622-2632`; `app:topology-t1` `:2653-2666`; `app:topology-r0` `:2673-2680`; `def:world-history` `:2707-2714`; `def:BLplus-semantics` `:3820-3823`; Since/Until convention footnote `:3816-3817`; Scott/Prior genealogy `:1308`; acknowledgments `:395`; semantics-first exposition `:899-1070`
- `other/dana.md` — three questions at ¶1 (T1/partial histories), ¶2 (temporal-axiom contingency), ¶3 (representation theorem, metric operators)
- `specs/ROADMAP.md:44-45, 49-54` — the strong-completeness gating rule

### Literature referenced

Already in `bibliography.bib`: Blackburn–de Rijke–Venema (2001); Gabbay–Hodkinson–Reynolds (1994); Reynolds (1992); Thomason (1984).

Not in `bibliography.bib`, required if cited: Goldblatt, *Logics of Time and Computation* (2nd ed. 1992); Chagrov–Zakharyaschev, *Modal Logic* (1997); Jónsson–Tarski, "Boolean Algebras with Operators I/II" (1951/52); Stone (1936); Scott, "Advice on Modal Logic" (1970).

### Verification commands

- `scripts/typst-status-counts.sh --json` — sorry/axiom counts, re-run at `2d57928fa`
- `scripts/typst-sync-check.sh` — required post-rewrite gate
- `typst compile typst/FormalFoundations.typ` — build baseline
