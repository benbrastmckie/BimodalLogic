# Research Report: Task #867

**Task**: 867 - Formalize Gabbay separation over ZTime for `PlusFormula`
**Started**: 2026-11-05T20:54:23Z
**Completed**: 2026-11-05T21:42:00Z
**Effort**: sizeable — 9 phases proposed; two of them (reconstructed eliminations, junction-depth induction) carry genuine stall risk
**Dependencies**: None blocking. Consumes only already-compiled declarations.
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`, `FormalSystem/PlusLanguage/{Formula,PlusTruth,PlusValidity,PlusIntTransfer,PlusReversal,PlusPasting,Subformulas,Substitution}.lean`, `FormalSystem/Semantics/FrameProperty.lean`, `FormalSystem/Metalogic/Expressiveness/{README.md,Separation/README.md,Kamp/README.md}`, `Boneyard/Kamp/KampWeakCanonical/Separation/**`, `docs/theorem-index.md`, `scripts/check-module-invariants.sh`
- Literature: Gabbay, Hodkinson and Reynolds 1994, *Temporal Logic: Mathematical Foundations and Computational Aspects* vol. 1, Chapter 10 §10.2 — read from `/home/benjamin/Projects/Literature/sources/gabbay_1994/ch1001_chapter-10-expressive-completeness-of-si.md` and cross-checked against `.../Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.pdf`
- Mathlib: `Mathlib/Data/Int/LeastGreatest.lean`
- lean-lsp MCP: `lean_local_search` (index state `warming`, see Evidence Tier below)
- Consumer report: `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md` §5
**Artifacts**:
- `specs/867_formalize_gabbay_separation_ztime/reports/01_gabbay-separation-ztime-plusformula.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The target statement is a syntactic validity, and it reduces to the single carrier ℤ.** `SeparationOver TaskFrame.IsZTime`'s equivalence clause is exactly `PlusValidZTime (φ ↔ sepForm L)`, and `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` (live, compiled, `FormalSystem/PlusLanguage/PlusIntTransfer.lean:188`) collapses that to validity over `FrameOver intOrder` with `t : ℤ`. The whole GHR §10.2 development can therefore be done over concrete integers, with `omega` and `Int.exists_least_of_bdd` available, instead of over an abstract successor-Archimedean ordered abelian group. This is the single largest de-risking available.
- **The recommended architecture is an auxiliary U/S syntax over abstract leaf predicates `ℤ → Prop`, not direct work on `PlusFormula`.** This is not a convenience: a direct `PlusFormula` route runs into a real obstruction (GHR's proof substitutes formulas for atoms, and *uniform substitution does not visibly preserve `PlusValidZTime`*, because `PlusFormula.atom` is evaluated at `M.valuation (τ.state t)` — a function of the world state alone — while an arbitrary substituend is history- and time-dependent). An abstract-leaf syntax makes every abstraction/substitution step a reindexing of the leaf valuation, with no substitution lemma needed at all. See **Decision D1**.
- **The box/stab dimension costs almost nothing.** `□φ` is history-independent (`PlusTruthAt`'s `box` clause quantifies over *all* world histories at the same `t`) and `⊡φ` depends only on `τ.state t`; both are leaf constructors of `IsPureFuture` *and* `IsPurePast` (`FormalSystem/PlusLanguage/Formula.lean:309-325`), and `pastDet_of_isPurePast` / `futDet_of_isPureFuture` are already compiled. So a **syntactic** separation into `IsPurePast ∨ IsPureFuture` clauses suffices at ZTime, and the semantic `PastDet`/`FutDet` that `SepClauses` asks for comes free from the existing bridges.
- **A ~10,300-line archived GHR §10.2 transcription exists** at `Boneyard/Kamp/KampWeakCanonical/Separation/` with Cases 1-4 worked and a full `junction_depth` / `all_formulas_separable` skeleton. It never compiled (`#exit`, outside the build closure) and its `replace_box_with_top` step is **unsound for `PlusFormula`**, but it is a usable architectural blueprint and it records a refutation worth re-checking.
- **GHR's printed Case 5 formula is refuted over integer time.** I verified a counterexample against the chapter-10 PDF text, not only the markdown chunk: with `a(0)`, `A(1)`, `B` identically false, `q(1)=q(2)`, the left side holds at `t=3` while both printed disjuncts require `A ∨ (B ∧ U(A,B))` at `t=3`, which fails. The printed conjunct also contradicts GHR's own gloss ("the second [disjunct holds] when [A] is true in the past"). A gloss-consistent reading that drops that conjunct from the second disjunct survives the counterexample on that model. **Cases 5-8 must be reconstructed and independently verified, not transcribed.**
- **Discharging `SeparationOver` does not by itself make the translation executable.** `tr` is `noncomputable` because it reads its separated form off `Classical.choose`, and its signature must not change. Executability is a *second, additive* deliverable: a computable `sepZ : PlusFormula → List (PlusFormula × PlusFormula)` plus a new computable `trZ`, which plugs into the already-generic `decidableOpenValidInOfTranslation` / `openDecider` / `openDecider_correct` with no signature change anywhere.
- **The first consumer's requirement is met exactly as stated.** `specs/865_.../reports/01_...md` §5 step (c) needs `SeparationOver TaskFrame.IsZTime` verbatim; the syntactic route delivers something strictly stronger than its "⊡/□ leaves are constant on the cluster" premise needs.

## Context & Scope

**Researched**: how to discharge `SeparationOver TaskFrame.IsZTime` for `PlusFormula`, formalizing GHR Lemmas 10.2.1-10.2.8 / Theorem 10.2.9, and what "making the open-future translation executable" additionally requires.

**Constraints taken as given** (from the dispatch):
- The consuming elimination layer in `OpenFutureElimination.lean` is landed and compiled; no signature there may be weakened, and nothing there is restated.
- `FormalSystem/Metalogic/Independence/` is out of scope; the metalogic-cycles allowlist is not to be altered.
- Gates: zero `sorry`, zero vacuous definitions, no new axiom; guarded scoped build then unscoped; `check-module-invariants.sh` and `check-metalogic-cycles.sh` green against pre-task baselines; every axiom profile measured.
- A precisely located obstruction is a legitimate `[COMPLETED WITH EXCLUSIONS]` outcome.

**Evidence tier.** `lean_local_search` reported `index: "warming"`, so no empty LSP result in this session is proof of absence. Every absence claim below (notably: no `PlusFormula`-level atom-substitution-with-truth-congruence; no separation development targeting `PlusFormula`) rests on `grep` sweeps over `FormalSystem/`, which read source text directly and are sound for absence. Positive existence claims were confirmed by reading the declaring file.

## Literature Proof Structure

**Source**: Gabbay, Hodkinson and Reynolds, *Temporal Logic: Mathematical Foundations and Computational Aspects*, vol. 1 (1994), Chapter 10, §10.2 "Separation for S, U over Integer Time", Lemmas 10.2.1-10.2.8 and Theorem 10.2.9 (printed pp. 368-372; chunk `ch1001_chapter-10-expressive-completeness-of-si.md`).

**Strategy**: syntactic rewriting. Repeatedly pull `U` out of the scope of `S` (and dually) until no `U` lies under an `S` and no `S` under a `U`; such a formula is *syntactically separated*, and GHR note that syntactic separation implies separation, since a `U`-only formula is pure future, an `S`-only formula is pure past, and atoms are pure present.

**Notation warning, load-bearing.** GHR write `U(A, B)` with **`A` the event and `B` the guard**: `U(A,B)` at `s` means `∃u > s, A(u) ∧ ∀r ∈ (s,u), B(r)`. This is confirmed by GHR's own semantic gloss on Case 1. The repository's `PlusFormula.untl` takes **guard first, event second** (`FormalSystem/PlusLanguage/Formula.lean:100-103`, and the `untl` clause at `PlusTruth.lean:89`). So **GHR's `U(A,B)` is the repository's `untl B A`**. Every transcription must flip.

### Step Map

1. **Lemma 10.2.1** — four Boolean distributivities, *valid over linear time*: `U(A ∨ B, C) ↔ U(A,C) ∨ U(B,C)`; `S(A ∨ B, C) ↔ S(A,C) ∨ S(B,C)`; `U(A, B ∧ C) ↔ U(A,B) ∧ U(A,C)`; `S(A, B ∧ C) ↔ S(A,B) ∧ S(A,C)`. Proof: "Simple." — [Source] Lemma 10.2.1.
2. **Lemma 10.2.2** — four negation equivalences, *over integer time*: `¬U(A,B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A)`, its `S`/`H` mirror, and two variants with `B ∧ ¬A` in the guard slot. Proof: "Simple." — [Source] Lemma 10.2.2.
3. **Lemma 10.2.3** — the **eight eliminations**, for `a, q, A, B` atoms, each pulling `U(A,B)` out from under an `S`: (1) `S(a ∧ U(A,B), q)`; (2) `S(a ∧ ¬U(A,B), q)`; (3) `S(a, q ∨ U(A,B))`; (4) `S(a, q ∨ ¬U(A,B))`; (5) `S(a ∧ U(A,B), q ∨ U(A,B))`; (6) `S(a ∧ ¬U(A,B), q ∨ U(A,B))`; (7) `S(a ∧ U(A,B), q ∨ ¬U(A,B))`; (8) `S(a ∧ ¬U(A,B), q ∨ ¬U(A,B))`. GHR give explicit separated right-hand sides for (1)-(5) and partial ones for (6)-(8), prefaced by "We will only present some of the details." — [Source] Lemma 10.2.3.
4. **Lemma 10.2.4** — single-`U`-type, depth-one packaging: for `U`/`S`-free `A, B`, if every `U` in `C` and `F` is `U(A,B)` and unnested under `S`, then `S(C,F)` has a syntactically separated equivalent in which `U` appears only as `U(A,B)`. Proof route: DNF `C`, CNF `F`, Lemma 10.2.1, then Lemma 10.2.3 clause-by-clause. — [Source] Lemma 10.2.4.
5. **Lemma 10.2.5** — induction on the maximum number `k` of nested `S`s above any `U(A,B)`; step applies 10.2.4 to each most deeply nested `S(C,F)`. — [Source] Lemma 10.2.5.
6. **Lemma 10.2.6** — induction on the number `n` of distinct maximal `U`-subformulas. Step: abstract `U(A_i,B_i)` to fresh atoms `q_i` for `i < n`, separate for `U(A_n,B_n)` by 10.2.5, substitute back, re-separate the resulting impure pure-past parts by the induction hypothesis. — [Source] Lemma 10.2.6.
7. **Lemma 10.2.7** — induction on the maximum nesting depth of `U`s beneath an `S`, for formulas with no `S` nested within a `U`. Step: abstract inner `U(X_ij,Y_ij)` to fresh atoms `z_ij`, separate by 10.2.6, substitute back, re-separate. — [Source] Lemma 10.2.7.
8. **Lemma 10.2.8** — induction on **junction depth** (the maximal length of a chain of nested `U`/`S` subformulas *alternating* between `U` and `S`). Junction depth `≤ 1` is already separated; the step abstracts each maximal `S(E,F)` inside a maximal `U(A_i,B_i)` to a fresh atom, separates by 10.2.7, resubstitutes, and claims the result has junction depth one less. — [Source] Lemma 10.2.8.
9. **Theorem 10.2.9** — Separation Theorem over the integer flow; immediate from 10.2.8. — [Source] Theorem 10.2.9.

### Dependencies

- 10.2.2 depends on discreteness (least-element arguments on rays). 10.2.1 needs only linearity.
- 10.2.3 depends on 10.2.1 and 10.2.2, and internally cases (3), (6), (7), (8) are reduced to cases (2), (4), (5).
- 10.2.4 depends on 10.2.1 and 10.2.3. 10.2.5 on 10.2.4. 10.2.6 on 10.2.5. 10.2.7 on 10.2.6. 10.2.8 on 10.2.7. 10.2.9 on 10.2.8.
- 10.2.5 through 10.2.8 each depend on a **fresh-atom abstraction and resubstitution** step, and on the claim that the chosen measure strictly decreases.
- All of §10.2 has a **dual** in which `U` and `S` exchange roles; GHR state this once and use it throughout.

### Potential Formalization Challenges

- **Cases 5-8 of 10.2.3 are not reliably transcribable.** The printed Case 5 formula is refuted over ℤ (see Findings → External Resources). Cases 6-8 are given only as reductions with gaps ("Eliminations (3) and (5) can be used to finish the separating"; "Notice the last disjunct in `¬D` is redundant" — unjustified).
- **"Appearances" are occurrence-level.** GHR's measures ("the most deeply nested `S(C,F)` in which `U(A,B)` appears", "junction depth of *an appearance*") are indexed by occurrences, which a Lean inductive formula type does not address. Every measure must be restated as a structural recursion on the syntax tree, and the strict-decrease claims — asserted without proof in 10.2.6-10.2.8 — must be proved.
- **Fresh-atom abstraction and resubstitution is the step a direct `PlusFormula` encoding cannot pay for.** See Decision D1.
- **GHR's `G`/`H` must be the repository's `allFuture`/`allPast`** (`Formula.lean:146,149`), both built from `untl`/`snce` on `top`, hence already syntactically pure in the right direction.
- **`sepForm` demands a specific binary-clause CNF.** GHR stop at "a Boolean combination of pure past, pure present and pure future"; `sepForm` (`OpenFutureElimination.lean:285`) is `⋀ᵢ (αᵢ ∨ βᵢ)` as a `List (PlusFormula × PlusFormula)`. Converting a separated Boolean combination into that shape is a step with no counterpart in the source, and it is where `bot` padding (`bot` is both `IsPurePast` and `IsPureFuture`) is used for single-sided clauses.

## Findings

### Codebase Patterns

**The consuming layer, and exactly what it asks for.** `SeparationOver` (`OpenFutureElimination.lean:349`):

```lean
def SeparationOver (P : TaskFrame → Prop) : Prop :=
  ∀ φ : PlusFormula, ∃ L : List (PlusFormula × PlusFormula),
    ∀ (F : TaskFrame), F.IsRegular → P F → SepClauses F L ∧
      ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
        PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t (sepForm L)
```

Three facts about this shape matter:

1. **`∃ L` precedes `∀ F`** — one separated form must serve every frame in the class. That is what a *syntactic* separation theorem delivers, and it is what rules out any frame-dependent construction.
2. The `SepClauses F L` conjunct asks only for the semantic `PastDet F c.1 ∧ FutDet F c.2`, which the compiled `pastDet_of_isPurePast` / `futDet_of_isPureFuture` supply from syntactic purity — frame-independently.
3. The equivalence conjunct is, after unfolding `FrameClass.Sat .ZTime F = F.IsRegular ∧ F.IsZTime`, precisely `PlusValidZTime (φ.iff (sepForm L))`.

**Carrier normalization is already proved.** `plusValidZTime_iff_plusValidInt : PlusValidZTime φ ↔ PlusValidInt φ` (`PlusIntTransfer.lean:188`), where `PlusValidInt φ = ∀ (F : FrameOver intOrder) [F.IsRegular] (M) (τ) (t : ℤ), PlusTruthAt M τ t φ`. Combined with fact (3) this means the entire elimination layer can be proved with `t : ℤ`. `Int.exists_least_of_bdd` (`Mathlib/Data/Int/LeastGreatest.lean:69`) is then directly available for the "least `u > t` with `A(u)`" arguments that 10.2.2 and 10.2.3 turn on — which over an abstract `IsZTime` carrier would have to be rebuilt from `IsSuccArchimedean`.

**`IsZTime` is strong but awkward.** `TaskFrame.IsZTime F = ∃ (_ : SuccOrder F.Duration) (_ : PredOrder F.Duration), IsSuccArchimedean F.Duration ∧ IsPredArchimedean F.Duration` (`FrameProperty.lean:192`). Its own docstring records that it has, and can have, no named accessors, and that consumers must `obtain` the witnesses and pass them positionally with `@` — never `haveI`. Routing through `plusValidZTime_iff_plusValidInt` avoids touching this entirely.

**Purity predicates make box/stab free.** `IsPureFuture` and `IsPurePast` (`Formula.lean:309,318`) both take `box φ` and `stab φ` as leaf constructors for *any* `φ`, with the recorded reason that `□ψ` is history-independent and `⊡ψ` depends on the present world state alone. The truth clauses bear this out: `box φ` is `∀ σ, PlusTruthAt M σ t φ` (no dependence on `τ` at all) and `stab φ` is `∀ σ, τ.state t = σ.state t → PlusTruthAt M σ t φ`. `AgreeUpTo`/`AgreeFrom` (`PlusPasting.lean:243,247`) are both **inclusive of `t`** (`∀ s, s ≤ t → …` / `∀ s, t ≤ s → …`), so atoms — evaluated at `τ.state t` — are simultaneously past- and future-determined, as are `box` and `stab`.

**Duality is available and halves the work.** `PlusFormula.reflectTime` with `IsPureFuture.reflectTime : IsPurePast φ.reflectTime` and its converse (`Formula.lean:326,338`), plus `plusValidIn_reflectTime_iff` (`PlusReversal.lean:202`). Every `S`-side case therefore mirrors a `U`-side case for free, exactly as GHR's "all the results in the rest of this section have dual results" promises.

**Derived connectives are all present**: `top`, `neg`, `and`, `or`, `imp`, `iff`, `someFuture` (`⊤ U ·`), `somePast`, `allFuture` (`G`), `allPast` (`H`), `next` (`⊥ U ·`), `prev` (`⊥ S ·`), `dstab` (`Formula.lean:134-193`). `next`/`prev` are the discrete-step connectives the ℤ arguments will want; `BoxStabFree` (`Subformulas.lean:291`) names the box/stab-free fragment the leaf abstraction targets.

**What is missing and must be built.** `grep` over `FormalSystem/` finds no `PlusFormula → PlusFormula` atom substitution and no truth-congruence lemma for one. `Substitution.lean`'s `substPlus : (Atom → PlusFormula) → Formula → PlusFormula` is a *language* translation (L into L⁺) used for derivability transfer, not an endo-substitution with a truth lemma. Decision D1 removes the need for one.

**The archived GHR §10.2 transcription.** `Boneyard/Kamp/KampWeakCanonical/Separation/` holds 10,292 lines across 16 files, for `Formula` over a concrete `IntStructure`:

| File | Lines | What it carries |
|---|---:|---|
| `Eliminations.lean` | 919 | GHR 10.2.3 Cases 1-4 with explicit separated forms (`case1_psi`, `case2_psi`, `elim_case_1..4` plus `_gen` variants); Boolean separability combinators; `since_event_split`; `since_guard_weaken` |
| `Distributivity.lean` | 207 | 10.2.1 |
| `NegationEquiv.lean` | 178 | 10.2.2 (`neg_until_equiv`) |
| `Duality.lean` / `DualEliminations.lean` | 361 / 120 | `swap_temporal` duality |
| `NormalForm.lean` | 573 | DNF/CNF and `is_syntactically_separated` |
| `Hierarchy/HierarchyDefs.lean` | 1070 | `junction_depth`, `junction_depth_U`, `junction_depth_S`, and the monotonicity bounds `jd_imp_le_left/right`, `jd_box_le`, `jd_untl_le_left/right`, `jd_snce_le_left/right` |
| `Hierarchy/HierarchyInduction.lean` | 1455 | `count_U_total` machinery |
| `Hierarchy/HierarchyCompletion.lean` | 1000 | 10.2.5/10.2.6/10.2.7 in oracle-parameterized *and* oracle-free forms, `all_formulas_separable_aux`, `all_formulas_separable` |
| `Hierarchy/HierarchyCaseSep.lean`, `DedekindZ/*` | 2939 | case split and Dedekind-ℤ material |

Status and usability, stated precisely: every file begins with an `ARCHIVED — BIT-ROTTED DEAD CODE` banner and `HierarchyCompletion.lean` carries an `#exit` directly after its docstring, so **nothing past that point is even parsed**. The banners themselves warn that `grep -c sorry == 0` on these files is meaningless. The two `sorry` hits per file are inside those banners.

Two concrete judgements about reuse:

- **The blueprint is valuable.** The measure vocabulary (`junction_depth` and its bounds, `count_U_subformulas`, `abstract_untl`, `abstract_subst_roundtrip`, `subst_formula_congr`, `extract_U_type`, `fresh_atom`), and the shape of `all_formulas_separable_aux` (strong recursion on junction depth, with a structural induction inside each level and a dual step for the `untl` case via `swap_temporal_involution`), are exactly the scaffolding GHR leaves implicit. Reading it saves rediscovering the decomposition.
- **One of its steps is unsound here.** `all_formulas_separable_aux` normalizes with `replace_box_with_top` and `replace_box_equiv : int_equiv ψ (replace_box_with_top ψ)` — replacing `□χ` by `⊤`. That is only available because `IntStructure` has no modal dimension. For `PlusFormula` over a task frame, `□χ` is not equivalent to `⊤` and `⊡χ` is not either. The replacement for that step is **leaf abstraction**, which is also what `OpenFutureElimination.lean`'s own docstring prescribes ("applied to the `U`/`S` formula obtained by reading each maximal `□ψ` and each maximal `⊡ψ` subformula, and each atom, as a propositional leaf").

**The first consumer.** `specs/865_.../reports/01_...md` §5 step (c) assumes `SeparationOver TaskFrame.IsZTime` verbatim and says "Separation is the gate on the doubled architecture, and this is the first consumer of [867] that is not an expressiveness result." Its step 1 needs the `⊡`/`□`-leaf values to be constant on the cluster; syntactic purity gives that a fortiori. **No change to the hypothesis shape is needed for that consumer.**

**Gates and baselines.** `scripts/check-module-invariants.sh` carries a C14 axiom baseline with pinned profiles for `ofutP_or_iff`, `openValidIn_ztime_iff_tr` and siblings, all `[propext, Classical.choice, Quot.sound]` with `#print axioms` invocations at lines ~2684-2689. New declarations must be added there with **measured** profiles. `docs/theorem-index.md` lines 649, 670, 672-673 carry the conditional rows and the prose note that the `tr` rows are "conditional specifically on `SeparationOver`"; lines 672 (`ZTime`) is the row that becomes unconditional, 673 (`RTime`) does **not** — that is Theorem 10.3.20, out of scope.

### External Resources

**GHR §10.2 is in the corpus in full, despite the briefing.** The literature briefing advertises only §10.3.1 and §10.3.2 for chapter 10. The actual chunk `ch1001_chapter-10-expressive-completeness-of-si.md` (15,055 bytes) contains §10.1 and **the whole of §10.2**, Lemmas 10.2.1 through 10.2.8, Theorems 10.2.9 and 10.2.10, verbatim. The chapter-10 PDF is also on disk. No step map had to be reconstructed.

**GHR's printed Case 5 formula is refuted over integer time.** GHR state that `S(a ∧ U(A,B), q ∨ U(A,B))` is equivalent, over integer time, to

```
  S(a,B) ∧ [A ∨ (B ∧ U(A,B))]
∨ S(A ∧ S(a,B), A ∨ B ∨ ¬S(¬q,¬A)) ∧ [A ∨ (B ∧ U(A,B))] ∧ ¬S(¬q,¬A)
```

and gloss it: "The first disjunct holds when the `A` from `U(A,B)` is true in the future or present and the second when it is true in the past."

Counterexample over ℤ. Put `a(0)` true, `A(1)` true, `B` false everywhere, `q(1)` and `q(2)` true, everything else false; evaluate at `t = 3`.
- Left side: take `s = 0`. `a(0)` holds. `U(A,B)(0)` holds with witness `u = 1`, since `A(1)` and the open interval `(0,1) ∩ ℤ = ∅` makes the `B`-guard vacuous. The `S`-guard `q ∨ U(A,B)` must hold on `(0,3) ∩ ℤ = {1,2}`, and `q(1)`, `q(2)` do. So the left side is **true** at 3.
- Right side: **both** printed disjuncts conjoin `[A ∨ (B ∧ U(A,B))]`, evaluated at `t = 3`. `A(3)` is false and `B(3)` is false, so that conjunct fails and the right side is **false** at 3.

I confirmed the bracketing against the PDF text rather than relying on the markdown chunk: the extracted layout puts `∧ [A ∨ (B ∧ U(A,B))] ∧ ¬S(¬q,¬A)` as a continuation line of the second disjunct, matching the chunk. So the defect is in the source as printed, not in the chunking.

Two readings, and the honest position between them. (i) The conjunct is a typesetting artifact belonging only to the first disjunct — which is what GHR's own gloss implies, since a second disjunct covering "`A` true in the past" cannot also demand `A` now or later. On that reading the second disjunct is `S(A ∧ S(a,B), A ∨ B ∨ ¬S(¬q,¬A)) ∧ ¬S(¬q,¬A)`, and I checked by hand that it is **true** on the model above, so the reconstruction survives this counterexample. (ii) The formula is simply wrong. Either way the operative conclusion is the same: **Cases 5-8 must be reconstructed from the semantics and independently verified; transcribing the printed formulas will produce a false lemma.**

**The archive's own account of this is partly right and must not be adopted wholesale.** `Boneyard/.../Eliminations.lean:781-810` records a section headed "GHR94 Error on Integer Time" with substantially the same counterexample (same model, same `t`), attributes it to a dense-time assumption that "the `U`-chain propagates `B`-coverage to `t`", declares the explicit Case 5 formula "an open problem", and routes Cases 5-8 through `all_formulas_separable` instead. Three cautions. First, that note does not consider the gloss-consistent bracketing, which survives its counterexample — so "open problem" is overstated on the evidence it gives. Second, its *second* claimed counterexample, that `¬S(¬q,¬A)` is "trivially satisfiable via vacuous `¬A` on empty intervals `(t-1,t)`", is garbled: the vacuous-guard phenomenon on ℤ makes `S(¬q,¬A)(t)` *easy to satisfy* (take `s = t-1`, whose open interval is empty, so it reduces to `¬q(t-1)`), hence makes `¬S(¬q,¬A)` *hard* to satisfy, not trivial. The underlying observation — that `S`/`U` guards on ℤ degenerate on adjacent points and GHR's §10.2 formulas read as written with dense-time intuitions — is real and worth carrying forward; the stated form of it is not. Third, it cites "GHR94 (p.370)" where the chunk's own header cites pp. 572-580; the chapter-10 PDF pagination shows 369-370 for Lemma 10.2.3, so the archive's page is right and the chunk header's is not.

**Resolving Cases 5-8 through the junction-depth induction is circular unless checked.** The archive's resolution is to prove Cases 5-8 as corollaries of `all_formulas_separable`. GHR's Lemma 10.2.4 — the first consumer of 10.2.3 — explicitly invokes "the preceding lemma" for each Boolean constituent of the form `S(C₁ ∧ ±U(A,B), C₂ ∨ ±U(A,B))`, which is exactly Cases 5-8. So in GHR's own dependency order, 10.2.4 → 10.2.5 → … → 10.2.9 *rests on* Cases 5-8, and deriving them back from 10.2.9 closes a loop. The archive's `HierarchyCompletion.lean` does carry `_no_oracle` variants that claim to break the loop, but the file is unparsed past `#exit`, so **this is unverified and must be established independently**. Treat it as a live risk, not a solved problem.

**Mathlib.** `Int.exists_least_of_bdd` and `Int.exists_greatest_of_bdd` (`Mathlib/Data/Int/LeastGreatest.lean`) are the classical least/greatest-element lemmas for bounded integer predicates, with a decidable computable variant alongside. These are the workhorses for every "least `u > t` such that …" step.

**Second target, for the record.** GHR §10.3 (Theorem 10.3.20, the Dedekind-complete separation) is in the corpus as chunks `ch1002` (§10.3.1 introduction), `ch1005` (§10.3.2 pre-eliminations), `ch1003` (§10.3.3 eliminations), `ch1004` (§10.3.4 induction). The dispatch correctly scopes it out of this task; the `RTime` row stays conditional.

### Recommendations

A sorry-free path exists. It is sizeable, and the two risk points are named explicitly below.

**R1 — Build the development on an auxiliary U/S syntax over abstract leaf predicates, not on `PlusFormula`.** Introduce something along these lines (names illustrative; the implementation plan should fix them):

```lean
inductive USForm (n : ℕ) : Type
  | leaf : Fin n → USForm n
  | bot  : USForm n
  | imp  : USForm n → USForm n → USForm n
  | untl : USForm n → USForm n → USForm n   -- guard, event: repo order
  | snce : USForm n → USForm n → USForm n

def usTruth (v : Fin n → ℤ → Prop) : ℤ → USForm n → Prop
```

Prove GHR 10.2.1-10.2.9 here, universally quantified over the leaf valuation `v : Fin n → ℤ → Prop`. Three consequences, each of which removes a specific obstruction:
- **No substitution lemma is needed anywhere.** GHR's fresh-atom abstraction and resubstitution steps (10.2.5-10.2.8) become reindexing of `v` and renumbering of `Fin n` — nothing is substituted into a formula at all.
- **No frames, models, world histories, or regularity appear in the hard part.** The entire development is combinatorics over `ℤ` and `ℤ → Prop`.
- **The separation function is a pure function on `USForm`**, hence computable by construction — which is what R6 needs.

**R2 — Interface to `PlusFormula` exactly once, at the leaf abstraction.** Define the leaf list of `φ` as its atoms together with its maximal `box`/`stab` subformulas, `abstract : (φ : PlusFormula) → Σ n, USForm n × (Fin n → PlusFormula)`, and `toPlus : USForm n → (Fin n → PlusFormula) → PlusFormula`. Then prove exactly two interface lemmas:
- *truth*: `usTruth (fun i t => PlusTruthAt M τ t (leaf i)) t ψ ↔ PlusTruthAt M τ t (toPlus ψ leaf)` — one induction on `USForm`, and a roundtrip `toPlus (abstract φ).2.1 (abstract φ).2.2 = φ`;
- *purity*: if `ψ : USForm n` uses only `snce` (resp. only `untl`) outside leaves, and every `leaf i` is an atom or `box`/`stab`-headed, then `IsPurePast (toPlus ψ leaf)` (resp. `IsPureFuture`). This is immediate from `IsPurePast`'s `box`/`stab`/`atom` leaf constructors.

**R3 — Reach ℤ via `plusValidZTime_iff_plusValidInt`, and prove the eliminations with arbitrary formula arguments.** State each elimination at a fixed model and history with `t : ℤ` and with its parameters arbitrary `USForm`s (or, pre-abstraction, arbitrary leaf predicates), never as "let `a,q,A,B` be atoms, then substitute". GHR's atomicity hypothesis exists only to license their uniform-substitution step and is not used in any of their semantic arguments.

**R4 — Use `reflectTime` duality to halve Lemma 10.2.3 and the induction's `untl`/`snce` cases.** `plusValidIn_reflectTime_iff` plus `IsPureFuture.reflectTime`/`IsPurePast.reflectTime` are compiled; a `USForm`-level `swap` with an involution lemma is cheap and reproduces the archive's `swap_temporal` step soundly.

**R5 — Reconstruct Cases 5-8 of 10.2.3 from the semantics, and probe them before committing.** For each case, derive the separated right-hand side by the case split GHR indicates (position of the `A`-witness relative to `t`; position of the first `¬B` after `s`), then *before* attempting a proof, test the candidate equivalence on small concrete ℤ models — including the adjacent-point degeneracies (`(t, t+1) ∩ ℤ = ∅`) that refuted the printed Case 5. The gloss-consistent Case 5 reconstruction in External Resources above is the suggested starting candidate, having already survived one counterexample.

**R6 — Treat executability as a separate, additive deliverable.** `tr` (`OpenFutureElimination.lean:359`) is `noncomputable` by construction and its signature is frozen. Add, alongside it:
- `sepZ : PlusFormula → List (PlusFormula × PlusFormula)` — computable, from the `USForm` separation function of R1 composed with the leaf abstraction of R2 and the CNF packaging of R7;
- `separationOver_ztime : SeparationOver TaskFrame.IsZTime := fun φ => ⟨sepZ φ, …⟩`;
- `trZ : OpenFormula → PlusFormula` — computable, defined like `tr` but with `ofutElim (sepZ (trZ φ))` / `opastElim (sepZ (trZ φ))` in place of the `Classical.choose` clauses, with its own `openTruthAt_iff_trZ` and `openValidIn_ztime_iff_trZ`.

`trZ` then inhabits the translation slot of `decidableOpenValidInOfTranslation`, `openDecider`, `openDecider_correct`, `openComplete_of_plusComplete_in` and `openValid_of_plusSound` — all five are already generic in `T` and need no change. Do **not** attempt a uniform `noncomputable` `Decidable (OpenValidIn FrameClass.ZTime φ)`: the module docstring records that shape as deliberately rejected, and `lean4.md` classes it as a vacuity violation.

**R7 — Pay the CNF-packaging step explicitly; it is not in the source.** A separated `USForm` is a Boolean combination of leaf, `untl`-only and `snce`-only parts. `sepForm` needs `⋀ᵢ (αᵢ ∨ βᵢ)` with `αᵢ` pure-past and `βᵢ` pure-future. Route: classify each literal as past-admissible, future-admissible, or both (leaves are both); CNF-normalize the Boolean skeleton; per clause, put the past and leaf literals in `αᵢ` and the future literals in `βᵢ`, padding an absent side with `bot` (which is both `IsPurePast.bot` and `IsPureFuture.bot`). Plan this as its own phase with its own truth-preservation lemma.

**R8 — Proposed phase decomposition** (the implementation plan should refine, not reproduce, this):

| Phase | Content | Risk |
|---|---|---|
| 1 | `USForm`, `usTruth`, `swap` + involution; leaf abstraction, `toPlus`, roundtrip, truth and purity interface lemmas; the `SeparationOver`-clause ↔ `PlusValidInt` bridge | low |
| 2 | GHR 10.2.1 (linear-time distributivities) and 10.2.2 (ℤ negation equivalences, via `Int.exists_least_of_bdd`) | low–moderate |
| 3 | GHR 10.2.3 Cases 1-4 | moderate |
| 4 | GHR 10.2.3 Cases 5-8, reconstructed and probed per R5 | **high — primary stall candidate** |
| 5 | GHR 10.2.4 (DNF/CNF + single-`U`-type packaging) and 10.2.5 (`S`-nesting induction) | moderate |
| 6 | GHR 10.2.6 (`U`-type-count induction) and 10.2.7 (`U`-nesting induction) | moderate–high |
| 7 | Junction depth as a structural measure, its strict-decrease lemmas, GHR 10.2.8 and Theorem 10.2.9 | **high — secondary stall candidate** |
| 8 | CNF packaging into `sepForm` clauses (R7); `separationOver_ztime` discharged | moderate |
| 9 | Computable `sepZ`/`trZ` (R6); unconditional `ZTime` corollaries; `docs/theorem-index.md` row restatements; measured C14 axiom baselines; `check-module-invariants.sh` and `check-metalogic-cycles.sh` green; guarded scoped then unscoped build | low |

**R9 — No sorry deferral, and what to do instead.** If Phase 4 or Phase 7 stalls, the sanctioned outcome is `[BLOCKED]` on that phase with the obstruction precisely located — which elimination or which strict-decrease claim resists formalization, the goal state reached, and what would unblock it — and `[COMPLETED WITH EXCLUSIONS]` for the task, as the dispatch's own gates permit. Every earlier phase's results stand on their own (the eliminations are independently useful validities over ℤ) and should be landed, committed and pinned regardless.

**R10 — Honest cost comparison, as the dispatch asks.** The dispatch asks that this be weighed against the MSO/Rabin decidability route before committing. That weighing is unchanged by this research with one correction: the value of this task is *not* confined to expressiveness bookkeeping. The 865 report establishes `SeparationOver TaskFrame.IsZTime` as the gate on the doubled-automaton L⁺ ZTime completeness architecture — a consumer the MSO/Rabin route does not serve. The expressiveness payoff (one unconditional row, plus a computable `trZ`) is the narrower of the two, as the dispatch warns; the completeness-architecture payoff is not.

## Decisions

- **D1. Build on an auxiliary U/S syntax over abstract leaf predicates `ℤ → Prop`, not directly on `PlusFormula`.** Rationale: GHR's proof substitutes formulas for atoms in four of its eight lemmas, and uniform substitution does *not* visibly preserve `PlusValidZTime`. `PlusFormula.atom p` is evaluated at `M.valuation (τ.state t) p`, a function of the world state alone, whereas a substituend is history- and time-dependent; the usual "modify the valuation" proof of substitution-closure is therefore unavailable, and no substitution lemma of the needed strength exists in the tree. Abstracting leaves to arbitrary `ℤ → Prop` predicates makes the obstruction disappear rather than paying for it, and makes the separation function computable as a bonus. This is the single most consequential design decision in this report.
- **D2. Target syntactic purity (`IsPurePast`/`IsPureFuture`) rather than the semantic `PastDet`/`FutDet`.** The compiled bridges convert for free; the syntactic predicates are decidable and compositional; and `box`/`stab` being leaves of both means the leaf abstraction loses nothing. The module docstring's reason for stating the predicates semantically — that the *Dedekind-complete* separated forms are future-determined without being syntactically pure — applies to `RTime`, not to the ZTime route taken here.
- **D3. Reduce to the carrier ℤ via `plusValidZTime_iff_plusValidInt` rather than reasoning over an abstract `IsZTime` carrier.** `IsZTime`'s existential-over-`SuccOrder`/`PredOrder` form has no accessors by design and its docstring forbids `haveI`-style instance introduction; concrete ℤ gives `omega`, `Int.exists_least_of_bdd` and ordinary induction instead.
- **D4. State the eliminations with arbitrary parameters, not atoms-plus-substitution.** GHR's atomicity hypothesis in 10.2.3 is an artifact of their substitution step and is unused in their semantic arguments.
- **D5. Reconstruct Cases 5-8; do not transcribe them.** The printed Case 5 formula is refuted over ℤ by a verified counterexample, and Cases 6-8 are published with acknowledged gaps.
- **D6. Treat discharging `SeparationOver` and making the translation executable as two deliverables, both additive.** No existing signature changes; `tr` stays `noncomputable` and keeps its name; a new computable `trZ` is added beside it.
- **D7. Mine the archived development as a blueprint, never as code.** Its measure vocabulary and induction shape are worth reading; its `replace_box_with_top` normalization is unsound for `PlusFormula`; nothing in it has ever been typechecked.
- **D8. Keep `RTime` conditional.** GHR Theorem 10.3.20 is out of scope per the dispatch; only `docs/theorem-index.md`'s `ZTime` row becomes unconditional.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| **Cases 5-8 of GHR 10.2.3 resist reconstruction.** The printed formulas are refuted or gapped; the right-hand sides are large and the ℤ adjacency degeneracies are easy to get wrong. | High — primary stall candidate | Probe every candidate equivalence on small concrete ℤ models *before* proving it (R5). Start from the gloss-consistent Case 5 reconstruction, which already survives the known counterexample. If a case resists, that case is the precisely-located obstruction the dispatch accepts as `[COMPLETED WITH EXCLUSIONS]`. |
| **Circularity between Cases 5-8 and the junction-depth induction.** GHR's 10.2.4 consumes Cases 5-8; the archive resolves Cases 5-8 *from* the final theorem. | High | Fix the dependency order before Phase 4 begins and keep Cases 5-8 strictly upstream of 10.2.4. Do not import the archive's `_no_oracle` claim as settled — it sits behind an `#exit` and has never been checked. |
| **Junction-depth strict decrease is asserted, not proved, in the source.** GHR's 10.2.6-10.2.8 each claim a measure drops under abstract-separate-resubstitute without proof. | High — secondary stall candidate | Define the measure as a structural recursion on `USForm` and prove the decrease lemmas as named obligations in their own phase (Phase 7). The archive's `junction_depth` bound lemmas (`jd_untl_le_left` and siblings) indicate the shape; re-derive, don't trust. |
| **Occurrence-level reasoning has no direct Lean counterpart.** "Maximal appearance", "most deeply nested" are occurrence notions. | Moderate | Restate every measure structurally. `Subformulas.lean`'s `subformulas`/`plusSubformulaClosure` and `BoxStabFree` give usable vocabulary; the `USForm` route keeps the trees small and index-addressable. |
| **CNF packaging blow-up.** Converting a separated Boolean combination to binary `sepForm` clauses can blow up term size and slow elaboration. | Moderate | `SeparationOver` places no size bound, so correctness is all that is required; keep the packaging a separate phase with its own lemma, and if elaboration slows, `lean_profile_proof` the packaging function rather than restructuring the mathematics. |
| **Build cost.** The development lands in `Metalogic/Expressiveness/`, downstream of `OpenLanguage`, so a full rebuild is expensive. | Moderate | Scoped guarded builds per phase (`lake-build-guard.sh build --timeout 1800 -- build Module.Name`), unscoped only at Phase 9. Detach as a shell-level background job and block with the bounded single-call idiom per `context/project/lean4/operations/long-builds.md`. |
| **Concurrency with sibling tasks this cycle.** Siblings 871 (research) and 884 (plan) are dispatched on the same tree; 871's `file_scope` includes `FormalSystem/PlusLanguage/{PlusLCSchema,PlusOmegaChain}.lean` and `FormalSystem/PlusLanguage/README.md`. | Low for research; real at implement time | This task's own file scope should be a new subdirectory (suggested: `FormalSystem/Metalogic/Expressiveness/SeparationZ/`) plus narrow edits to `OpenFutureElimination.lean`, `docs/theorem-index.md` and `scripts/check-module-invariants.sh`. It does **not** need to touch 871's files. Re-read before editing; stage explicit file lists only; never `git-snapshot.sh` in reverting mode. |
| **C14 baseline drift.** New declarations must appear in the pinned axiom baseline with measured profiles. | Low | Measure with `#print axioms` / `lean_verify` and paste the measured output; never hand-type a profile. Expect `[propext, Classical.choice, Quot.sound]` to remain the ceiling — nothing in the route above needs more, and a computable `sepZ` should need strictly less. |
| **`sepZ` accidentally non-computable.** A stray `Classical.choose` or decidability gap in the separation function would silently defeat the executability deliverable. | Low | Declare `sepZ` and `trZ` as plain `def`s with no `noncomputable` keyword — the compiler then enforces it, exactly as the module docstring records for its own `Decidable`-valued declarations. |

## Tactic Survey Results

A tactic survey was performed only to the limited extent this phase supports: no Lean file for this task exists yet, so there is no proof goal to attempt tactics against, and `lean_multi_attempt` has no position to target. No speculative tactic probes were run, and no `lean_multi_attempt` / `lean_hammer_premise` results are reported as if they were evidence.

What was established instead, as pre-survey groundwork for the implementation phases:

| Goal class (anticipated) | Candidate | Status | Premises/Config |
|---|---|---|---|
| "least `u > t` with `A u`" over ℤ (GHR 10.2.2, 10.2.3 case splits) | `Int.exists_least_of_bdd` | available | `Mathlib/Data/Int/LeastGreatest.lean:69`; classical form, decidable computable variant at line 47 |
| adjacent-point arithmetic on ℤ, empty open intervals `(t, t+1) ∩ ℤ = ∅` | `omega` | expected to apply | available once the carrier is ℤ via `plusValidZTime_iff_plusValidInt`; unavailable over an abstract `IsZTime` carrier |
| Boolean skeleton rearrangement (DNF/CNF, GHR 10.2.4, R7) | `simp` / `tauto` on `usTruth` clause lemmas | not yet probed | requires the `usTruth` clause lemmas of Phase 1 to exist first |
| purity side conditions `IsPurePast`/`IsPureFuture` of a `toPlus` image | `constructor` / direct inductive-constructor application | expected trivial | `box`, `stab`, `atom`, `bot` are all leaf constructors of both predicates |
| dual (`S`-side) cases of every elimination | `reflectTime` rewriting | available | `plusValidIn_reflectTime_iff` (`PlusReversal.lean:202`), `IsPureFuture.reflectTime` / `IsPurePast.reflectTime` (`Formula.lean:326,338`) |

The implementation plan should run the actual `lean_multi_attempt` survey per phase, at real goal positions, once Phase 1 has landed the clause lemmas.

## Context Extension Recommendations

- **Topic**: Uniform substitution in L⁺ and why it is not available.
  **Gap**: Nothing in `context/project/lean4/` or `FormalSystem/PlusLanguage/README.md` records that `PlusFormula.atom` being evaluated at `M.valuation (τ.state t)` blocks the usual "modify the valuation" proof that validity is closed under uniform substitution, nor that `Substitution.lean`'s `substPlus` is a language translation rather than an endo-substitution. This is a trap that costs real time to rediscover, and it is the reason Decision D1 exists.
  **Recommendation**: add a short note to `FormalSystem/PlusLanguage/README.md` (or a `context/project/lean4/domain/` entry) stating the obstruction and naming the abstract-leaf workaround.

- **Topic**: Carrier normalization as a standard first move for ZTime results.
  **Gap**: `plusValidZTime_iff_plusValidInt` is documented in its own module as a prerequisite for "any integer-indexed decidability route", but no context file advertises it as the general way to escape `IsZTime`'s accessor-free existential form when proving a ZTime validity.
  **Recommendation**: record the pattern — "to prove a ZTime validity, normalize to ℤ first" — alongside the `IsZTime` discussion.

- **Topic**: Mining the Kamp Boneyard safely.
  **Gap**: `Boneyard/Kamp/KampWeakCanonical/Separation/README.md` says what the approach was and why it died, but not which of its *steps* are unsound outside `IntStructure`. The `replace_box_with_top` normalization is the concrete instance: harmless for `Formula` over `IntStructure`, unsound for `PlusFormula` over a task frame.
  **Recommendation**: add that single caveat to the archive README, so the next reader does not transplant the step.

## Appendix

### Searches and commands used

- `grep` sweeps over `FormalSystem/` for: `SeparationOver`, `IsZTime`, `IsPurePast`/`IsPureFuture`, `AgreeUpTo`/`AgreeFrom`, `substAtom|subst_formula|atomSubst|PlusFormula.subst`, `exists_least_of_bdd|IsLeast|WellFoundedLT|Int.le_induction`, `Separated|IsSeparated|separable`.
- `find Boneyard -ipath "*eparation*" -name "*.lean"`; `wc -l` and per-file `grep -c sorry` over `Boneyard/Kamp/KampWeakCanonical/Separation/`.
- `mcp__lean-lsp__lean_local_search` on `plusValidZTime_iff_plusValidInt` — confirmed at `FormalSystem/PlusLanguage/PlusIntTransfer.lean`, `index: "warming"`.
- `pdftotext -f 1 -l 20` on `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.pdf`, to cross-check Lemma 10.2.3's bracketing against the markdown chunk.
- Hand-evaluation of the Case 5 counterexample model and of the gloss-consistent reconstruction on that model.

### Files read

- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` (lines 1-160, 280-440, 475-599)
- `FormalSystem/PlusLanguage/Formula.lean` (91-200, 295-345), `PlusTruth.lean` (84-124), `PlusValidity.lean` (99-117), `PlusIntTransfer.lean` (1-100, 155-215), `PlusReversal.lean`, `PlusPasting.lean` (235-255), `Subformulas.lean`, `Substitution.lean`
- `FormalSystem/Semantics/FrameProperty.lean` (100-260)
- `FormalSystem/Metalogic/Expressiveness/README.md`, `Separation/README.md`, `Kamp/README.md`
- `Boneyard/Kamp/KampWeakCanonical/Separation/README.md`, `Eliminations.lean` (1-120, 777-919), `Hierarchy/HierarchyCompletion.lean` (1-80, 880-1000)
- `docs/theorem-index.md` (lines 649, 670-673), `scripts/check-module-invariants.sh` (C14 region)
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md` (§5)

### Literature references

- D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and Computational Aspects*, vol. 1, Oxford University Press, 1994. Chapter 10 §10.2 (Lemmas 10.2.1-10.2.8, Theorems 10.2.9-10.2.10, printed pp. 368-372) — the formalization target. Chapter 10 §10.3 (Theorem 10.3.20) — the Dedekind-complete counterpart, out of scope. Chapter 9 §9.3 — separation equals expressive completeness.
- A. Rabinovich, *A Proof of Kamp's Theorem*, 2014 — the separation-based modern treatment already cited by `OpenFutureElimination.lean` and transcribed in `Metalogic/Expressiveness/Kamp/`.

### Stale documentation noticed in passing

`FormalSystem/Metalogic/Expressiveness/Separation/README.md` tabulates eleven modules (`Distributivity.lean`, `Eliminations.lean`, `SeparationThm.lean`, `TemporalClosure.lean`, `DedekindZ/`, `Hierarchy/` and others). Only three live `.lean` files exist in that directory — `Defs.lean`, `KampTranslation.lean`, `SemanticBridge.lean` — and the listed ones are in `Boneyard/Kamp/KampWeakCanonical/Separation/`. `Expressiveness/README.md` already records the correct live figure (3 files, 926 lines) and states that the hand-written per-subdirectory cells lag the measurement. Not this task's scope, and no action is proposed here; recorded so a future reader of that README is not misled into thinking a live GHR elimination layer already exists.
