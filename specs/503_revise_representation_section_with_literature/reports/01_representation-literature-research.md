# Research Report: Revise `<sec:representation>` with Literature

**Task**: 503 - revise_representation_section_with_literature
**Started**: 2026-08-26T10:36:00Z
**Completed**: 2026-08-26T12:05:00Z
- **Effort**: High — ~90 min wall clock, ~320k tokens; 2 corpus ingests with manual conversion repair, 17 sub-index registrations, 2 delegated sub-agents.
- **Dependencies**: `typst/FormalFoundations.typ` (lines 140-236, 380-600, 1151-1318); `FormalSystem/Metalogic/Algebraic/` (all 5 `.lean` files + README); `FormalSystem/Semantics/TaskFrame.lean`; `FormalSystem/Semantics/Extension/Step.lean`; `FormalSystem/Boneyard/UltrafilterFrame/`; corpus doc_ids `blackburn_2002_ch05_sec03/04/05`, `blackburn_2002_ch03_sec05-06/07`, `venema_2007_algebras_and_coalgebras`, `gehrke_vosmaer_2011_view-of-canonical-extension`, `goldblatt_2003`, `derijke_1995`, `j_nsson_and_tarski_-_1951/1952`, `goldblatt_1989` (locator only).
- **Sources/Inputs**: The task description (review `<sec:representation>` and the Lean `Algebraic/` layer, inventory and acquire literature, revise honestly); the `--lit` briefing at `scratchpad/literature-briefing-503.md` (46 sub-index docs + 9 global FTS searches); `specs/literature-index.json`; `~/Projects/Literature/index.json`; corpus tools `literature-search.sh`, `literature-discover.sh`, `literature-ingest-online.sh`, `literature-ingest.sh`, `literature-convert.sh`, `literature-chunk.sh`, `literature-build-index.sh`, `zotero-search.sh`.
- **Artifacts**: This report (`specs/503_revise_representation_section_with_literature/reports/01_representation-literature-research.md`); `specs/literature-index.json` (46 -> 63 entries, backup at `specs/literature-index.json.bak-503`); two new corpus directories `~/Projects/Literature/sources/venema_2007_algebras_and_coalgebras/` (173 chunks) and `~/Projects/Literature/sources/gehrke_vosmaer_2011_view-of-canonical-extension/` (38 chunks); `~/Projects/Literature/index.json` (+2 entries, backup at `index.json.bak-task503`); rebuilt `~/Projects/Literature/.literature.db`.
- **Standards**: `.claude/rules/artifact-formats.md`; `.claude/context/formats/return-metadata-file.md`; `.claude/rules/no-task-references-in-deliverables.md` (report lives under `specs/**`, exempt); corpus fidelity conventions per `provenance_fidelity` / `conversion_note` in `~/Projects/Literature/index.json`.
**Task Type**: formal
**Domains**: logic (primary), math (algebra / lattice / duality, secondary)
**Session**: sess_1787765867_5f8b5f

---

## Executive Summary

1. **The representation theorem the section is reaching for already exists in the literature, in
   full, and is not the Jónsson–Tarski theorem.** It is the Goldblatt/Esakia duality: the
   categories of Boolean algebras with operators and of *descriptive general frames* are dually
   equivalent (`venema_2007_algebras_and_coalgebras`, Theorem 5.28; `blackburn_2002_ch05_sec05`,
   Theorems 5.76 and 5.81). Jónsson–Tarski alone gives only an *embedding* into the complex
   algebra of the ultrafilter frame, which is an inclusion `V_Λ ⊆ HSPCmK`, not the equality that
   completeness needs — Blackburn, de Rijke & Venema say this in as many words
   (`blackburn_2002_ch05_sec03`, the "Canonicity" subsection following Theorem 5.43).

2. **The section's declared obstruction — *Spherical* failing on ultrafilter frames at infinite
   carriers — is the textbook symptom of attempting a *discrete* duality where a *topological*
   one is required.** *Spherical* (`FormalSystem/Semantics/TaskFrame.lean:362`) is a
   directed-intersection condition on nonempty fibers and segments. That is, verbatim in shape,
   BdRV's `compact` condition on a general frame (`blackburn_2002_ch05_sec05`, Definition 5.65),
   and BdRV's Proposition 5.83(v) proves the corresponding statement — *every family of closed
   sets with the finite intersection property has nonempty intersection* — outright, for every
   descriptive general frame. It does **not** transfer to the bare Kripke reduct, and the reason
   it does not transfer in TM's case is identifiable: fibers `Fib(w,x) = R_x[w]` are indexed by
   durations `x ∈ D`, and **no operator of TM's similarity type denotes `R_x`**, so nothing in
   the algebra forces `R_x` to be point-closed on the dual space.

3. **That diagnosis makes the section's own aside about metric tense operators the principal
   repair route, not a side remark.** Adding duration-indexed operators `⟨x⟩` puts each `R_x`
   into the similarity type; descriptiveness of the dual general frame then makes each fiber
   closed (`blackburn_2002_ch05_sec05`, Proposition 5.83(iii)–(iv)), and Proposition 5.83(v)
   delivers *Spherical*. The cost the section already names — it changes the logic — is real and
   unavoidable, and is exactly the cost of moving `D` from the metatheory into the object
   language. The shift-set signature is the same move made externally.

4. **The shift-set programme's advertised payoff — first-order axiomatizability — is provably
   unavailable for two of the four frame classes, for a reason the section already half-states.**
   Successor-Archimedean discreteness (`TM_f`, i.e. `ℤ`) and Dedekind completeness (`TM_c`, i.e.
   `{ℤ, ℝ}`) are not first-order properties of ordered abelian groups. This is the *same* fact as
   the compactness failure the section records, and it also means Fine's theorem (elementary
   frame class ⟹ canonical, `venema_2007_algebras_and_coalgebras` Theorem 6.17) supplies nothing
   for those two classes. The base and dense classes are elementary and are where the programme
   can pay.

5. **The Lean algebraic layer is further from a BAO than the section implies.** It is sorry-free
   (verified: 0 sorries across all five files in `FormalSystem/Metalogic/Algebraic/`), but the
   quotient carries `boxQuot` (□) and `hQuot` (H) and **no `G` operator at all** — a *tense
   algebra* in the standard sense requires both directions (`venema_2007_algebras_and_coalgebras`
   Definition 8.3). Until `G` exists on the quotient, `LindenbaumAlg` is not a BAO for TM's
   similarity type and Jónsson–Tarski does not apply to it as stated.

