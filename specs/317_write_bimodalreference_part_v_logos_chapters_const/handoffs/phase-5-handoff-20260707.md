# Phase 5 Handoff — task 317 (sweep, audit, final verification)

- **Cross-reference sweep**: ch:counterfactual <-> ch:constitutive render as "Chapter 15"/"Chapter 16"; @ch:vlach-blstar resolves as "Chapter 10"; thmbox def/thm refs resolve (Definition 16.6, Theorems 16.12/16.14/16.16-16.19); 00-introduction Part III/IV promises and BimodalReference.typ part-divider blurbs both match the written chapters (no edits made or needed).
- **Honesty audit (a)-(g)**: all confirmed (see summary).
- **TM show-rule**: single *TM* hit in new prose, intentional (constitutive shadow section).
- **Notation polish**: all constitutive-notation.typ symbols used (maximalstates via maximalstates_evolutions; impositionsym is the internal helper for imposition(w)); nothing pruned.
- **Final gates**: full compile fails ONLY on 316's missing generated/machine-appendix.typ import; sync-check fails ONLY on 316's missing artifacts (Check 1 backtick path + Check 3). Zero failures attributable to 317 files.
- **Task 315 coordination**: preserve <ch:vlach-blstar> (now referenced from Part III) and store/recall in bimodal-notation.typ.
