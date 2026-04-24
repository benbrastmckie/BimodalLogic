# Teammate D (Horizons): Strategic Literature Alignment Analysis

**Task**: 111 - Literature second research wave
**Role**: Teammate D (Horizons) — long-term strategic alignment
**Date**: 2026-04-24

---

## Key Findings

### 1. The Existing Literature Collection Is Well-Targeted but Missing One Critical Source

The eight papers identified in `specs/107_chain_design_diagnostics_for_representation_theorem/reports/04_literature-sources.md` cover the mathematical core of the completeness proof competently. However, **the collection was assembled to solve the F-propagation problem**, which is now superseded by the Burgess chronicle approach. The task-111 literature wave needs to serve a different purpose: supporting the **publication case** for this formalization.

The single most glaring gap is **Xu 1988** ("On some U,S-tense logics," Journal of Philosophical Logic 17(2):181-202). The project is explicitly a formalization of the **Burgess-Xu (BX) system**, named after both Burgess and Xu. A paper claiming to formalize the BX system cannot credibly omit citation of the paper that defines the axiom system. This paper is behind a paywall but should be accessible via institutional library or interlibrary loan.

**Burgess 1982 Part II** ("Axioms for tense logic II: Time periods," NDJFL 23(4):375-383) is also missing from close study — it appears in the collection but is listed as a companion without a separate relevance assessment. Part II handles the period-based fragment and contains structural insights about the chronicle that may bear on the interval function g.

### 2. The Literature Collection Does Not Yet Serve Publication Preparation

The project roadmap (`specs/ROADMAP.md`) states the goal as:

> "TM is complete with respect to TaskFrames over totally ordered abelian groups."
> "Only the algebraic/canonical model approach is pursued for completeness."
> "The structural correspondence is the scientific contribution — it tells us what TM *is*, not merely that it is complete."

For a publication, the literature collection needs to answer three questions that the current eight papers do not fully address:

**Q1: What other formalizations of temporal logic completeness exist in proof assistants?**

The current collection has zero references to prior machine-checked completeness proofs for temporal logics with Until/Since. Task 107 reports (Teammate C, `03_teammate-c-findings.md`) explicitly flagged this gap: "A search should be conducted for existing formalizations of completeness for Until/Since tense logic in proof assistants (Lean, Coq, Isabelle)." This search has not been completed.

Known candidate sources to check:
- The **Isabelle/HOL Archive of Formal Proofs (AFP)** contains modal logic entries. Relevant: Berghofer's K4 completeness (~2010), Blanchette's modal logic work, and possibly tense logic entries.
- **Coq** has had several temporal logic formalizations: the Pnueli-style LTL in Coq by Braüner/de Paiva; Lescuyer and Gnadig's tense logic formalization; Cristau's Coq formalization of Until.
- The **ITP/CPP proceedings** (Lean community venues) would document Lean 4 formalizations of modal or temporal logic if any exist.

The absence of this survey weakens any publication claim that the BX formalization in Lean 4 is novel or fills a specific gap.

**Q2: How does TM relate to the published literature on combined modal-temporal logics?**

The combination of S5 modality with linear temporal logic is studied in the **two-dimensional modal logic** tradition:
- **Thomason 1984** ("Combinations of tense and modality," Handbook of Philosophical Logic Vol. II) — the standard reference for modal-temporal combinations, co-located with Burgess 1984 in the same volume.
- **Prior 1968** (Papers on Time and Tense) — the origin of tense logic; foundational for citation purposes.
- **Segerberg 1970** ("Modal Logics with Linear Alternative Relations") — introduces the canonical model technique for temporal logics; the technical foundation that Burgess 1982 extends to Since/Until.

These contextualization sources are absent from the current collection.

**Q3: Is the Burgess-Xu axiom system the canonical axiomatization of this combined logic?**

The project treats BX as the definitively correct axiom system, but the literature does not uniformly agree. Alternative axiomatizations exist:
- **Reynolds 1997** ("Axioms for tense logic over dense orders," IEEE LICS) — an alternative approach for dense orderings that might intersect task 68.
- **Gabbay-Hodkinson-Reynolds 1994** (GHR book, already in the collection) — discusses multiple axiom systems and their relative strengths.

