# Phase 4 Handoff: p3-decidability-frontier.typ

- **Task**: 315
- **Phase**: 4 (Write p3-decidability-frontier.typ) — COMPLETED
- **Session**: sess_1783410218_f83296_315

## Done
- Full chapter (~90 lines) in the seven-section shape: (i) the question; (ii) floor
  (sistlaClarke1985) and product zone (gabbay2003manyvalued, marx1999, hmv2004) with the
  hirschHodkinsonKurucz2002 three-dimensional ceiling; (iii) cross-referencing ceiling
  (arecesBlackburnMarx2001, tenCateFranceschet2005) with the linear descent correctly cited to
  franceschetEtAl2003, freeze/registers (demriLazic2009), clocks (alurHenzinger1994), trace
  quantification (finkbeiner2016/2015/2017, clarkson2014), reference pointers (goranko1996);
  (iv) BL⋆ prior-art-expectation paragraph ending at anchor 1; (v) generic complexity-map
  section ending at anchor 2; (vi) generic applications outlook (baierkatoen2008) ending at
  anchor 3; (vii) TM's own position reusing the resolved wording by cross-reference to
  @sec:decidability-practice.
- EMBARGO header and all three SLOT-IN anchor blocks verified byte-identical (diff against
  pre-edit copies in scratchpad).

## Embargo audit notes
- Prose grep for Lk/L_k/Lₖ/TACAS: zero hits outside preserved comments.
- One prose occurrence of "alternation": the published Finkbeiner-Rabe-Sánchez 2015
  quantifier-alternation-exponential model-checking cost for HyperLTL, explicitly required by
  the plan's section (iii) inventory — NOT an alternation-freedom claim about the tower.
- No tower results stated or attributed; BL⋆ paragraph is in expectation-from-prior-art form.

## Verification
- `typst compile` exit 0.
- Backticks: `decide_sound`, `fmp_completeness` only (verified list).
