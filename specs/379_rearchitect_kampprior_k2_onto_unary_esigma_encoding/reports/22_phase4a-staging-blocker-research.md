# Research Report: Phase-4a Staging Blocker — Root Cause and Solution Path

- **Date**: 2026-07-23
- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Session**: sess_1784829998_2462de
- **Report Type**: research (blocker escalation, Step 2 of orchestrator escalation)
- **Inputs**: `handoffs/phase-4a-blocker-20260723.md`; plan v21 Phase 4a blockquote; Rabinovich PDF pp. 4-6 (read directly); repo inspection at green HEAD (declaration-name anchored)

## 1. Root Cause

Plan v21's Phase 4 stages the per-formula re-encode as an **in-place swap** of the existing
total-assignment representation: the same `UnaryType`/`IntervalType` names, the same
`ExistsForallFormula` fields, re-encoded file by file (4a `IntervalType.lean`, 4b
`LiftPair.lean`, 4c `Prop43Translate.lean`). Both blocker findings are downstream of that single
assumption:

1. `UnaryType sig F := NormalForm (sigE sig F) 0 1` (`ExistsForallFormula.lean`) is a bare,
   `M`-free type consumed in 17 Kamp files (25 uses in `LiftPair.lean` alone) including as
   **stored field types** of `ExistsForallFormula` (`pointType`, `intervalType`). Any in-place
   change to its arity (add an `M` parameter) or semantics (Σ-`M` bundling weakening
   `unaryHolds`) breaks every consumer simultaneously — there is no per-file-green order for an
   in-place swap. This is independent of alphabet finiteness, which is why the flip-last device
   (keep `sigE` finite) does not rescue it.
2. The rendering path `unaryToFormula` (`Prop35ExistsForall.lean`) delegates to
   `nf_depth0_char_formula` (`Separation/KampTranslation.lean`), which folds over
   `Fintype.elems (sig.preds)` — a total-alphabet enumeration that cannot exist at the
   post-flip infinite `sigE`. That file is foundational and outside Phase 4's file list.

**However**, the in-place assumption is not forced. The blocker handoff itself names the
alternative (additive parallel representation, "widen-last" scaled up), and the inspection below
confirms it is realizable with a concrete green-at-every-commit order — and that the
`Separation/` file does **not** need to be touched at all.

## 2. Paper-Faithfulness Verdict on Per-Formula-M Rendering: FAITHFUL

Read directly from the PDF (pp. 4-6):

- **Def 3.1 (p. 4)**: the ∃∀-formula's `αⱼ`, `βⱼ` are "**quantifier free formulas with one
  variable over Σ**". A quantifier-free formula is a finite syntactic object mentioning
  **finitely many** predicate names — the paper never forms a total truth assignment over all of
  Σ, and never enumerates Σ.
- **Prop 3.5 (p. 5)**: the translation to TL(Until, Since) is per-formula: "Let `Aᵢ` and `Bᵢ` be
  temporal formulas equivalent to `αᵢ` and `βᵢ`" — each `Aᵢ` is built from the finite syntax of
  its own `αᵢ`, i.e. from its mentioned atoms only.
- **Def 4.1 (p. 5)**: `E[Σ] = Σ ∪ {A | A is a TL(Until,Since)-formula over Σ}` is an
  **infinite** alphabet. Over it, a total assignment to all predicates is not even a formula-like
  object; the paper's `αⱼ`/`βⱼ` over `E[Σ]` (p. 6, "The ∃∀ and ∨∃∀ formulas are defined as
  previously, but now they can use as atoms TL-definable predicates") remain finite
  quantifier-free formulas.

**Verdict**: the repo's TOTAL `UnaryType` (truth assignment to *all* E[Σ] atoms, rendered by
folding over `Fintype.elems`) is a **repo-local finite-alphabet encoding artifact**, not the
paper's object. The per-formula representation (`UnaryTypeFin sig F M` — assignment to the
mentioned-atom set `M`, `InfAlphabetProbe.lean`) **is** the faithful transcription of Def 3.1's
`αⱼ`/`βⱼ`. Re-encoding the rendering onto per-formula-`M` (a conjunction of literals over `M`)
is exactly Prop 3.5's `Aᵢ` and is therefore faithful transcription, **not** novel mathematics.
The "semantics change" worry in the blocker (weakening `unaryHolds` to mentioned-`M` agreement)
is the paper's own satisfaction notion for a quantifier-free formula; during migration the two
are connected by a finite-alphabet bridge (below), so no correctness statement is weakened — the
old statements are *reproved as consequences*, then retired.