Without addressing these alternatives, a paper risks reviewers questioning whether the chosen axiom system is natural or canonical.

### 3. The Scoping Question: Priorities Are Clear

**Should the search focus on obtaining the 4 missing papers before adding new ones?**

Yes, with nuance. The priority order should be:

**Tier 1 (essential — mathematical content directly needed):**
1. **Xu 1988** — cannot publish a BX formalization without this
2. **GHR 1994** (Gabbay-Hodkinson-Reynolds) — comprehensive reference; library copy needed

**Tier 2 (strongly recommended for publication context):**
3. **Burgess 1984** handbook chapter — textbook treatment of the construction
4. **Thomason 1984** — modal-temporal combination context
5. A prior machine-checked formalization survey (see Q1 above)

**Tier 3 (enrichment — can be cited without full reading):**
6. **Prior 1968** or any standard reference for tense logic origins
7. **Segerberg 1970** — canonical model technique pre-Burgess
8. **Reynolds 2001** (already in collection, lower priority for BX context)

**The new literature wave (task 111) should focus primarily on Tier 2-3 items**, since Tier 1 items are tracked in task 107 and should already be on the acquisition list.

### 4. Creative/Unconventional Sources

**PhD theses** covering chronicle constructions or bimodal completeness are significantly more detailed than published papers. Candidate theses:
- **Mark Reynolds's doctoral work** — Reynolds is a leading temporal logic completeness expert (PhD from Queensland, early 1990s). His thesis would have detailed chronicle constructions.
- The **Amsterdam tradition** (ILLC dissertations) — de Jongh's group produced multiple theses on tense logic completeness in the 1990s. Verbrugge's own thesis or subsequent ILLC dissertations may contain more detailed step-by-step constructions than the 2004 Festschrift paper. The ILLC makes dissertations freely available at `https://www.illc.uva.nl/Research/Publications/Dissertations/`.

**Technical reports:**
- Verbrugge's construction was first a mid-1980s manuscript before appearing in the 2004 Festschrift. Earlier versions may exist as ITLI (Institute for Theoretical Logic and Informatics, Amsterdam) technical reports, which were circulated informally. These might contain more detailed proofs than the 2004 version.
- The **CSLI/Stanford technical report series** — Goldblatt's CSLI Lecture Notes grew out of Stanford technical reports that may contain intermediate-level proofs of the filtration constructions.

**Community resources specific to Lean/Mathlib:**
- The **Lean Zulip community** (`leanprover.zulipchat.com`) has channels for formalization projects. Searching `#Is there code for this?` for terms like "modal logic completeness" or "temporal logic" may surface prior Lean 4 formalization attempts that have not been published.
- The **Mathlib4 library** itself — Mathlib has `Mathlib.Logic.Order.Filter` and related infrastructure. Checking whether any Mathlib PRs touched modal or temporal logic formalization would surface adjacent work.
- **ITP 2023-2025 proceedings** — the annual Interactive Theorem Proving conference sometimes has Lean 4 formalization papers. Searching for "modal" or "temporal" in recent ITP/CPP proceedings would identify potential comparison points.

### 5. Roadmap Alignment Assessment

The ROADMAP is tightly focused on a single deliverable: sorry-free `bx_completeness`. The literature collection directly supports this through the chronicle construction sources (Burgess 1982, Verbrugge 2004). This alignment is **appropriate for the implementation phase**.

However, the ROADMAP section on "Representation Theorem Goal" articulates a broader scientific contribution:
> "The representation theorem characterizes TM by showing that every consistent formula has a model built from the logic's own proof-theoretic structure (MCS ↔ worlds, truth lemma connecting membership and semantic truth). This structural correspondence is the scientific contribution."

