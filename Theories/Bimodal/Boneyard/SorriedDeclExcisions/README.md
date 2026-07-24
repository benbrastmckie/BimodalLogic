# SorriedDeclExcisions

Dead-sorry closure excisions: verified-dead declaration closures (each carrying one or
more statement-position sorries) moved out of live `Theories/Bimodal/` code. Every
declaration archived here was confirmed dead by word-boundary grep over `Theories/`
(Boneyard excluded) and `Tests/` — zero external consumers; consumers, where any exist,
fall entirely inside the moved closure.

## Never-Built Policy

Files in this directory are **never compiled**. Each archive file follows this exact
structure, in order:

1. **Imports verbatim** — the union of the source files' import blocks, copied as-is.
   Import lines are historical text, not build edges; stale imports are never repaired.
2. **`ARCHIVED (Boneyard) — never compiled.` docstring** — names every moved
   declaration, the source file(s), and the reason for excision, and ends with
   `Do not import from live code.`
3. **`#exit`** — immediately after the docstring, before the first declaration, so no
   name ever elaborates.
4. **Code verbatim** — the excised declarations exactly as they appeared in live code,
   with per-declaration source-file comments where a file merges multiple sources.

No path in this directory appears in `lakefile.lean`, and no live module imports from
it. The only build invariant is that the default target (`lake build`) stays green
after any change here.

## File Inventory

| File | Decls | Sorries | Source |
|------|------:|--------:|--------|
| `Ghr93ForwardToBackwardChain.lean` | 7 | 7 | `WeakCanonical/Expressiveness/CaseAnalysis.lean`, `WeakCanonical/Expressiveness/Theorem6.lean` |
| `AlgebraicGQuotChain.lean` | 5 | 3 | `Algebraic/LindenbaumQuotient.lean`, `Algebraic/InteriorOperators.lean` |
| `WeakTruthLemmaCluster.lean` | 12 | 6 | `WeakCanonical/TruthLemma.lean` |
| `SingletonSorriedDecls.lean` | 3 | 4 | `WeakCanonical/OrderedSum.lean`, `BXCanonical/Frame.lean`, `BXCanonical/Chronicle/ChronicleToCountermodel.lean` |
| `UntilSinceCoherence.lean` | 6 | 2 | `Bundle/UntilSinceCoherence.lean` (whole file body) |

A sixth closure, `StaviExpressiveCompletenessTail.lean` (24 decls, 3 sorries, from
`WeakCanonical/EFGames/StaviCompleteness.lean`), went to the thematic sibling
directory `../StaviDiscretePath/` rather than here. The closure was enlarged from
its originally-audited 16 declarations to its verified 24-decl fixpoint during
excision: iterating the exclusively-consumed-helper check to a fixpoint pulled in 8
additional pre-tail helpers (`sf_disjList_iff`, `sf_conjList_iff`,
`atomKind_to_sf_literal_correct`, `nf_base_sf`, `zone_match_witness`, `sf_disj_iff`,
`sf_top_iff`, `sf_atom_literal_iff`) whose only consumers sat inside the tail.

## Relationship to Active Code

Adjacent live declarations were deliberately KEPT in place and must not be moved here:
`bot_not_in_mcs` (15 live consumers), `doets_lemma_1_4`, `ghr93_case_I`/`ghr93_case_II`,
`ghr93_inductive_step_discrete` (distinct from the archived `ghr93_inductive_step`),
`H_quot`/`provEquiv_all_past_congr`/`H_monotone` and the live `sigma_quot*` lemmas, and
the compile-live `chronicle_gap_contradiction`/`succ_cofinal`/
`limitDomSubtype_isSuccArchimedean` trio.
