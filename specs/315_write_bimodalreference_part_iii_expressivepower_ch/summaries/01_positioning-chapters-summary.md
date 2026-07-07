# Implementation Summary: Task #315 — The Three Positioning Chapters of BimodalReference Part I

- **Task**: 315 — write_bimodalreference_part_iii_expressivepower_ch
- **Session**: sess_1783410218_f83296_315
- **Date**: 2026-07-07
- **Plan**: plans/01_positioning-chapters-plan.md (all 5 phases COMPLETED)
- **Status**: COMPLETED — both acceptance gates green

## What Was Done

### Phase 1 — Bibliography pass (`Theories/Bimodal/typst/bibliography.bib`)
- `blackburn2000hybrid` fixed: now the `@article` IGPL manifesto (Blackburn, "Representation,
  Reasoning, and Relational Structures: a Hybrid Logic Manifesto", *Logic Journal of the IGPL*
  8(3):339-365, 2000).
- `kamp1971formalproperties` enriched (Theoria 37(3):227-273); its misattributing note replaced
  by a comment routing the expressive-completeness theorem to `kamp1968` + `rabinovich2014`.
- `cresswell1990entities` enriched (Kluwer, Studies in Linguistics and Philosophy vol. 41,
  Dordrecht); `baierkatoen2008` / `gabbay2003manyvalued` verified notes cleared; GKWZ
  series/volume merged (SLFM vol. 148).
- 26 pre-verified entries imported: 13 from Lk.bib (keys wholesale: `kamp1968`,
  `rabinovich2014`, `gpss1980`, `sistlaClarke1985`, `marx1999`, `hmv2004`,
  `hirschHodkinsonKurucz2002`, `arecesBlackburnMarx2001`, `tenCateFranceschet2005`,
  `franceschetEtAl2003`, `demriLazic2009`, `alurHenzinger1994`, `goranko1996`) and 13 from
  possible_worlds.bib (lowercased: `pnueli1977`, `clarke1982`, `emerson1986`, `lamport1980`,
  `vardi2001`, `belnap2001`, `rumberg2016`, `thomason1984`, `clarkson2014`, `finkbeiner2015`,
  `finkbeiner2016`, `finkbeiner2017`, `lind2021`).
- Embargo header comment intact; no Lk entry anywhere.