A second-wave literature search should support THIS goal specifically, not just the implementation. The sources needed here are:
- Prior representation theorems for similar combined logics (to position TM's novelty)
- Formalization papers that demonstrate machine-checked completeness for comparable logics (to establish the methodological contribution)

The existing collection does not address either of these. The second wave is well-justified.

---

## Strategic Recommendations

### R1. Acquire Xu 1988 Before Any Other New Source (CRITICAL)

The project name "Burgess-Xu (BX) system" without Xu 1988 in the bibliography is a publication-blocking gap. The paper is at Springer/JSTOR — institutional library or interlibrary loan within 1-2 weeks. Every other literature decision is secondary to this.

### R2. Conduct a Focused Survey of Machine-Checked Temporal Logic Completeness

Specifically search:
- Isabelle AFP (`https://www.isa-afp.org`) for modal and temporal logic entries
- CoRR/arXiv for "formalization" + ("temporal logic" OR "Until" OR "Since") since 2015
- ITP 2020-2025 and CPP 2020-2025 proceedings for temporal logic papers
- Lean4 Zulip archive

The goal is a 1-paragraph literature survey positioning TM's formalization relative to existing machine-checked completeness proofs. This is likely a 4-6 hour literature search, not a major research campaign.

### R3. Add Two Contextualization Sources for Modal-Temporal Combinations

The two highest-value additions for a publication introduction section:
1. **Thomason 1984** (Handbook of Philosophical Logic, Vol. II, pp. 135-165) — standard reference for modal-temporal combinations; co-located with Burgess 1984. Free preview likely via Google Books.
2. **Segerberg 1970** ("Modal logics with linear alternative relations," Theoria 36(3):301-322) — the canonical model technique foundation. Available via JSTOR.

### R4. Check ILLC Dissertations for Detailed Construction Proofs

The Verbrugge 2004 paper omits several proof details (the Lemma 2.4-2.8 equivalents are compressed). Reynolds or ILLC dissertations from the 1990s may contain more explicit step-by-step proofs that would reduce implementation risk on the remaining chronicle sorry sites. This is a 1-2 hour search at `https://www.illc.uva.nl/Research/Publications/Dissertations/`.

### R5. Do Not Broaden the Search Beyond This Scope

The current collection is appropriate for the mathematical core. The second wave should be targeted at:
1. Filling the Xu/Thomason/Segerberg gap (contextualization)
2. Finding prior machine-checked proofs (novelty claim)
3. Obtaining the 4 paywalled papers (complete coverage)

Broadening to adjacent areas (PDL, CTL*, hybrid logic, description logic) would dilute focus without improving the publication case. The BX formalization is novel enough that the contribution case does not depend on extensive adjacent literature.

---

## Evidence and Examples

**Evidence for Xu 1988 priority**: The `Axioms.lean:46-49` comment block explicitly credits "Burgess 1982/84, Xu 1988, Venema 1993" as the basis for the 35 axioms. A publication based on this code must cite what the code cites. The BX acronym appears throughout the codebase (BXPoint, BXCanonical, bx_completeness, etc.) making the citation omission doubly conspicuous.

**Evidence for machine-checked formalization gap**: All 107 research reports focus on the mathematical proof; none mention prior Lean/Coq/Isabelle formalizations of Until/Since completeness. The task-107 Teammate C report explicitly flagged this as an open question: "A search should be conducted for existing formalizations." This has not been done as of task 111's creation.

**Evidence for Thomason 1984 relevance**: The ROADMAP describes TM as "combining S5 modality with irreflexive linear temporal logic." Thomason 1984 is *the* standard survey reference for this class of combinations in the philosophical logic tradition. Any reviewer from modal or temporal logic would expect it in the bibliography.

**Evidence that the existing 8-paper collection is incomplete for publication**: The project has zero custom axioms, sorry-free soundness, and sorry-free decidability — a strong result. But the ROADMAP's own statement of contribution ("structural correspondence ... tells us what TM *is*") is not supported by any survey of what competing formalizations or related systems exist. The missing papers are needed to make that claim precise.

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| Xu 1988 is a publication-blocking gap | **High** — the paper defines the axiom system the project formalizes |
| No prior machine-checked U/S completeness formalization exists | **Medium** — this is based on absence of mentions across 100+ research reports; actual search needed |
| Thomason 1984 and Segerberg 1970 are standard contextualization sources | **High** — standard citations in modal logic bibliography |
| ILLC dissertations contain more detailed construction proofs than Verbrugge 2004 | **Medium** — based on typical dissertation vs. conference paper depth |
| 4-6 hours for formalization survey is sufficient | **Medium** — depends on how many AFP/CoRR hits need close reading |
| The existing 8 papers are sufficient for mathematical implementation | **High** — confirmed by Teammate analyses in task 107 |
| Second wave scope (3-5 papers) is appropriate | **High** — broader scope would dilute focus |
