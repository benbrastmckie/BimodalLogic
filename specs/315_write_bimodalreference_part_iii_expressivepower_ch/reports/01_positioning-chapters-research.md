# Research Report: The Three Positioning Chapters of BimodalReference Part I

- **Task**: 315 — write_bimodalreference_part_iii_expressivepower_ch (title predates task 319's restructure; the three chapters now close **Part I**, not a "Part III")
- **Session**: sess_1783410218_f83296_315
- **Date**: 2026-07-07
- **Sources examined**: the three placeholder chapters + all 14 sibling chapters + `BimodalReference.typ` + `template.typ` + `bibliography.bib` + `sync-check-whitelist.txt` + `generated/status.typ` (all under `Theories/Bimodal/typst/`); `scripts/typst-sync-check.sh`; task 313 teammate A/B findings; task 319 summary; `possible_worlds.tex` §3.1 (:1007–1073), §3.3 (:1160–1256), §4.2–4.3 (:1412–1560); `Lk/sections/02-syntax-semantics.tex` (:255–300, Kamp scoping only), `Lk/sections/07-related-work.tex` (published-citation survey only), `Lk/Lk.bib`; `possible_worlds.bib`; Lean source under `Theories/Bimodal/Metalogic/` (WeakCanonical/Kamp, ConservativeExtension, Decidability); live web verification of four citations.

---

## 1. What Exists Now (the three placeholders)

All three files sit at the end of Part I in `BimodalReference.typ:194–196`, after `05-theorems.typ`:

| File | Current state | Hard constraints |
|---|---|---|
| `chapters/p3-ltl-to-tm.typ` | 11 lines: heading + one-sentence placeholder citing `@demrigorankolange2016 @baierkatoen2008` | NEVER describe TM as "vanilla LTL + S5" (that framing is extension-roadmap only) |
| `chapters/p3-vlach-blstar.typ` | 11 lines: heading "Vlach Operators and the BL#super[⋆] Tower" + placeholder citing `@vlach1973nowandthen @cresswell1990entities @blackburn2000hybrid @kamp1971formalproperties` | verify citations before print; Kamp theorem correctly scoped; honest Lean frontier status in plain prose |
| `chapters/p3-decidability-frontier.typ` | 37 lines: EMBARGO header comment (lines 8–12), heading, one-sentence placeholder, three `// SLOT-IN:` anchors (`ladder-table` :22, `complexity-map` :27, `case-study` :33) with reservation comments | EMBARGO header + all three SLOT-IN anchor blocks preserved **verbatim**; NO Lk-specific results, NO Lk citation anywhere (task 318 will populate post-acceptance) |

Task 319 established the register: **plain textbook prose, no sync-class banners, no status symbols (✓/⧖/○/◇), no task numbers in body text**. The dropped `p3-open-future.typ` chapter's salvage already landed: the Determined/Deterministic + actuality-operators remark is the closing `#remark` of `02-semantics.typ:166–169` — the new chapters must **point to it, not duplicate it**.

## 2. Verification Gates (exact, current)

1. `typst compile Theories/Bimodal/typst/BimodalReference.typ` — must exit 0 (two pre-existing thmbox font warnings are tolerated; baseline is 59 pages).
2. `bash scripts/typst-sync-check.sh` — **note a stale reference in the task description**: it says "checks 1+4", but task 319 deleted checks 2–3 and renumbered; the script now runs exactly two checks:
   - **Check 1 (name resolution)**: every backticked span in `typst/**/*.typ` must resolve as (a) a whitelist entry, (b) a path under `Theories/Bimodal/` or repo root (line-suffix `:123` stripped; Boneyard excluded unless named), or (c) a bare identifier found by literal grep in `*.lean` under `Theories/Bimodal/` excluding `Boneyard/`. Multi-word spans must literal-grep-match Lean source or be whitelisted.
   - **Check 2 (count freshness)**: `generated/status.typ` matches live regeneration — the new chapters simply must not hand-write counts; import from `generated/status.typ` if counts are needed (they should not be).

**Backtick discipline** (the single biggest failure mode): use backticks ONLY for real Lean identifiers/paths. `BL⋆`, `LTL`, `S5`, `HyperLTL`, operator glyphs, and paper-side theorem labels must be set in italics/math/plain text, NOT backticks (or added to `sync-check-whitelist.txt`, which should be a last resort). Verified-resolving names available for these chapters (all checked live this session, Boneyard excluded):

- `untl`, `snce`, `next`, `prev`, `next_unfold`, `prev_unfold` (Until/Since basis, derived Next/Previous)
- `Metalogic/WeakCanonical/Kamp/` (path), `kamp_prior_expressive_completeness`, `US_expressively_complete_over_prior`, `rabinovich_translate`, `MonadicFormula`, `KampTranslation`
- `decide_sound`, `fmp_completeness`, `lift_derivation_qfree`, `time_shift`
- NOT resolving: `PriorStructure` (write "Prior structures" in prose, no backticks). Whitelist already carries `possible_worlds.tex`, `app:discrete`/`app:dense`/`app:complete`, `thm:BLplus-NextPrevious`.

## 3. Chapter 1 — `p3-ltl-to-tm.typ`: "From LTL to TM: Honest Positioning"

### Thesis (mandated framing)
TM is **Until/Since temporal logic over linear orders** (durations form a totally ordered abelian group, strict/irreflexive semantics) **fused with an S5 metaphysical modality plus one interaction axiom (MF) and uniformity axioms, interpreted over task frames** where possible worlds are constructed as task-constrained functions from convex duration sets to world states. It is *not* "vanilla LTL + S5": the modality quantifies over the constructed history space $H_F$ (validating perpetuity via time-shift invariance), not over a second primitive Kripke dimension.

### Content inventory with sources (teammate A row 10 + row 8 + local chapters)

1. **Trace vs task semantics** (the core contrast). LTL: ω-sequences over atomic propositions, distinguished initial point, non-strict Until with primitive Next (`@baierkatoen2008`, `@demrigorankolange2016`). TM: histories τ : X → W with convex domains over an arbitrary ordered abelian group; bi-infinite or partial; no initial point; validity over all frames/histories/times. Source: `02-semantics.typ` (already in the book — cross-reference, don't restate) + `possible_worlds.tex:1412–1440` (NDS/LTS: a task frame IS a labeled transition system with duration labels carrying group structure; Baier–Katoen footnote at :1494).
2. **Operator-convention deltas**, presented as a table or short list: strict vs non-strict Until/Since (book's `06-notes.typ` §Design Choices is the in-book anchor; the temporal T-axioms invalid, seriality axiomatic via BX1/BX1′); Next/Previous derived (`next`/`prev` = `φ U ⊥`/`φ S ⊥`, Burgess convention, `next_unfold`/`prev_unfold` — see `p2-frame-classes.typ` §Next and Previous, cross-reference); past operators present (LTL is future-only; GPSS future-only adequacy belongs to chapter 2's Kamp discussion, not here); anchored (initial-time) vs floating validity.
3. **Fusion vs product positioning** (Gabbay–Kurucz–Wolter–Zakharyaschev vocabulary, teammate B F3.1). TM is *neither* the fusion (no interaction) *nor* literally the product PTL × S5: the interaction principles (MF, and derived TF) hold because possible worlds are *constructed* with time-shift invariance, where in the general product landscape such principles must be imposed. Paper source: `possible_worlds.tex:1519–1526` ("Whereas TM validates its bimodal interaction principle by the construction of possible worlds itself, this fails in the broader landscape of products of modal logics", Kurucz products footnote). Cite `gabbay2003manyvalued` (already in bib; recommend renaming note only, key stays) and add a Kurucz-2003 handbook-chapter entry if desired (`possible_worlds.bib:558` has `Kurucz2003`).
4. **LTL/CTL/CTL\*/HyperLTL triangulation** (`possible_worlds.tex:1519–1533` — the paper's own published positioning; this is quotable/paraphrasable and fully outside the Lk embargo): individual worlds are linear as in LTL; the set of worlds through a world state branches as in CTL; □ is unrestricted rather than state-relativized path quantification (A/E); HyperLTL binds trace variables in the object language and its satisfiability is undecidable, whereas TM's □ binds nothing. Bib entries to import from `possible_worlds.bib`: `Pnueli1977`, `Clarke1982`, `Emerson1986`, `Lamport1980`, `Vardi2001`, `Clarkson2014`, `Finkbeiner2015/2016/2017` (the HyperLTL block also serves chapter 3 — add once).
5. **Branching-time neighbors** (brief): STIT (Belnap–Perloff–Xu) and Rumberg's transition semantics posit a branching partial order outright; the task relation *unfolds into* a tree from a total duration order (`possible_worlds.tex:1495–1501`; `Belnap2001`, `Rumberg2016`, `Thomason1970/1984` in `possible_worlds.bib`). Optional: shifts of finite type as the finite-discrete instance (:1502–1507, `Lind2021`).
6. **Conservativity as the bridge**. Two-layer story, stated honestly:
   - *Paper side*: TM (H/G basis) extends to TM⁺ (Until/Since basis) conservatively (`thm:ConservativeExtension`), and the book's Lean system works in the Until/Since basis throughout — so the LTL-style operator vocabulary is the *native* one, and the H/G tense logic is recovered inside it. This is the bridge that lets the chapter compare TM with LTL operator-by-operator without changing systems mid-argument. Source: `possible_worlds.tex:1240–1244` + `06-notes.typ` §Language Basis.
   - *Lean side, stated honestly* (per the `p2-frame-classes.typ` §A Fresh-Atom Conservative-Extension Technique and `06-notes.typ` discrepancy correction): **no Lean module formalizes the paper's L-vs-L⁺ conservativity**; `Metalogic/ConservativeExtension/` proves the different fresh-atom lifting lemma `lift_derivation_qfree`. The chapter must cross-reference the frame-classes chapter's precise statement rather than re-litigating or overclaiming.

### Anti-goals
- No "TM = LTL + S5" phrasing anywhere, including section titles.
- No decidability/complexity ladder here (that is chapter 3's job); at most one forward reference.
- Do not re-prove or restate perpetuity (chapter 05-theorems owns it); cite P1/P2 by cross-reference to `02-semantics.typ` §Time-Shift.

## 4. Chapter 2 — `p3-vlach-blstar.typ`: "Vlach Operators and the BL⋆ Tower"

### Content inventory with sources (teammate A row 8 + row 6; teammate B F3.3)

1. **Motivation**: TM⁺ "lack[s] the means by which to cross reference either times or worlds" (`possible_worlds.tex:1246`). Natural-language driver: tense anaphora ("Once, everyone now alive hadn't yet been born") — Kamp's "now", Vlach's "then".
2. **The operators, exactly as in the paper** (:1246–1256): evaluation points gain a vector v of stored times and a vector μ of stored worlds; four indexed families — time-store ↑ⁱ (writes evaluation time into vᵢ), time-recall ↓ⁱ (shifts evaluation time to vᵢ), world-store ⇑ⁱ (writes evaluation world into μᵢ), world-recall ⇓ⁱ (shifts evaluation world to μᵢ). These generalize Vlach's single now/then pair to indexed families *and* add the world-theoretic counterparts. The semantics of BL is otherwise unchanged.
3. **BL⋆ defined** (:1255): BL⋆ = ⟨SL, ⊥, →, □, S, U, Ⓞ, ↑ⁱ, ↓ⁱ, ⇑ⁱ, ⇓ⁱ⟩ — note it **includes the stability operator Ⓞ** from §3.1 (:1007–1030). The chapter therefore needs a short subsection presenting Ⓞ (quantifies over worlds intersecting τ at x; monomodal S5; collapses to trivial on non-temporal formulas) and may mention the definable Will/Could operators and open-future/open-past restrictions |τ⟩ₓ/⟨τ|ₓ in one paragraph, since the definability-not-primitive-accessibility argument (:1052–1060) is the philosophical payoff of construction. The paper explicitly declines to axiomatize BL⋆ ("outside the scope of the present paper", :1256) — the book should say the same; a logic for BL⋆ is future work.
4. **Worked-use pointer, not exposition**: the paper's only worked use of Vlach operators is the open-future analysis ((Sea)/(Det), §4.1). Per task 319's decision the puzzle chapter is dropped; this chapter should give **one sentence** noting that application with `@brastmckie2026possibleworlds` and a cross-reference to the Determined/Deterministic remark in the semantics chapter (`02-semantics.typ:166–169`). Do not reintroduce the sea-battle exposition.
5. **Hybrid-logic prior-art framing** (the chapter's scholarly spine):
   - Kamp 1971 introduced "now" as a rigid temporal reference point (@kamp1971formalproperties — this is that paper's correct role);
   - Vlach 1973 added "then", the storage/recall pattern (@vlach1973nowandthen);
   - Cresswell 1990 argued the general case requires unboundedly many stored indices — storage operators approach full explicit quantification over times (@cresswell1990entities);
   - hybrid logic's ↓-binder and @-operator systematize this (@blackburn2000hybrid — see citation corrections below); Goranko's reference pointers are the direct temporal-logic ancestor (recommend ADDING `goranko1996`, verified entry available in `Lk/Lk.bib:260`: Goranko, "Hierarchies of Modal and Temporal Logics with Reference Pointers", JoLLI 5(1):1–24, 1996).
   - Framing sentence (teammate B F3.3): the Vlach families are hybrid-style binders over the time and world coordinates with an indexed register vector; the known cost profile of ↓ (undecidability in general, tamer bounded fragments) is what makes the frontier chapter's ceiling-and-descent narrative expected — one forward reference to chapter 3, no results stated here.
6. **Kamp's theorem, correctly scoped** (mirrors `Lk 02-syntax-semantics.tex:272–293`, which is *scoping prose about published results* — the theorem and its scope conditions are published prior art, safe to state; do NOT cite Lk itself):
   - Statement: Until and Since (in their **strict** readings) are expressively complete for the first-order theory of linear order over **Dedekind-complete** flows of time — Kamp 1968 (dissertation), modern proof Rabinovich 2014.
   - Both scope conditions must be stated: strict operators (which TM uses natively — the book's `06-notes.typ` strict-semantics section is the cross-reference) and Dedekind completeness of the flow.
   - Optional completing note: over discrete future-only ℕ-like flows the past-free fragment already suffices (Gabbay–Pnueli–Shelah–Stavi 1980) — this is why LTL can be future-only; TM keeps the past operators because its flows are general.
7. **Formalization frontier, honest plain prose** (matching `04-metalogic.typ:113–117` register): work toward a Kamp-style expressive-completeness theorem is in progress in `Metalogic/WeakCanonical/Kamp/` — the Rabinovich 2014 proof chain (Lemma 5.1 → Prop 4.2 → Prop 4.3 → Theorem 4.4) targeting `kamp_prior_expressive_completeness` (every `MonadicFormula` with one free variable has a U/S-equivalent formula on Prior structures), with the Proposition 3.5 translation implemented as `rabinovich_translate`. State that the modules are **not sorry-free** (`generated/status.typ`: WeakCanonical/ subtree carries 24 of the repository's 41 non-Boneyard sorries) and that these results "should not be cited as settled" — the exact phrase family `04-metalogic.typ` already uses. No sorry-count tables, no status symbols; one or two plain sentences. The safe formulation: soundness of the translation infrastructure exists in parts; the end-to-end theorem is the frontier.

### Citation verification results (task-mandated; verified live this session)

| Key | Verdict | Correct data |
|---|---|---|
| `vlach1973nowandthen` | OK as `@phdthesis` | Vlach, F., *"Now" and "Then": A Formal Study in the Logic of Tense Anaphora*, PhD dissertation, UCLA, 1973. (Matches how `possible_worlds.bib:676` cites it.) Clear the "verify before print" note. |
| `cresswell1990entities` | OK; enrich | Cresswell, M. J., *Entities and Indices*, Studies in Linguistics and Philosophy vol. 41, Kluwer Academic Publishers, Dordrecht, 1990 (xi+274 pp.). Verified via JSL review/SpringerLink. Add series+volume, clear note. |
| `blackburn2000hybrid` | **WRONG as it stands** | Current entry is `@book{title={Hybrid Languages and Temporal Logic}, year=2000}` — that conflates two works. Either (recommended) fix to the manifesto: Blackburn, P., "Representation, Reasoning, and Relational Structures: a Hybrid Logic Manifesto", *Logic Journal of the IGPL* 8(3):339–365, 2000 (`@article`, verified via OUP academic.oup.com/jigpal/article-abstract/8/3/339/808433); or switch to Blackburn & Tzakova, "Hybrid Languages and Temporal Logic", *LJIGPL* 7(1):27–54, 1999 (then the key/year must change). Keep the key `blackburn2000hybrid`, fix the fields to the manifesto. |
| `kamp1971formalproperties` | **Note misattributes the theorem** | The 1971 Theoria paper is "Formal properties of 'now'", *Theoria* 37(3):227–273, 1971 (verified via Wiley/PhilPapers) — it introduces the *now* operator and is the right cite for the prior-art narrative. **Kamp's expressive-completeness theorem is from the 1968 UCLA dissertation** (*Tense Logic and the Theory of Linear Order*). Fix the entry's fields (volume 37, number 3, pages 227–273) and its note; ADD `kamp1968` (`@phdthesis`, UCLA, 1968 — verified entry in `Lk/Lk.bib:9`) and ADD `rabinovich2014` (Rabinovich, "A Proof of Kamp's Theorem", *LMCS* 10(1), 2014 — `Lk/Lk.bib:16`). Cite the theorem as `@kamp1968` (+ `@rabinovich2014`), cite "now" as `@kamp1971formalproperties`. |

## 5. Chapter 3 — `p3-decidability-frontier.typ`: "The Decidability Frontier"

### Embargo compliance (user decision 2, task 313)
- Preserve the header comment block (lines 8–12 of the current file) and all three `// SLOT-IN:` anchor blocks **verbatim**, in place. The task-318 numbers live only in comments (task 319 already adjudicated this as acceptable: the compiled PDF carries no task numbers).
- FORBIDDEN in prose: any BL⋆-ladder table lifted from Lk, any L_k/Lₖ complexity theorem or attribution, alternation-freedom results, the hardware/constant-time case study, any citation of the Lk submission, and any wording that reveals unpublished theorem content ("undecidable for k ≥ 2", "PSPACE-complete diamond-free fragment" etc. as *claims about the tower*). The general lesson may be *motivated* from published results only.
- Recommended placement: write the prose sections so each SLOT-IN anchor sits at the natural insertion point of its future content (ladder narrative → anchor 1; complexity narrative → anchor 2; applications outlook → anchor 3), with the surrounding prose complete and self-standing without them.

### Published-only ceiling-and-descent narrative (all bib data verified — the Lk.bib entries below were themselves /cite-verified in that paper's Phase 14 and can be copied wholesale)

**Floor** — LTL satisfiability is PSPACE-complete: Sistla & Clarke, *JACM* 32(3):733–749, 1985 (`sistlaClarke1985`, `Lk/Lk.bib:33`).

**Adding an S5 dimension (products)** — the bimodal product PTL × S5 (and commutator-style combinations) is decidable but EXPSPACE-hard/complete territory; general treatment in Gabbay–Kurucz–Wolter–Zakharyaschev 2003 (`gabbay2003manyvalued`, already in bib — clear its note; the Lk copy `gkwz2003` adds series/volume data worth merging), complexity of products in Marx, *JLC* 9(2):197–214, 1999 (`marx1999`), complete axiomatizations for knowledge-and-time in Halpern–van der Meyden–Vardi, *SICOMP* 33(3):674–703, 2004 (`hmv2004`). Ceiling *within* products: three-dimensional S5×S5×S5-like products are undecidable/non-finitely-axiomatizable — Hirsch–Hodkinson–Kurucz, *JSL* 67(1):221–234, 2002 (`hirschHodkinsonKurucz2002`). This positions "one modal dimension over linear time" as the safe zone.

**Adding cross-referencing (the hybrid/freeze/trace-quantifier ceiling)** —
- hybrid binder ↓: satisfiability undecidable over arbitrary frames — Areces–Blackburn–Marx, *JSL* 66(3):977–1010, 2001 (`arecesBlackburnMarx2001`); ten Cate–Franceschet, CSL 2005, LNCS 3634:339–354 (`tenCateFranceschet2005`).
- **Descent on linear flows**: over linear structures, hybrid logics with binders become decidable, though non-elementary — Franceschet–de Rijke–Schlingloff, TIME-ICTL 2003:166–173 (`franceschetEtAl2003`). CAUTION carried over from the Lk bib header: this paper, NOT tenCateFranceschet2005, is the source of the linear-order decidable bound — do not swap them.
- freeze quantifiers/registers: one register future-only decidable (non-primitive-recursive); two registers or past → undecidable — Demri–Lazić, *TOCL* 10(3), 2009 (`demriLazic2009`); metric/clock discipline as the tamer alternative — Alur–Henzinger, "A Really Temporal Logic", *JACM* 41(1):181–204, 1994 (`alurHenzinger1994`).
- trace quantification: HyperLTL satisfiability undecidable (Finkbeiner–Hahn 2016), model checking decidable with quantifier-alternation-exponential cost (Finkbeiner–Rabe–Sánchez 2015), first-order embedding (Finkbeiner–Zimmermann 2017), origin Clarkson et al. 2014 — entries in `possible_worlds.bib:1165–1230` (`Clarkson2014`, `Finkbeiner2015`, `Finkbeiner2016`, `Finkbeiner2017`).
- reference pointers: expressiveness hierarchies — Goranko 1996 (`goranko1996`).

**Where BL⋆ sits (general statement only)**: BL⋆'s indexed store/recall over *both* times and worlds gives it hybrid-binder-like power in two coordinates simultaneously; by the published pattern above, one must expect undecidability at the top of the tower and decidable fragments only under register bounds, anchoring disciplines, or quantifier restrictions. This states an *expectation from prior art*, attributes nothing, and leaves the actual tower results to the SLOT-INs.

**TM's own position (in-repo honesty)**: TM itself is claimed decidable via the finite model property in the paper (`@brastmckie2026possibleworlds`, cor:tm-decidability); in this repository the tableau procedure's soundness is proven (`decide_sound`) and the finite-filtration FMP statement is sorry-free (`fmp_completeness`) with the semantic-validity bridge open — the chapter MUST reuse the resolved wording of `p2-decidability-practice.typ` (§FMP Status Resolution) via cross-reference (`@sec:decidability-practice`) rather than paraphrasing freshly (divergent paraphrases were exactly what task 313 Phase 8 cleaned up).

### Shape recommendation
~90–130 lines: (i) the question — what expressive extensions cost; (ii) floor and product zone; (iii) the cross-referencing ceiling with the linear-flow descent; (iv) BL⋆ expectation paragraph + anchor 1; (v) what a complexity map for the tower would need to chart + anchor 2; (vi) applications outlook (verification-flavored, generic; `@baierkatoen2008`) + anchor 3; (vii) TM's own status paragraph.

## 6. Bibliography Work Plan (single edit pass in `bibliography.bib`)

- **Fix**: `blackburn2000hybrid` → `@article`, manifesto fields (LJIGPL 8(3):339–365, 2000); `kamp1971formalproperties` → add volume 37, number 3, pages 227–273, rewrite note ("Kamp's *now* operator; NOT the source of the expressive-completeness theorem — see kamp1968"); enrich `cresswell1990entities` (Kluwer, SLP 41); clear now-verified "verify before print" notes (baierkatoen2008 and gabbay2003manyvalued data are correct as stated; add GKWZ series/volume from `Lk/Lk.bib:179`).
- **Add** (copy from `Lk/Lk.bib`, already print-verified there): `kamp1968`, `rabinovich2014`, `gpss1980` (optional), `sistlaClarke1985`, `marx1999`, `hmv2004`, `hirschHodkinsonKurucz2002`, `arecesBlackburnMarx2001`, `tenCateFranceschet2005`, `franceschetEtAl2003`, `demriLazic2009`, `alurHenzinger1994`, `goranko1996`.
- **Add** (copy from `possible_worlds.bib`): `Pnueli1977`, `Clarke1982`, `Emerson1986`, `Lamport1980` (or `lamport1983`), `Vardi2001`, `Belnap2001`, `Rumberg2016`, `Thomason1984`, `Kurucz2003` (optional), `Clarkson2014`, `Finkbeiner2015`, `Finkbeiner2016`, `Finkbeiner2017` (normalize key casing to the book's existing all-lowercase convention when copying).
- The embargo header comment at the top of `bibliography.bib` (NO Lk entry) must remain.
- The book uses `style: "ieee"` numeric citations; unused entries do not render, so adding the full set is harmless, but keys must be actually cited or pruned per the implementer's taste.

## 7. Style Contract for All Three Chapters

- `#import "../template.typ": *` then `= Chapter Title` (level-1 heading = Chapter, auto-supplement).
- Optional `#chapter-header(description: [...], dependencies: [...])` — used by `p2-frame-classes.typ` and `p2-decidability-practice.typ`; recommended for consistency.
- Available environments: `definition`, `theorem`, `lemma`, `axiom`, `remark`, `proof`, `proposition`, `corollary`, `example`, `notation-env`; `#leansrc(module, name)` for Lean anchors; footnotes carry Lean file:line references.
- Cross-reference labels available: `@sec:decidability-practice`, `@sec:conservative-extension`, `@sec:design-choices`, `@sec:notes`, `@sec:formulas`, `@sec:truth`. New chapters should add their own `<sec:...>` labels (suggest `<sec:ltl-to-tm>`, `<sec:vlach-blstar>`, `<sec:decidability-frontier>`).
- Paper-side theorems stated with `#theorem(...)` + citation footnote, never with fabricated Lean anchors (pattern: `p2-frame-classes.typ` §Paper Correspondence).
- Sizes of comparable finished chapters: 83–356 lines. Sensible targets: ltl-to-tm ~140–190, vlach-blstar ~150–200, decidability-frontier ~90–130.

## 8. Risks and Traps

1. **Backticked non-Lean tokens** — the #1 predictable sync-check failure; audit every backtick before running the script.
2. **Kamp misattribution** — citing the theorem to the 1971 paper (as the current placeholder and bib note do) would be a scholarly error the task explicitly asks to catch; fix per §4.
3. **Embargo leakage by paraphrase** — stating "the tower is undecidable from level 2" even uncited is an Lk-specific result; only the *prior-art expectation* form is safe.
4. **Duplicating salvaged content** — Determined/Deterministic remark (02-semantics) and the FMP-resolution wording (p2-decidability-practice) must be cross-referenced, not restated.
5. **Conservativity overclaim** — do not attribute the paper's L-vs-L⁺ theorem to `Metalogic/ConservativeExtension/`; the book already corrected this once (06-notes discrepancy correction).
6. **Stale task-description references** — "checks 1+4" is now "checks 1+2"; "Part III/Expressive-Power" in the task slug is now "end of Part I"; `possible_worlds.tex 1246-1256` confirmed accurate for the Vlach clauses.
7. **Vlach glyph consistency** — the heading uses `BL#super[⋆]` (star operator ⋆, not ★); keep that glyph throughout (task 319 deviation note).
8. **The abstract already promises this content** (`BimodalReference.typ:139`: "closes by positioning TM among richer temporal-modal logics (Vlach store/recall operators, the BL⋆ tower, the decidability frontier)") — chapter titles/order must keep matching it.

## 9. Recommended Implementation Order

1. Bibliography pass (fixes + additions) — unblocks all citations.
2. `p3-vlach-blstar.typ` (most self-contained; citation-sensitive).
3. `p3-ltl-to-tm.typ` (leans on ch. 2's Kamp scoping via forward/backward refs).
4. `p3-decidability-frontier.typ` (embargo-audited last, when the other two's cross-references exist).
5. Verify: `typst compile` + `bash scripts/typst-sync-check.sh`; whitelist additions only if a genuinely non-Lean backtick is unavoidable.

## Confidence

- **High**: file states, verification-gate mechanics, style conventions, Lean name resolution (all checked live); paper line citations (read directly); the four Vlach-chapter citations (web-verified); Lk-derived published bib data (pre-verified in Lk Phase 14 and spot-consistent).
- **Medium**: recommended chapter lengths/outlines (design judgment); whether to include gpss1980/shifts-of-finite-type material (optional enrichment).
- **No open blockers**: all sources exist and are readable; no missing prerequisite.