### Phase 2 — `chapters/p3-vlach-blstar.typ` (~110 lines)
Motivation (tense anaphora, the paper's cross-referencing gap); store/recall definition with the
four indexed families and a notation remark mapping to the paper's T/M-subscripted arrows;
stability operator (set as ⊡/`dot.square`, matching the paper's box-with-dot glyph) with the S5
and trivial-collapse facts; Will/Could definability and open-future/open-past restrictions with
the definability-not-primitive-accessibility payoff; BL⋆ signature; explicit statement that the
paper declines to axiomatize BL⋆ and a logic for it is future work; one-sentence worked-use
pointer to the semantics chapter's Determined/Deterministic remark (not re-exposed); hybrid
prior-art narrative (Kamp-now, Vlach-then, Cresswell, Blackburn manifesto, Goranko) with one
forward reference to the frontier chapter; Kamp's theorem stated via `#theorem` + footnote
citing kamp1968 + rabinovich2014 with BOTH scope conditions (strict operators, Dedekind-complete
flow) and an explicit miscitation warning; GPSS future-only note; honest formalization-frontier
paragraph (Metalogic/WeakCanonical/Kamp/ not sorry-free, "should not be cited as settled").

### Phase 3 — `chapters/p3-ltl-to-tm.typ` (~110 lines)
Mandated thesis framing (Until/Since temporal logic over linear orders fused with S5 + MF over
task frames; the modality quantifies over the constructed history space); traces-vs-task-frames
contrast; four-row operator-convention table (strict/non-strict, derived Next/Previous via
Burgess convention, past operators, anchored vs floating validity); fusion-vs-product
positioning in GKWZ vocabulary (interaction holds by construction, not stipulation);
LTL/CTL/CTL*/HyperLTL triangulation; STIT/Rumberg/Thomason branching neighbors + shifts of
finite type; two-layer conservativity bridge (paper theorem paper-side; Lean side states only
what `lift_derivation_qfree` proves, cross-referencing the frame-classes chapter). Perpetuity
cited by cross-reference only; exactly one forward reference to the frontier chapter.

### Phase 4 — `chapters/p3-decidability-frontier.typ` (~90 lines, embargo-compliant)
Seven-section ceiling-and-descent narrative from published results only: LTL PSPACE floor;
product zone (EXPSPACE-hard territory, S5×S5×S5 ceiling); hybrid-binder ceiling with the
linear-flow descent correctly cited to franceschetEtAl2003; freeze/register and clock results;
HyperLTL block; Goranko pointers; BL⋆ paragraph strictly in prior-art-expectation form ending at
anchor 1; generic complexity-map section ending at anchor 2; generic applications outlook ending
at anchor 3; TM's own position reusing the resolved FMP wording by cross-reference to
@sec:decidability-practice. EMBARGO header and all three SLOT-IN anchor blocks verified
byte-identical against pre-edit copies.

### Phase 5 — Verification and audits
- Backtick audit: 14 unique backticked spans across the three chapters, all on the research
  report's live-verified Lean-name list or real repo paths; BL⋆/LTL/S5/CTL/HyperLTL/STIT never
  backticked; no whitelist additions needed.
- Kamp audit: theorem contexts cite kamp1968 (+rabinovich2014) only; kamp1971formalproperties
  appears only in "now"-operator prior-art contexts.
- Embargo audit: zero prose hits for Lk/L_k/Lₖ/TACAS; the single prose "alternation" is the
  published Finkbeiner-Rabe-Sánchez 2015 model-checking cost, mandated by the plan.
- Consistency: chapter titles/order match the abstract's promise (BimodalReference.typ:139);
  glyph ⋆ throughout (zero ★); no hand-written counts; no status symbols, task numbers, or
  sync-class banners in body text; salvaged content cross-referenced, never duplicated.

## Acceptance Gates (final state, repo root)
- `typst compile Theories/Bimodal/typst/BimodalReference.typ` — exit 0 (only the two tolerated
  thmbox font warnings); page count 72, up from the 59-page baseline.
- `bash scripts/typst-sync-check.sh` — PASS, both checks (Check 1: 0 violations / 464
  candidates; Check 2: 0 mismatches).

## Plan Deviations
- **Label contract**: the vlach chapter heading carries `<ch:vlach-blstar>` instead of the
  plan's `<sec:vlach-blstar>`, per orchestrator course correction (task 317 depends on a
  resolvable `<ch:vlach-blstar>` on that heading). Sibling references use `@ch:vlach-blstar`;
  nothing references `sec:vlach-blstar`, so no dangling labels.
- **Label timing**: `<sec:decidability-frontier>` was added to the frontier placeholder heading
  during Phase 2 (heading line only; embargo blocks untouched) so the vlach chapter's forward
  reference compiled green at the end of that phase.
- **Optional bib keys**: `Kurucz2003` not imported (bibliographically identical to the existing
  `gabbay2003manyvalued`; chapters cite the existing key). Optional `gpss1980` and `lind2021`
  imported and cited.
- **Symbol substitutions**: possibility-stability set as `diamond.stroked.dot` (the plan's
  informal Ⓞ gloss rendered with the paper-faithful box/diamond-with-dot glyphs); `sect`
  replaced by `inter` to clear a typst deprecation warning.

## Artifacts
- `Theories/Bimodal/typst/bibliography.bib`
- `Theories/Bimodal/typst/chapters/p3-ltl-to-tm.typ`
- `Theories/Bimodal/typst/chapters/p3-vlach-blstar.typ`
- `Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ`
- `Theories/Bimodal/typst/BimodalReference.pdf` (72 pages, compiled)

## Observation (out of scope, not changed)
`chapters/04-metalogic.typ:117` cites `@kamp1971formalproperties` in a "Kamp-style
expressiveness modules" context; the plan's Kamp audit covers only the three new chapters, so
this pre-existing citation was left as-is. A follow-up could re-point it at `kamp1968`.