## 3. Consumer Classification (17 Kamp files at green HEAD)

Class (a) — **type + instances + `unaryHolds`/`intervalHolds` lemma layer only** (migrate by
adding Fin-variant lemmas proved via the bridge):
`ExistsForallFormula.lean` (defs + `efSat`), `ExistsForallLemmas.lean`, `IntervalType.lean`
(algebra: `ofComplete`, `intervalConj`, monotonicity — but see (c) for `intervalTop`),
`ConjInterleave.lean`, `EFSatNegationGeneral.lean`, `VeeSatNegation.lean`,
`Prop42ExistsForall.lean`, `ZetaAtomMapReconcile.lean`.

Class (b) — **need rendering at `sigE`** (must switch from the total renderer to a per-formula
renderer): `Prop35ExistsForall.lean` (`unaryToFormula`, `unaryToFormula_correct`),
`Prop35Assembly.lean` (`translateProp35`, `translateProp35_correct`), `Prop35Chain.lean`,
`VVecEA2Collapse.lean`, `ESigmaCapture.lean`.

Class (c) — **alphabet-dependent enumeration** (`Finset.univ` at `UnaryType`; becomes
`M`-relative and *survives the flip*, since `Finset.univ : Finset (UnaryTypeFin … M)` and
`Finset.univ : Finset (Fin (m+1) → UnaryTypeFin … M)` are finite from `M` alone):
`IntervalType.lean` (`intervalTop`), `LiftPair.lean` (`skelR` and the three
`Finset.univ.filter` tuple-skeleton sites), `Prop43Translate.lean` (δ-translate filter).