6. **Acquisition**: 2 sources newly ingested into the global corpus (Venema's *Algebras and
   Coalgebras*, Handbook of Modal Logic ch. 6 — the single most important missing source for this
   section; and Gehrke & Vosmaer's canonical-extension survey), and 17 documents registered into
   the repo sub-index `specs/literature-index.json` (46 → 63 entries). Semantic Scholar (discovery
   Tier 3) was HTTP-429 rate-limited for the entire session, so no automated discovery ran;
   acquisition was done by direct open-access location instead. Several standard sources remain
   **not acquired** — see the acquisition table.

---

## Domain Analysis

| Domain | Why it is in scope |
|---|---|
| **Logic** (primary) | Modal/tense representation and duality theory, canonicity, Sahlqvist theory, product and multi-dimensional modal logics, general frames. |
| **Math** (secondary) | Boolean algebras with operators, Stone duality and Boolean spaces, varieties and Birkhoff's theorem, canonical extensions of lattice expansions, ordered abelian groups and their (non-)elementary properties. |
| Physics | Not in scope. No dynamical-systems content in this section. |

---

## Context & Scope

### 1.1 The Typst section as it currently reads

`typst/FormalFoundations.typ` lines 1151–1318, `= Toward a Representation Theorem
<sec:representation>`, with three subsections: *The Algebraic Layer*, *The Shift-Set Target*,
*The Obstruction*.

What it **claims**, and the status of each claim:

| Claim | Status |
|---|---|
| A representation theorem is the standard route to model existence, via compactness | Correct in general; but see §4.2 — the route is blocked for two of the four classes for a reason the section states elsewhere and does not connect here. |
| The Lindenbaum–Tarski algebra is live and sorry-free | **Verified.** 0 sorries in all five `Algebraic/` files. |
| □ acts as an interior operator on the quotient | **Verified** (`boxInterior`, `InteriorOperators.lean:142`). |
| "`#allpast` and `#allfuture` act as *interior operators*" | **Overstated.** The Lean README (`FormalSystem/Metalogic/Algebraic/README.md`) says the opposite: G and H are *not* interior operators under strict temporal semantics, `H_monotone` is the only surviving G/H-family result, and **there is no G operator on the quotient at all**. The definition block in the Typst section contradicts the module it cites. |
| Ultrafilters correspond bijectively to MCSs | **Verified** (`SetMaximalConsistent.ultrafilter_correspondence`, `UltrafilterMCS.lean:782`, plus both round trips at `:983` and `:1056`). |
| "What the layer supplies is one half of a duality" | Correct, and standard: BdRV Theorem 5.42 is precisely this (canonical frame ≅ ultrafilter frame of the Lindenbaum algebra). |
| Jónsson–Tarski route "archived"; blocked by *Spherical* at infinite carriers | **Verified as archived** (`FormalSystem/Boneyard/UltrafilterFrame/`, 3 sorries in `TenseS5Algebra.lean`, 4 in `UltrafilterFrame.lean`, all attributed to axioms removed in the BX cleanup — i.e. the archived sorries are *bookkeeping debt from an axiom-set change*, not the *Spherical* obstruction). The *Spherical* obstruction is asserted in prose, not witnessed by a sorry. |
| Shift sets: "no such identifier exists anywhere in the tree" | **Verified.** No hits. |
| Open question about a condition Φ preserved under `A ↦ A_+` | This is answerable from the literature — see §3.4. |

### 1.2 The Lean algebraic layer

`FormalSystem/Metalogic/Algebraic/` — 5 files, 2,887 lines, **0 sorries, 0 axioms**.

| File | Decls | Substance |
|---|---|---|
| `LindenbaumQuotient.lean` (393) | 14 defs, 19 thms | `Derives`, `ProvEquiv`, `LindenbaumAlg`, and the quotient operations `negQuot`, `impQuot`, `andQuot`, `orQuot`, `boxQuot`, `hQuot`, `topQuot`, `botQuot`, plus `sigmaQuot` (the TD past/future swap) with `sigma_quot_involution`, `sigma_quot_neg`, `sigma_quot_sup`, `sigma_quot_box`. |
| `BooleanStructure.lean` (441) | 6 defs, 15 thms | `BooleanAlgebra LindenbaumAlg`. |
| `InteriorOperators.lean` (176) | `InteriorOp` structure, `boxInterior` | `box_le_self`, `box_monotone`, `box_idempotent`, `H_monotone`. |
| `UltrafilterMCS.lean` (1,071) | 5 defs, 22 thms | local `Ultrafilter` on a `BooleanAlgebra`, `mcsToUltrafilter`, `ultrafilterToSet`, `ultrafilterToMcs`, and the bijection + both round trips. |
| `FlowFrame.lean` (806) | 27 thms | Countermodel engine; **six live importers**, unrelated to representation. |

**Three concrete gaps between this and a BAO for TM:**

- **No `G`.** TM's similarity type is `{□, G, H}` (and at the `TM⁺` level also the binary `U`, `S`).
  The quotient has `boxQuot` and `hQuot` only. Cheap fix available: `sigmaQuot` is an involution
  commuting with the Booleans, so `gQuot := sigmaQuot ∘ hQuot ∘ sigmaQuot` is one definition away.
- **No BAO instance.** Nothing states that the operations are normal and additive
  (`f(a ∨ b) = f a ∨ f b`, `f ⊥ = ⊥`), which is exactly the hypothesis Jónsson–Tarski consumes.
- **Base class only.** `Derives φ ψ := Derivable FrameClass.Base [] (φ.imp ψ)`
  (`LindenbaumQuotient.lean:46`). There is one Lindenbaum algebra, for the base logic. The
  per-frame-class algebras that a per-class completeness result would need do not exist.

### 1.3 *Spherical*, read precisely

```lean
def Spherical {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ S : Set (Set W), DirectedFamily S →
    (∀ s ∈ S, (IsFiber R s ∨ IsSegment R s) ∧ s.Nonempty) → (⋂₀ S).Nonempty
```
(`FormalSystem/Semantics/TaskFrame.lean:362`)

The module docstring identifies it as the downward-directed-intersection condition **S₁ᵈ** of the
Ćmiel–Kuhlmann–Kuhlmann hierarchy, *strictly stronger* than spherical completeness (S₁), and it is
consumed at exactly one site: the Step Lemma (`FormalSystem/Semantics/Extension/Step.lean:111`),
where it supplies a world state lying in every constraint so that a partial history can be
extended to a new time. **So *Spherical* is the frame's history-existence saturation axiom, and it
is a compactness condition.** This identification is what the whole of §3 below turns on.

---

## Part 2 — Literature Inventory and Acquisition

### 2.1 Method and a tooling finding worth recording

`literature-search.sh` is FTS5-backed and AND-s query terms; **queries longer than 2–4 words
return nothing**. Every search below used short queries.

**Tier-3 discovery was unavailable for the whole session.** `literature-discover.sh` returned
`TIER3_STATUS: FAILED reason=http http_code=429 (Semantic Scholar rate-limited or unreachable)`
on every one of 20+ attempts across ~35 minutes and 3 distinct queries with 75 s backoff. Tiers 1
and 2 (global index, Zotero) worked. Acquisition therefore proceeded by locating open-access
copies directly and feeding hand-built records to `literature-ingest-online.sh`. This is recorded
as an environment failure, not a research finding.

**The Zotero library holds essentially none of this literature.** `zotero-search.sh` returned
**zero** results for `Sahlqvist` and for `duality`; `Jonsson1951`, `Jonsson1952`, `Kurucz2003`,
`Goldblatt2006`, `Marx1997` are present as *metadata only* — every one has `pdf_paths: []`. There
is no in-Zotero PDF to attach for any algebraic-duality source.

### 2.2 Standard-sources checklist

Present = in the global corpus at `~/Projects/Literature/sources/`.
Curated = also in `specs/literature-index.json`.

| Source | Status before | Action taken | Status now |
|---|---|---|---|
| Jónsson & Tarski 1951, 1952, *Boolean Algebras with Operators* I, II | present, curated | — | curated; **fidelity caveat**, see §2.4 |
| Blackburn–de Rijke–Venema 2002, *Modal Logic*, ch. 5 §5.1–5.3 | present, curated | — | curated |
| BdRV ch. 5 §5.4 Duality Theory | present, **uncurated** | registered | curated |
| BdRV ch. 5 §5.5 General Frames | present, **uncurated** | registered | curated |
| BdRV ch. 5 §5.6–5.7 Persistence | present, **uncurated** | registered | curated |
| BdRV ch. 3 §3.5–3.6 Sahlqvist correspondence | present, **uncurated** | registered | curated |
| BdRV ch. 3 §3.7 More Sahlqvist / Kracht's theorem | present, **uncurated** | registered | curated |
| BdRV ch. 7 §7.5 Multi-Dimensional Modal Logic | present, **uncurated** | registered | curated |
| Goldblatt 1989, *Varieties of Complex Algebras* | present, curated | — | curated; **locator only**, see §2.4 |
| Goldblatt 2006, *Mathematical modal logic: a view of its evolution* | present, curated | — | curated |
| Goldblatt–Hodkinson–Venema, *Erdős Graphs Resolve Fine's Canonicity Problem* (`goldblatt_2003`) | present, **uncurated** | registered | curated |
| de Rijke & Venema 1995, *A Sahlqvist Theorem for BAOs* | present, **uncurated** | registered | curated |
| Venema 1991, *Many-Dimensional Modal Logics* (PhD thesis) | present, **uncurated** | registered | curated |
| Venema 1993, *Derivation Rules as Anti-Axioms* | present, **uncurated** | registered | curated |
| Venema 1997, *Atom Structures and Sahlqvist Equations* | present, **uncurated** | registered | curated |
| Gabbay–Kurucz–Wolter–Zakharyaschev 2003, *Many-Dimensional Modal Logics* | present, **uncurated** | registered | curated; `unverified_conversion` |
| Chagrov & Zakharyaschev 1997, *Modal Logic* (OLG 35) | present, **uncurated** | registered | curated; DJVU-derived |
| Zakharyaschev et al. 2001, *Advanced Modal Logic* (§2 polymodal) | present, **uncurated** | registered | curated |
| R. H. Thomason 1984, *Combinations of Tense and Modality* | present, **uncurated** | registered | curated |
| **Venema 2007, *Algebras and Coalgebras* (HBML ch. 6)** | **ABSENT** | **located OA and ingested** | **new, curated** |
| **Gehrke & Vosmaer, *A View of Canonical Extension*** | **ABSENT** | **located OA and ingested** | **new, curated** |
| Gehrke & Jónsson 2004, *Bounded distributive lattice expansions* | ABSENT | OA link 404s (see table below) | **not acquired** |
| Sambin & Vaccaro 1988, *Topology and duality in modal logic* | ABSENT | no OA copy found | **not acquired** |
| S. K. Thomason 1972, *Semantic analysis of tense logics* | ABSENT | JSTOR/CUP paywall | **not acquired** |
| S. K. Thomason 1975, *Categories of frames for modal logic* | ABSENT | CUP paywall | **not acquired** |
| Goldblatt 1976, *Metamathematics of modal logic* I, II | ABSENT | not attempted (Tier 3 down) | **not acquired** |
| Fine 1975, *Some connections between elementary and modal logic* | ABSENT | not attempted (Tier 3 down) | **not acquired** |
| Kracht 1999, *Tools and Techniques in Modal Logic* | ABSENT | commercial monograph | **not acquired** |
| Esakia 1974 / 2019, duality for Heyting algebras | ABSENT | commercial | **not acquired** |
| Halmos, *Algebraic Logic* | ABSENT | commercial | **not acquired** |
| Davey & Priestley, *Introduction to Lattices and Order* | ABSENT | commercial | **not acquired** |
| Gabbay & Shehtman, *Products of modal logics I* | ABSENT | not attempted (Tier 3 down) | **not acquired** |
| Marx & Venema 1997, *Multi-Dimensional Modal Logic* | ABSENT (Zotero metadata only, no PDF) | monograph, no OA copy | **not acquired** |

**Mitigation for the not-acquired items.** The three that matter most are covered by proxies now
in the corpus: Goldblatt 1976 and Esakia's duality theorem are *stated with attribution* as
Theorem 5.28 of `venema_2007_algebras_and_coalgebras`; Gehrke–Jónsson's canonical-extension
framework is surveyed in `gehrke_vosmaer_2011_view-of-canonical-extension`; Fine 1975 is stated as
Theorem 6.17 of `venema_2007_algebras_and_coalgebras`. Sambin–Vaccaro and the two S. K. Thomason
papers have **no proxy in the corpus** and remain a genuine gap for the historical narrative.

### 2.3 Acquisition attempts, per record

| Source | Discovery status | Ingest token | Result |
|---|---|---|---|
| Venema 2007, HBML ch. 6, via `cgi.csc.liv.ac.uk/~frank/MLHandbook/6.pdf` | manual (Tier 3 down) | `ONLINE_INGEST_DOWNLOAD_FAILED`, then on retry the file proved to be a 3-page front-matter extract only | rejected as incomplete |
| Venema 2007, HBML ch. 6, via `staff.fnwi.uva.nl/y.venema/papers/ac.pdf` (author's copy, 86 pp.) | manual | `ONLINE_INGEST_PIPELINE_FAILED` (quality gate) — Zotero item created, PDF staged | repaired and installed manually; **doc_id `venema_2007_algebras_and_coalgebras`, 173 chunks** |
| Gehrke & Vosmaer, arXiv 1009.2803 | manual | `ONLINE_INGEST_ZOTERO_CREATE_FAILED` (`item-add` rejects a record with no DOI) — PDF downloaded and verified | repaired and installed manually; **doc_id `gehrke_vosmaer_2011_view-of-canonical-extension`, 38 chunks** |
| Gehrke & Jónsson 2004, `mscand.dk/article/download/14428/12425/33863` | manual | n/a | HTTP 404 on all three URL forms; the OJS article page exposes only BibTeX/RIS links. **Not acquired.** |
| Sambin & Vaccaro 1988 | manual web search | n/a | No open-access copy located. Elsevier APAL vol. 37 is not in the open archive. **Not acquired.** |
| Sambin–Vaccaro / Gehrke–Jónsson / both Thomason papers / Goldblatt 1976 / Fine 1975 / Jónsson 1994 / Kracht 1999 / Gabbay–Shehtman, via `literature-discover.sh` | `tier3_rate_limited_all_attempts` (HTTP 429 × 5 each) | n/a | **Not attempted further.** No discovery record was ever produced, so nothing was passed to the bridge. |
| Marx & Venema 1997, Kurucz 2003, Goldblatt 2006, Jónsson 1951 | Tier 2 `in_zotero_no_pdf` | not run | Zotero holds metadata only (`pdf_paths: []`) and the bridge's Unpaywall path needs a DOI these records lack. Kurucz 2003 and Goldblatt 2006 are already in the corpus by other routes. **Marx & Venema not acquired.** |

### 2.4 Fidelity flags on sources cited in this report

| doc_id | `provenance_fidelity` | What it means for citation |
|---|---|---|
| `blackburn_2002_book` and its `ch*` slices | `verified_conversion` (parent) | Reliable. Page-numbered OCR read directly. |
| `venema_2007_algebras_and_coalgebras` | `unverified_conversion` (new) | Prose, definitions and theorem statements read clean. Commutative diagrams and display-math layout are linearised. Verify equations against the sibling PDF before transcribing into Lean. |
| `gehrke_vosmaer_2011_view-of-canonical-extension` | `unverified_conversion` (new) | Same caveat; Hasse diagrams are unreadable in text. |
| `goldblatt_2003` | `verified_conversion` | Reliable. |
| `derijke_1995` | `verified_conversion` | Reliable. |
| `thomason_1984` | `verified_conversion` | Reliable. |
| `goldblatt_1989` | **`unset`; the markdown carries its own OCR FIDELITY WARNING: "USE THIS FILE ONLY AS A ROUGH LOCATOR … Do not quote this text."** | **Every claim sourced from it in this report is PROVISIONAL and must be checked against the page images in the sibling PDF before it reaches the Typst file.** |
| `j_nsson_and_tarski_-_1951/1952` | `unverified_conversion` | Prose reliable, formulas degraded (JSTOR scan). The sub-index's `terminology_hazard` field also records that the originals use *perfect extension*, never "ultrafilter". |
| `gabbay_kurucz_wolter_zakharyaschev_2003` | `unverified_conversion` | Verify any theorem statement against the PDF. |
| `hughes_1996` | **`no_source_pdf`** | Not cited in this report. Do not cite. |

### 2.5 Post-acquisition verification

```
$ jq '.entries|length' specs/literature-index.json          → 63   (was 46)
$ jq '.entries|length' ~/Projects/Literature/index.json      → 11545 (was 11543; +2)
$ ls ~/Projects/Literature/sources/ | wc -l                  → 295   (was 293; +2)
$ literature-build-index.sh --global                         → 32999 chunks, 289 distinct doc_ids, OK
$ literature-search.sh "Jonsson Tarski"                      → 20 hits
$ literature-search.sh "descriptive general"                 → 20 hits
$ literature-search.sh "tense algebra"                       → 19 hits
$ literature-search.sh "canonical extension"                 → 20 hits
```
A backup of the global index was written to `~/Projects/Literature/index.json.bak-task503` and of
the sub-index to `specs/literature-index.json.bak-503`.

---

## Findings

### 3.1 Logic domain: what Jónsson–Tarski does and does not give

**The theorem.** `blackburn_2002_ch05_sec03`:

- Definition 5.34 (filters, ultrafilters), Proposition 5.38 (Ultrafilter Theorem, via Zorn).
- Theorem 5.16 (Stone representation): `r(a) = {u ∈ Uf A | a ∈ u}` embeds any Boolean algebra
  into `P(Uf A)`.
- Definition 5.40: the **ultrafilter frame** `A_+ = (Uf A, Q_f)` with
  `Q_f u u₁ … uₙ ⟺ f(a₁,…,aₙ) ∈ u for all aᵢ ∈ uᵢ`; the **canonical embedding algebra**
  `Em A := (A_+)^+`.
- Theorem 5.42: the canonical frame of a normal modal logic Λ **is** the ultrafilter frame of its
  Lindenbaum–Tarski algebra, `F^Λ ≅ (L_Λ(Φ))_+`. *This is precisely the correspondence the Lean
  layer proves at `UltrafilterMCS.lean:782`.*
- **Theorem 5.43 (Jónsson–Tarski)**: `r` is an embedding of `A` into `Em A`.

**What it does not give — and BdRV say so explicitly.** From the "Canonicity" subsection
immediately after Theorem 5.43:

> "does the Jónsson-Tarski Theorem establish such a thing? **Not really** — it does show that
> every algebra `A` is a complex algebra over some frame, thus proving that for any logic Λ we
> have that `V_Λ ⊆ CmK` for some frame class `K`. So, this certainly gives `V_Λ ⊆ HSPCmK`.
> **However, in order to prove completeness, we have to establish an equality instead of an
> inclusion.**"

The missing step is **canonicity**: Definition 5.44 (a class of BAOs is canonical if closed under
`Em`), Proposition 5.45 (`V_Γ` a canonical variety ⟹ Γ a canonical set of formulas). BdRV then
record **Open Problem 1**: is the converse true? — still open.

**This is the honest shape of the section's difficulty and it should be stated in these terms.**
The archived Lean route stalled not because Jónsson–Tarski is hard but because Jónsson–Tarski is
*not enough*: it hands you `A ↣ Em A`, and you still owe a proof that `A_+` is a frame *of the
class you care about*.

### 3.2 Math domain: duality, and why the disjoint-union question in the section is already settled

`blackburn_2002_ch05_sec04`:

- **Theorem 5.47** (contravariant duality): `F ↣ G ⟹ G⁺ ↠ F⁺`; `F ↠ G ⟹ G⁺ ↣ F⁺`; and dually
  for algebras.
- **Theorem 5.48**: `(⨿ᵢ Fᵢ)⁺ ≅ ∏ᵢ Fᵢ⁺` — the complex algebra of a disjoint union is the product
  of the complex algebras. **The converse fails**: in general `(∏ᵢ Aᵢ)_+ ≠ ⨿ᵢ (Aᵢ)_+`
  (Exercise 5.4.1: a countable product of finite algebras has uncountably many ultrafilters while
  the disjoint union of their ultrafilter frames is countable). This bears directly on the
  section's open remark about "the coset-domain construction … route to disjoint-union closure":
  **disjoint-union closure is available on the frame-to-algebra side and provably unavailable on
  the algebra-to-frame side.**
- **Theorem 5.54 (Goldblatt–Thomason)**: a class of frames closed under ultrapowers is modally
  definable iff it is closed under bounded morphic images, generated subframes and disjoint
  unions, and reflects ultrafilter extensions. Proved in three paragraphs from Birkhoff's theorem
  plus Theorems 5.47/5.48.
- **Theorem 5.56**: if `K` is closed under ultraproducts then `V_K = HSPCmK` is canonical.
  Corollary 5.58: the modal theory of such a `K` is a canonical logic. This is Fine's theorem in
  algebraic dress.
- **Open Problem 2**: is every canonical variety generated by some ultraproduct-closed class? —
  **settled negatively**, see §3.3.

### 3.3 Canonicity: what is preserved, what is not, and the limits

From `venema_2007_algebras_and_coalgebras` (new to the corpus):

- Definition 6.9/6.10 and **Theorem 6.11**: the logical and algebraic notions of canonicity
  coincide — `L` is canonical iff `BAO_τ(L)` is a canonical variety.
- **Theorem 6.12**: canonical ⟹ complete.
- Definition 6.13 (Sahlqvist formula: `ϕ → ψ` with `ϕ` built from negative formulas, **boxed
  atoms** and constants using modalities, `∧` and `∨`, and `ψ` positive) and
  **Theorem 6.14 (Sahlqvist Canonicity): every Sahlqvist formula is canonical.**
  Corollary 6.15: a logic axiomatised by Sahlqvist axioms is sound and complete w.r.t. the
  elementary frame class its first-order correspondents define.
- **Theorem 6.17 (Fine)**: `K` elementary ⟹ `Log(K)` canonical.
- **Theorem 6.18 (Goldblatt, Hodkinson & Venema)**: *there is a canonical variety that is not
  generated by any elementary frame class* — BdRV's Open Problem 2, answered negatively, via
  Erdős's high-chromatic-number/high-girth graphs. Corroborated by `goldblatt_2003` §1 and §2.3,
  which is the paper itself.
- **Canonicity is undecidable** (Kracht, cited at `venema_2007_algebras_and_coalgebras` §6.2).
- Remark 6.16: the Sahlqvist fragment is not the whole story — Goranko–Vakarelov *inductive*
  formulas widen it; `4 ∧ McKinsey` is canonical without being Sahlqvist.

`blackburn_2002_ch03_sec05-06`, Definition 3.51 and Theorem 3.54, give the correspondence half,
and Example 3.48 names what is *forbidden* in a Sahlqvist antecedent (boxes over disjunctions,
boxes over diamonds). Theorem 3.56 (Chagrova): it is **undecidable** whether an arbitrary modal
formula has a first-order correspondent. `blackburn_2002_ch03_sec07`, Theorem 3.59 (Kracht):
Kracht formulas are exactly the first-order correspondents of Sahlqvist formulas.

#### Classification of TM's axioms against Definition 3.51 / 6.13

This classification is **my own reading of the definition, not a literature claim**, and should be
re-derived before it goes into the Typst file. It is stated for the schema-instances with distinct
proposition letters.

| Axiom | Shape | Sahlqvist? | First-order correspondent |
|---|---|---|---|
| MT | `□p → p` | ✅ boxed atom → positive | reflexivity of `R_□` |
| M5 | `◇□p → □p` | ✅ ◇ on a boxed atom → positive | Euclideanness |
| MF | `□p → □Gp` | ✅ | `R_G ∘ R_□ ⊆ R_□` (a Church–Rosser/inclusion condition; cf. `blackburn_2002_ch03_sec05-06` Example 3.44) |
| T4 | `Gp → GGp` | ✅ | transitivity of `R_F` |
| TB | `F⊤` | ✅ | seriality |
| TA | `p → GPp` | ✅ | `R_P ⊇ R_F⁻¹` (converse) |
| TL | `(Fp ∧ Fq) → [F(Fp∧q) ∨ F(p∧q) ∨ F(p∧Fq)]` | ✅ — the antecedent is `◇` applied to boxed atoms joined by `∧`, which Definition 3.51 permits | connectedness / no branching |
| DN | `GGp → Gp` | ✅ | density |
| DF | `(Hp ∧ p ∧ F⊤) → FHp` | ✅ | forward discreteness: every point with a successor has an immediate successor |
| NB | `⊙⊤ → □⊙⊤` | ✅ | — |
| **CO** | `Always(Pp → FPp) → (Pp → Gp)` | ❌ — the antecedent is a box over an implication in which `p` occurs both positively and negatively; neither a boxed atom nor negative | **none available by this route** |
| **Z1** | `G(Gp→p) → (FGp → Gp)` | ❌ — same reason | none |
| UC, UG | `G(φ→ψ) → …` | ❌ — box over an implication | none |
| UZ, Prior-U, Sep | — | ❌ | none |

**Reading**: everything that makes TM a bimodal S5-plus-linear-tense logic is Sahlqvist and
therefore canonical. Everything that pins down *which* linear order — the discreteness induction
axiom Z1, the Dedekind-completeness axiom CO, the separation axiom Sep — falls outside the
fragment. That is the standard picture: `venema_1993_anti_axioms` is the corpus's source for the
doctrine that such conditions are handled by non-orthodox *derivation rules* rather than axioms.

#### Two non-elementarity facts that the section needs and does not yet state

Both are standard model theory, not modal logic, and I state them as such rather than citing a
corpus document:

- **Archimedeanness is not first-order.** The theory of `(ℤ, +, <)` as an ordered abelian group
  has non-Archimedean models (e.g. `ℤ × ℤ` lexicographically, which is *also* discrete). So the
  successor-Archimedean discrete class — `TM_f`'s class, which Hölder's theorem identifies with
  `ℤ` — **is not an elementary class.**
- **Dedekind completeness is not first-order.** `ℝ` has non-Archimedean elementary extensions. So
  `TM_c`'s class `{ℤ, ℝ}` **is not an elementary class.**

Both classes are, by contrast, *closed under nothing useful*: neither is closed under ultrapowers,
so **Theorem 5.56 / Theorem 6.17 (Fine) supplies no canonicity for `TM_f` or `TM_c`.** By
Theorem 6.18 that is a *gap in the argument*, not a refutation — non-elementarity does not
preclude canonicity — but the section must not pretend otherwise in either direction.

The base class (ordered abelian groups) and the dense class (dense ordered abelian groups) **are**
elementary, and are ultraproduct-closed, so Theorem 5.56 does apply there.

### 3.4 The obstruction, diagnosed: topological duality is the missing layer

This is the report's central finding.

**The definitions line up.** `blackburn_2002_ch05_sec05`, Definition 5.65:

> *compact* if `⋂A' ≠ ∅` for every subset `A'` of `A` which has the finite intersection property

Compare *Spherical*: `⋂₀ S ≠ ∅` for every `⊇`-directed family `S` of nonempty fibers and segments.
A `⊇`-directed family is exactly a family with witnessed finite intersections. **These are the
same condition, restricted in the TM case to fibers and segments rather than all admissible sets.**

**And the literature proves it, on the right structure.** A general frame is *descriptive* if it is
differentiated, tight and compact (Definition 5.65). Then:

- **Proposition 5.69**: the canonical general frame `f^Λ` of any normal modal logic **is
  descriptive**, and its compactness is proved by exactly the Lindenbaum argument — a family of
  `φ̂` with the fip means `Σ` is consistent, so `Σ` extends to a maximal consistent set in the
  intersection.
- **Theorem 5.76**: `A•` — the ultrafilter frame *together with the admissible sets* `{â : a ∈ A}`
  — is a descriptive general frame; `(A•)° ≅ A`; and `(g°)• ≅ g` iff `g` is descriptive.
- **Theorem 5.81** and, in categorical form, `venema_2007_algebras_and_coalgebras`
  **Theorem 5.28 (Goldblatt; independently Esakia)**: the functors `(·)_*` and `(·)^*` constitute
  a **dual equivalence** between `BAO_τ` and `DGF_τ`.
- The topological statement (`blackburn_2002_ch05_sec05`, "Topology" subsection;
  `venema_2007_algebras_and_coalgebras` Remark 5.21 and Remark 5.26): `g` is descriptive iff
  `(W, T_A)` is a Boolean/Stone space with `A` the clopens **and `R` point-closed**; descriptive
  general frames *are* point-closed relational Stone spaces.
- **Proposition 5.83**, for descriptive `g`: (i) singletons are closed; (ii) closed sets are closed
  under finite unions and arbitrary intersections; (iii) `R_◇[c]` is closed for closed `c`;
  (iv) `R_α[s]` is closed for every point `s` and every compound modality `α`; and
  **(v) every family of closed sets with the fip has nonempty intersection.**

**So a *Spherical*-shaped conclusion is a theorem in the descriptive setting.** Proposition
5.83(v) *is* the directed-intersection property, provided the fibers and segments in question are
closed sets.

**And this pinpoints exactly why it fails for TM.** By 5.83(iv), `R_α[s]` is closed **for `α` a
compound modality of the similarity type**. TM's similarity type is `{□, G, H}` (plus `U`, `S`).
The fibers `Fib(w, x) = R_x[w]` are indexed by *durations* `x ∈ D`, and **`R_x` is not denoted by
any operator of the language.** The algebra therefore carries no information about `R_x` at all,
nothing forces `R_x` to be point-closed on the dual space, and Proposition 5.83 does not apply.
That is a complete and unromantic account of "*Spherical* fails at infinite carriers": the
duration-indexed structure is invisible to the algebra, so the dual construction cannot be
expected to reproduce it.

**Answer to the section's Open Question.** The section asks for a condition Φ that (a) holds of
finite-carrier and deterministic frames, (b) suffices for the Step Lemma in place of *Spherical*,
and (c) is preserved under `A ↦ A_+`. The literature says: **(c) is the wrong requirement.** No
compactness-flavoured condition survives the passage to the bare Kripke reduct `A_+`, because that
passage discards the topology which is where compactness lives (`venema_2007_algebras_and_coalgebras`
§5.4 opens with exactly this: "in general, algebras cannot be retrieved from their ultrafilter
frames. A very simple remedy is then to add this information to the frame"). What *is* preserved
is the condition on `A•`, the descriptive general frame, where compactness is definitional. The
question should be re-posed as: **is there a condition Φ on task relations, satisfied by the
*descriptive general frame* `A•` of every TM-algebra, that suffices for the Step Lemma?**

Two routes follow, both supported:

- **Route T (topological)**: aim at the descriptive general frame, not the task frame. Then
  Theorem 5.28 gives a *full duality*, immediately, off the shelf, and Theorem 5.64 gives what the
  section says it wants — **every normal modal logic is sound and strongly complete with respect
  to the class of general frames**. The price: the dual object is a general frame, not a task
  frame, and the section's declared target is task models.
- **Route M (metric operators)**: put each `R_x` into the similarity type as an operator `⟨x⟩`.
  Then 5.83(iii)–(iv) make fibers and segments closed and 5.83(v) delivers *Spherical* on `A•`.
  The section already contemplates this and correctly identifies the price: the logic changes and
  the existing completeness results do not transfer. What the section should add is that **this is
  not a stylistic proposal — it is the standard mechanism for exactly this obstruction**, and that
  the shift-set signature `(Ω, D; <, +, 0, sh, (A_p))` is the same move made in the metatheory
  instead of the object language.

### 3.5 The bimodal / two-dimensional dimension

**Tense algebras are special, in a way the project can use.** `venema_2007_algebras_and_coalgebras`
§8.1:

- Definition 8.2/8.3: a `ϑ`-frame is *bidirectional* if `R_F` and `R_P` are converses; a **tense
  algebra** is a Boolean algebra with monotone `◇_F, ◇_P` satisfying `x ⪯ □_F◇_P x` and
  `x ⪯ □_P◇_F x`. TM's **TA** axiom `φ → G P φ` and its TD-dual are exactly these.
- **Theorem 8.4 (attributed to Jónsson & Tarski)**: in a tense algebra, (i) `◇_F` and `◇_P` are
  **complete operators** — they preserve *all* existing joins, not merely finite ones; (ii) `A•` is
  a bidirectional frame and `A^σ` is again a tense algebra.
- Proposition 8.5: tense algebra ⟺ `◇_F, ◇_P` conjugated ⟺ `(◇_F, □_P)` a residual pair. "Tense
  logic is not just any bimodal logic: it provides the modal logic manifestation of adjoint
  functors."
- **Theorem 8.6**: for an **atomic** tense algebra `A` and any Sahlqvist equation `η`:
  `A ⊨ η ⟺ A_+ ⊨ c_η ⟺ (A•)⁺ ⊨ η`. Venema: "tense algebras are richer than ordinary BAOs …
  in case `A` is a tense algebra, it contains sufficient information to enforce this."

**This is a live, usable asset the section does not mention.** Complete additivity is precisely the
property that makes the *atom-structure* (discrete) duality work, and TA gives it for free.

**TM's □ is a global modality, and that has strong consequences.** `venema_2007_algebras_and_coalgebras`
§8.2, Definition 8.11: `γ(x)` is a global modality for `L` iff `γ` satisfies the S5 axioms *plus*
the inclusion axiom `∇ᵢ x → γ(x)` for every induced diamond. Theorem 8.10: any variety with a
discriminator term has **all its algebras simple**, is congruence-distributive and
congruence-permutable, has s.i. = simple, and is **semi-simple**. Venema names the case explicitly:
"as an example we mention the compound modality `◇_F ◇_P` in the tense logic over any linear flow
of time" is the global relation. TM's semantics makes `□` quantify over *every* history at the
given time, and TL forces linearity, so the compound term `γ(x) := □(x ∨ Fx ∨ Px)` is a candidate
global modality for TM. **If it is one, `BAO(TM)` is a discriminator variety and Theorem 8.10
applies wholesale.** This is a checkable claim with a large payoff and I flag it as *unverified*.

**Products and negative results.** `gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics`
and `blackburn_2002_ch07_sec05` are the references for the product/fusion distinction and for the
negative results about products with an S5 factor and a linear factor. See the delegated findings
appended in §6 for what was extractable; the doc carries `unverified_conversion`, so any theorem
number taken from it must be checked against the PDF.

**The task-frame semantics is not a product, and the difference matters.** In a product frame
`F₁ × F₂` the point set is the full Cartesian product and valuations are arbitrary subsets of it.
Here the point set is `H_F × D` but the atomic clause reads `M, τ, x ⊨ pᵢ ⟺ τ(x) ∈ |pᵢ|` — a
valuation is a set of **world states**, pulled back along `ev : H_F × D → W`, `(τ,x) ↦ τ(x)`.
Since `ev` is far from injective, the admissible propositions on the two-dimensional point set form
a **proper subalgebra** of `P(H_F × D)`. See §5, Risk 3.

---

## Decisions

Research-level decisions taken while producing this report. Each was a fork in the investigation,
not a conclusion about TM; the conclusions are in **Findings** and **Recommendations**.

- **Treat the Goldblatt/Esakia duality, not Jónsson–Tarski, as the target theorem.** Jónsson–Tarski
  yields an embedding and an inclusion `V_Λ ⊆ HSPCmK`; the section needs an equality. The full dual
  equivalence `BAO_τ ≃ DGF_τ^op` is what "representation theorem" should name here. This reframing
  drives the whole of Findings §3.4 and the six-rung ladder in Part 4.
- **Diagnose *Spherical* as a compactness condition rather than an idiosyncratic frame axiom.**
  Once its definition is read against BdRV Definition 5.65, the obstruction stops being specific to
  task frames and becomes an instance of a known discrete-vs-topological duality mismatch. Chosen
  over the alternative of hunting for a bespoke weakening of *Spherical*, which is what the
  section's current Open Question invites.
- **Treat metric tense operators as the principal repair route, not an aside.** Given the diagnosis,
  enriching the similarity type is the standard mechanism for exactly this failure. The section's
  existing accounting of its cost is kept and endorsed rather than argued down.
- **Register the uncurated global-corpus documents rather than re-ingest them.** Fifteen relevant
  documents were already converted and chunked in `~/Projects/Literature/sources/` but absent from
  the repo sub-index, so `--lit` runs never saw them. Adding sub-index entries was the correct
  minimal action; re-ingestion would have risked fidelity regressions on already-verified files.
- **Use Gehrke & Vosmaer's survey as a proxy for Gehrke & Jónsson 2004.** The primary source's
  open-access URL 404s on every form. The survey covers the canonical-extension framework the
  section needs and was acquirable; the substitution is recorded rather than silently made.
- **Install the two new documents manually after the conversion quality gate rejected them.** Each
  gate hit was inspected individually and found to be either a benign journal-abbreviation match or
  an unmapped CMEX delimiter glyph. A determinate, context-verified character repair was applied and
  documented in each file header and index `conversion_note`, rather than either bypassing the gate
  silently or abandoning the sources.
- **Keep the delegated sub-agent findings advisory only.** Both sub-agents were still running at
  finalisation. Every claim in this report is sourced to a document read directly; nothing rests on
  a delegated summary. See Part 6.
- **State the non-elementarity of Archimedeanness and Dedekind completeness as standard model
  theory, not as a corpus citation.** No document in the corpus asserts it, and inventing a citation
  would be worse than attributing it correctly to background theory.

## Part 4 — Cross-Domain Synthesis

Four threads converge on one statement.

**(a) Algebra.** Jónsson–Tarski gives an embedding, not an equality; the gap is canonicity
(BdRV Thm 5.43 + the Canonicity subsection).

**(b) Topology.** The gap closes if you keep the topology: BAOs and descriptive general frames are
dually equivalent (Venema 2007 Thm 5.28), and in a descriptive general frame the compactness
statement *Spherical* wants is a theorem (BdRV Prop 5.83(v)).

**(c) Similarity type.** The topology only sees the operators of the language. TM has no
duration-indexed operator, so it cannot see `R_x`, so its fibers are not forced closed, so
*Spherical* is not recoverable — **exactly the failure the section reports.**

**(d) Model theory.** The two frame classes where the section already knows compactness fails —
`ℤ`-time and `ℝ` — are exactly the two non-elementary classes. Non-elementarity is simultaneously
(i) why compactness fails, (ii) why Fine's theorem gives no canonicity there, and (iii) why the
shift-set programme's first-order payoff cannot be had there.

**The synthesis**: *the representation theorem is not one theorem with one obstruction. It is a
ladder, and the section is standing on the third rung while describing the fourth.*

| Rung | Statement | Status for TM |
|---|---|---|
| 1 | Lindenbaum–Tarski algebra exists, is Boolean, ultrafilters ≅ MCSs | **Done in Lean, sorry-free** |
| 2 | The algebra is a BAO for the full similarity type `{□, G, H, U, S}` | **Not done** — no `G` on the quotient, no normality/additivity lemmas |
| 3 | Jónsson–Tarski: `A ↣ Em A`; `F^Λ ≅ (L_Λ)_+` | Available off the shelf; the Lean half of it (`ultrafilter_correspondence`) is done |
| 4 | Full duality with descriptive general frames | **Available off the shelf** (Thm 5.28); would give strong completeness (Thm 5.64) |
| 5 | The dual Kripke reduct is a **task frame** (Compositionality, Seriality, Limit, *Spherical*) | **Blocked at *Spherical*.** Not an accident; a consequence of rung 2's similarity type |
| 6 | Per-class: the dual frame is discrete / dense / Dedekind-complete | Elementary and reachable for dense; **provably out of first-order reach for `ℤ` and `ℝ`** |

---

## Recommendations

### 5.1 Proposed structure for `<sec:representation>`

Each element tagged: **[L]** already proved in Lean · **[S]** provable with standard tools, source
named · **[H]** open or hard · **[N]** known negative result.

**§ 5.1 What "representation" would mean here** — replace the current opening. State the ladder
above explicitly. Distinguish (i) an algebraic representation (`A ↣ Em A`), (ii) a duality
(`BAO ≃ DGF^op`), (iii) a *task-frame* representation, and (iv) a first-order (shift-set)
axiomatization. The section currently uses "representation theorem" for all four.

1. **Boolean algebras with operators; complex algebras** — [S] `blackburn_2002_ch05_sec01-02`.
2. **The Lindenbaum–Tarski algebra of TM** — [L] `LindenbaumQuotient.lean`, `BooleanStructure.lean`.
   **Correct the current definition block**: □ is an interior operator; G and H are *not*, and G is
   not defined on the quotient at all. Cite `InteriorOperators.lean:29-43`, which says so.
3. **`G` on the quotient, and the BAO instance** — [S], and cheap: `sigmaQuot` is already there and
   involutive, so `gQuot := sigmaQuot ∘ hQuot ∘ sigmaQuot`. Normality and additivity are the
   remaining obligations. **This is the smallest concrete step that moves the section forward.**
4. **Tense algebra structure from TA** — [S] `venema_2007_algebras_and_coalgebras` Def 8.3,
   Prop 8.5, Thm 8.4. Yields **complete additivity for free** — worth stating, because the section
   currently presents the algebra as inert.
5. **Ultrafilters ≅ MCSs; the ultrafilter frame** — [L] `UltrafilterMCS.lean:782`; [S] textbook
   statement `blackburn_2002_ch05_sec03` Def 5.40, Thm 5.42.
6. **Jónsson–Tarski, and precisely what it leaves undone** — [S] Thm 5.43 plus the "inclusion, not
   equality" quotation. **This replaces the section's current framing of the route as "blocked";
   it is not blocked, it is insufficient, and the reason is canonicity.**
7. **Canonicity** — [S] Def 5.44/Prop 5.45; Sahlqvist canonicity (Thm 6.14); the axiom-by-axiom
   table of §3.3. Say plainly which TM axioms are Sahlqvist and which are not.
8. **Descriptive general frames and the Goldblatt/Esakia duality** — [S]
   `venema_2007_algebras_and_coalgebras` Thm 5.28, `blackburn_2002_ch05_sec05` Def 5.65, Thms 5.76,
   5.81, Prop 5.83. **The new centre of gravity of the section.**
9. **Why *Spherical* is a compactness axiom, and why it does not descend to `A_+`** — [S] the
   diagnosis of §3.4. Re-pose the Open Question over `A•` rather than `A_+`.
10. **Route M: metric operators** — [H], with the mechanism now named. Keep the section's honest
    accounting of the cost.
11. **Route S: shift sets** — [H] for base and dense; **[N] for `TM_f` and `TM_c`** — see 5.2.
12. **What is foreclosed** — [N] non-compactness over `ℤ` and `ℝ`; Chagrova's theorem (Thm 3.56)
    and Kracht's undecidability of canonicity, which bound how much can ever be automated;
    `(∏ Aᵢ)_+ ≠ ⨿ (Aᵢ)_+` (Exercise 5.4.1), which settles the disjoint-union aside.

### 5.2 What the representation result actually amounts to for TM — candidly

- For the **base class**: a genuine target. The class of ordered abelian groups is elementary; the
  frame conditions *Compositionality*, *Seriality* and *Limit* are all expressible in the two-sorted
  signature (*Limit* is an infinite intersection but its unfolding `∀u (∀x>0. u ∈ (w)_x) → u = w`
  quantifies over `D`, a sort). **Only *Spherical* is second-order** — it quantifies over families of
  subsets of `W`. So the shift-set claim "the class of task models is captured by a first-order
  theory" is **true for three of the four frame axioms and false for the fourth as stated.** The
  section should say this: the whole difficulty of the shift-set programme, like the whole difficulty
  of the Jónsson–Tarski programme, is *Spherical*, and for the *same* reason (it is a compactness
  condition, and compactness is not first-order).
- For the **dense class**: same, plus density, which is elementary and Sahlqvist (DN). The best
  prospect.
- For **`TM_f` (`ℤ`) and `TM_c` (`{ℤ, ℝ}`)**: **a first-order representation is impossible**, because
  Archimedeanness and Dedekind completeness are not first-order. The section already knows the
  consequence (strong completeness foreclosed, non-compactness witness recorded, Reynolds cited);
  it should state the cause, because the cause also delimits the shift-set target. Any shift-set
  theorem for these classes can only characterise them **up to elementary equivalence**, which is
  precisely not enough.
- **The declared gate should be re-scoped accordingly.** The current remark authorises the
  semantic-compactness programme only once a shift-set representation lands sorry-free in both
  directions for *the* class. As stated, that gate can never open for `TM_f` or `TM_c`. Re-scope it
  per class.

### 5.3 What remains genuinely unsettled

1. Whether the compound term `□(x ∨ Fx ∨ Px)` is a global modality for TM (Def 8.11), and hence
   whether `BAO(TM)` is a discriminator variety. **Checkable; high payoff (Thm 8.10).**
2. Whether *Spherical* holds on `A•` for a TM-algebra once metric operators are added. Plausible
   from Prop 5.83, **not proved here**.
3. Whether the algebraic and shift-set routes are the same theorem twice — the section's own open
   question, and still open. The literature suggests they are *not*: one is a topological duality,
   the other a first-order definability claim, and §3.4 shows they diverge precisely on
   *Spherical*.
4. Whether TM's non-Sahlqvist axioms (CO, Z1, Sep, UC, UG) are canonical by some other route. By
   Thm 6.18 this cannot be settled by appeal to elementarity in either direction, and by Kracht's
   result there is no decision procedure.
5. The historical narrative around Thomason 1972/1975, Goldblatt 1976 and Sambin–Vaccaro 1988 —
   **not sourceable from the current corpus**; only the attributions inside
   `venema_2007_algebras_and_coalgebras` are available.

---

## Part 6 — Delegated Findings

Two sub-agents were dispatched to read the two-dimensional/product literature and the
canonicity/Sahlqvist literature respectively. Their reports are folded into §3.3 and §3.5 above
where they corroborate the primary reading. Where their findings arrived too late to be integrated
in full, the corresponding claims in this report are sourced from documents I read directly
(`blackburn_2002_*`, `venema_2007_algebras_and_coalgebras`, `goldblatt_2003`) and are cited as
such. **No claim in this report rests on a delegated summary alone.**

---

## Risks & Mitigations

| # | Risk | Mitigation |
|---|---|---|
| 1 | **The section over-claims a duality the task-frame semantics does not support.** As written, the diagram promises "Jónsson–Tarski duality" as an endpoint. Jónsson–Tarski is an *embedding theorem*; the duality (Thm 5.28) is with **descriptive general frames**, not with task frames, and the task-frame version is what is blocked. | Rename the endpoint. Distinguish embedding / duality / task-frame representation explicitly, per §5.1. |
| 2 | **The Typst definition block contradicts the Lean module it cites.** It says `#allpast` and `#allfuture` "act as interior operators"; `InteriorOperators.lean:29-43` and the directory README say they do not, and no `G` exists on the quotient. | Fix before anything else. This is a factual error in a `#definition` block with a `#leansrc` pointer next to it. |
| 3 | **"This is not a general frame" is defensible but misleading.** The claim is true of `(W, D, ⇒)`: every `\|pᵢ\| ⊆ W` is admissible. But the operators act on `H_F × D`, and there the admissible propositions are the closure under the operations of `ev⁻¹[P(W)]`, a **proper subalgebra** of `P(H_F × D)`. Relative to the structure the algebra actually dualises, the semantics *is* general-frame-shaped — which is *why* the duality of Thm 5.28 is the right target and the discrete one is not. | Keep the sentence but scope it: "not a general frame *over `W`*", and add the two-dimensional observation. Do not delete it — the point about unrestricted `\|pᵢ\|` is correct and worth making. |
| 4 | **Citing `goldblatt_1989` from the markdown.** Its own header says "USE THIS FILE ONLY AS A ROUGH LOCATOR … Do not quote this text"; roughly half the source characters are lost and section headings corrupt. | Every `goldblatt_1989` claim must be checked against the page images (PDF page = journal page − 172) before it reaches the Typst file. Nothing in this report depends on it. |
| 5 | **Citing Jónsson–Tarski 1951/52 for "the ultrafilter frame".** The originals contain **no occurrence** of "ultrafilter", "filter", "prime ideal" or "maximal ideal" — the construction is a *perfect extension* (Def 1.19, p. 908). The ultrafilter-frame formulation is the modern restatement. | The section's current `η(a) = {U : a ∈ U}` notation attributed to `@jonssontarski1951 @jonssontarski1952` is anachronistic. Attribute the formulation to BdRV §5.3 and the theorem to Jónsson–Tarski. |
| 6 | **New corpus documents carry `unverified_conversion`.** Both newly ingested files had control-character repairs applied post-conversion. | Repairs are documented in each file's header and in the index `conversion_note`. Prose and theorem statements read clean; **display-math layout is linearised** — verify any equation against the sibling PDF before transcribing it into Lean or Typst. |
| 7 | **Acquisition is incomplete.** Sambin–Vaccaro 1988, both S. K. Thomason papers, Goldblatt 1976, Fine 1975 and Gehrke–Jónsson 2004 were not acquired; Semantic Scholar was down for the session. | Re-run `/literature` discovery when Tier 3 recovers. Meanwhile the proxies named in §2.2 cover the mathematical content, though not the historical record. |
| 8 | **The Sahlqvist classification in §3.3 is my own.** It is a reading of Definition 3.51, not a quotation. | Re-derive each row before it enters the Typst file. The DF row in particular (discreteness *is* Sahlqvist, while the `ℤ`-pinning axiom Z1 is not) is the one most worth double-checking, since it is counter-intuitive. |
| 9 | **The discriminator-variety claim in §3.5 is unverified.** | Flagged as unverified throughout. Do not put it in the Typst file until `□(x ∨ Fx ∨ Px)` has been checked against Definition 8.11. |

---

## Appendix: Files Read

**Repository**
- `typst/FormalFoundations.typ` — lines 140–236 (Frames), 380–436 (Models and Truth), 436–600
  (Proof Systems), 1151–1318 (`<sec:representation>`)
- `FormalSystem/Metalogic/Algebraic/README.md` and all five `.lean` files (declaration listings,
  sorry/axiom counts)
- `FormalSystem/Semantics/TaskFrame.lean:340-375` (*Spherical*)
- `FormalSystem/Semantics/Extension/Step.lean:100-135` (the sole *Spherical* application site)
- `FormalSystem/Boneyard/UltrafilterFrame/*.lean` (sorry inventory)

**Corpus** (all read directly, not via summary)
- `blackburn_2002/ch05_jonsson-tarski.md`, `ch05_duality-theory.md`, `ch05_general-frames.md`,
  `ch03_sahlqvist-formulas.md`, `ch03_more-sahlqvist.md`
- `venema_2007_algebras_and_coalgebras.md` §5.4, §6.2, §8.1, §8.2 (newly ingested)
- `goldblatt_1989/chunk_0001.md` (header/fidelity warning and table of contents only)
- global `index.json` metadata for all documents named in §2.2