Scheduled deletion (Phase 5, already planned — do NOT migrate): `ESigmaCapture.lean` capture
sites, `ZetaUniformExtract.lean`. Probes: `InfAlphabetProbe.lean` (the Phase-1 gate — already
per-formula; promote, don't duplicate), `OptionBLocalityProbe.lean` (preserved).

**Decisive negative finding on Finding 2's scope fear**: `nf_depth0_char_formula` has ~40+
consumers outside the ∃∀ chain (`KampPrior.lean` itself, the whole `NfMultiAnchorBridge/` tree,
Boneyard archives) that use it at finite/concrete signatures where `[Fintype sig.preds]`
legitimately holds. It must therefore **stay exactly as it is**. The correct move is
**additive**: a new Kamp-layer per-formula renderer used by the ∃∀ chain at `sigE`;
`Separation/KampTranslation.lean` is never edited. Finding 2's "unscoped foundational file"
dissolves — the scope addition is one NEW file, not a foundational re-encode.

## 4. Recommended Migration Order (additive bridge; green at every commit)

The bridge (finite-alphabet only, deleted at the flip): for `c : UnaryTypeFin sig F M`,
`completions c : Finset (UnaryType sig F) := Finset.univ.filter (fun τ => ∀ a ∈ M, τ a = c a)`
with lemma `intervalHolds N (completions c) y ↔ partialHolds N c y`. It exists precisely while
`sigE` is finite (the flip-last device's real payoff) and is what lets every old total-type
lemma be consumed while the Fin-variants land.

| Step | Content | New/edited files | Green because |
|---|---|---|---|
| 4a-0 | Promote `UnaryTypeFin`/`partialHolds`/`charTypeFin` from `InfAlphabetProbe.lean` to a production file; add `IntervalTypeFin M := Finset (UnaryTypeFin M)`, `intervalHoldsFin`, restriction/weakening maps, the `completions` bridge + bridge lemmas | new `PerFormulaType.lean` | purely additive |
| 4a-1 | Per-formula renderer: `unaryToFormulaFin (c : UnaryTypeFin M) : Formula` folding over `M.toList` (proof mirrors `nf_depth0_char_formula_correct`, bounded to `M`) + `unaryToFormulaFin_correct` ↔ `partialHolds` | new `PerFormulaRender.lean` | purely additive; `Separation/` untouched |
| 4a-2 | **Micro-gate** (extends the Phase-1 gate to the render step, discharging report 20 §3.3's residual 4b risk *before* mass migration): `translateProp35Fin` on a nontrivial `n = 1` input end-to-end through `unaryToFormulaFin_correct` | gate file (probe) | additive probe |
| 4a-3 | Per-formula ∃∀ object: `ExistsForallFormulaFin` bundling `M` + `pointType : Fin (n+1) → UnaryTypeFin M` + `intervalType : Fin (n+2) → IntervalTypeFin M`, `efSatFin`, bridge to `efSat` via `completions` (this IS Def 3.1: ψ is a finite formula, `M` = its mentioned atoms) | `PerFormulaType.lean` or new | additive + bridge |
| 4a-4…N | Migrate class (a)/(b) consumers in import order, one file per commit: `IntervalType` algebra (`intervalTopFin` over `M`) → `ExistsForallLemmas` → `ConjInterleave` → `Prop35ExistsForall`/`Prop35Assembly`/`Prop35Chain` (switch to Fin renderer) → `Prop42ExistsForall` → `EFSatNegationGeneral`/`VeeSatNegation`/`VVecEA2Collapse` → `Prop43Translate` (`M`-relative filter) | existing files, Fin-variants added alongside old | each lemma proved via bridge; old lemmas untouched |
| 4b | `LiftPair.lean` last and alone (25 uses; the plan's fwd/bwd split applies): `skelRFin := Finset.univ : Finset (Fin (m+1) → UnaryTypeFin M)` — finite from `M`, so the skeleton disjunction survives the flip | `LiftPair.lean` | Fin-variants alongside old |
| 4c | Switchover: repoint the `KampPrior` consumer chain (`nf_characterizable_temporal_prior` → `nf_nvar_exist_all_depths` k+2 arm) at the Fin variants; delete the now-unconsumed total-type lemmas at `sigE` + the bridge | Kamp chain files | deletions of unconsumed decls |
| 3-terminal | The small summand flip `{A // A ∈ F}` → `Formula` (per the recorded flip-last decision) + `DecidableEq`-only threading; nothing left at `sigE` needs `Fintype` | `ESigmaExpansion.lean` + instance threading | all remaining `sigE` surface is `M`-relative |
| 5 | Phase 5 as planned (capture-site deletions, stale audit block fix, wrap-up) | as in plan v21 | unchanged |

Each row is bounded to roughly one agent run or less except 4a-4…N, which is one commit per file
with no cross-file coupling (the bridge decouples them).

## 5. Reviser Recommendations

1. **Choose path (A): additive-bridge migration** with the ordered table above. Reject (B)
   in-place re-encode (refuted — no green order exists) and (C) user-stuck (not warranted — the
   evidence determines the path; no user-level trade-off remains).
2. Rewrite plan v21's Phase 4 as sub-phases 4a-0 … 4a-4…N / 4b / 4c per the table (each with its
   own file list and DoD); move the summand flip to a named terminal sub-phase after 4c;
   keep Phase 5 unchanged. Record §2's faithfulness verdict in the plan (per-formula-M **is**
   Def 3.1/Prop 3.5; the total types were the encoding artifact) so the semantics-change concern
   is settled in-document.
3. Explicit non-goals to state: NO edits to `Separation/KampTranslation.lean`
   (`nf_depth0_char_formula` keeps its ~40 finite-signature consumers); NO migration of
   `ESigmaCapture`/`ZetaUniformExtract` (Phase-5 deletions); `OptionBLocalityProbe.lean`
   preserved; quarantine list unchanged.
4. Keep the recorded flip-last decision — it is what makes the `completions` bridge available
   during the whole migration. Its premise failed only for *in-place* 4a, not for the additive
   path.
5. The 4a-2 micro-gate is the cheap early GO/NO-GO this task's history demands (three-strikes
   pattern): it exercises the exact render-correctness obligation that the Phase-1 gate missed,
   on a nontrivial input, before any consumer migration begins.
