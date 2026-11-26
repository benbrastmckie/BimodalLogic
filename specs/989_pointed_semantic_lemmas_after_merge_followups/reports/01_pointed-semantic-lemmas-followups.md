# Research Report: Task #989

**Task**: 989 - Pointed semantic lemmas: after-merge follow-ups
**Started**: 2026-11-24T16:58:00Z
**Completed**: 2026-11-24T17:40:00Z
**Effort**: medium (one implementation dispatch; ~3 phases)
**Dependencies**: None blocking. Adjacent and separate: `connective_signature_layer_shared_primitives` (owns the named interval operators and the `next`/`prev` encoding), `promote_next_prev_covby_to_generic_lemmas` (owns the `next_iff_covBy` promotion).
**Sources/Inputs**:
- Merged tree at `a770ce4f0` (branch `dev/m7-ladder-continuation`), modules added by `72de818a4`
- `specs/reviews/pr-reviews-2026-11-21/pr11-comment.md` (the posted review) and `pr11-review.md` (the fuller draft)
- `specs/archive/978_review_pr11_pointed_semantic_lemmas/reports/01_review-pr11-pointed-semantic-lemmas.md`
- `specs/archive/990_rereview_pr11_at_rewriteable_pointed_truth_head/reports/01_rereview-pr11-at-usability-and-tests.md`
- Ten compiled probes via `lake env lean` against the built `.olean` tree (paths in the Appendix)
**Artifacts**:
- `specs/989_pointed_semantic_lemmas_after_merge_followups/reports/01_pointed-semantic-lemmas-followups.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All three follow-up items are still outstanding.** The contributor's post-review push (`b2eb3ac0b`) landed the three *merge conditions* — including the L⋆ test rows in `TemporalRulesTest.lean` — but touched none of the after-merge list. Nothing to drop.
- **The whole proposed delta compiles clean today, in one probe file**: two positive-reading lemmas, two primitive-tense persistence lemmas, two new env-aware point relations with `.intro` lemmas, two L⋆ transport factories, and seven test rows spanning L, L⁻, L⁺ and L⋆.
- **Two review claims do not survive compilation, and both change the plan.** (a) The directory's `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree` form **cannot** be adopted by `PointTransport.lean` — that module already imports `ProofSystem.Axiom` transitively. (b) The L⋆ transport factories are **not** "nearly free" wraps: the existing `Shifted` and `SameStateNow` relations do not constrain `Point.env`, so the naive wraps fail to typecheck.
- **One measured bonus**: the new primitive-tense `allFuture_persist` sibling is `[propext]`, strictly *cleaner* than the existing `untl`-derived `allFuture_persist`, which is `[propext, Classical.choice, Quot.sound]`.
- **Recommended shape**: three phases, one per review item, in the order (2) docstrings + locks → (1) positive reading → (3) lemmas. Item 2 is the cheapest and touches the same three files item 1 and 3 touch, so doing it first avoids two passes over the same headers.

## Context & Scope

Researched: what each of the three after-merge follow-up items concretely requires in the merged tree, whether any was already done, and whether each is achievable as stated. Every recommended declaration was compiled before being written here.

The four modules the review is about, all added by `72de818a4` and all on `main`:

| Module | Lines | Docstring title | `assert_not_exists` spelling |
|---|---|---|---|
| `FormalSystem/Semantics/TemporalRules.lean` | 130 | **none** | `DerivationTree FrameClass` |
| `FormalSystem/Semantics/TemporalIntervals.lean` | 105 | **none** | `DerivationTree FrameClass` |
| `FormalSystem/Semantics/RankProgress.lean` | 82 | **none** | `DerivationTree FrameClass` |
| `FormalSystem/Semantics/PointTransport.lean` | 360 | `# Transport between pointed truth judgments` | `DerivationTree Derivable PlusDerivationTree` |

"The three generic modules" in both the posted comment and the draft's request 6 means the first three rows (the three that lock `DerivationTree FrameClass`). `PointTransport.lean` is the fourth, and already has a title.

Out of scope by explicit territory statement in the task description and the posted review: defining named `release`/`trigger`/`weakUntil`/`inclusiveUntil` operators (signature layer), and the `next_iff_covBy`/`prev_iff_covBy` promotion.

## Findings

### Codebase Patterns

**Nothing in the three items has been done.** Verified by reading the merged files:

- `release_iff`/`trigger_iff` (`TemporalIntervals.lean:68` and `:77`) are still `simp only [neg_iff, UntlClause.untl_clause]` with the negated clause transcribed on the right-hand side.
- The three modules still carry no `# ` title; three `assert_not_exists` spellings are still live in `FormalSystem/Semantics/`.
- `allFuture_persist`/`allPast_persist` (`TemporalRules.lean:75`, `:82`) are still stated with `[UntlClause L]`/`[SnceClause L]` only.
- `PointTransport.lean` imports no `StarLanguage` module and carries no L⋆ factory. `Tests/BimodalTest/Semantics/PointTransportTest.lean` instantiates at `Formula` and `PlusFormula` only.

**The merge condition about an L⋆ test row *was* satisfied**, elsewhere: `TemporalRulesTest.lean:31-33` exercises `next_iff` at L⋆ with an explicit `regs : ℕ → F.Duration`, and `:102-109` exercises `rank_progress_truth_strict` at L⋆. So the "including one at the star language" obligation in this task's description is about the *new* declarations, not a re-do.

**Docstring shape, measured at current `main`.** Of 47 modules in `FormalSystem/Semantics/` (top level), 44 open with a `# ` title, 28 carry `## Tags`, 23 carry a `## Main Definitions`/`## Main Results` section. The three without a title are exactly `TemporalIntervals.lean`, `RankProgress.lean`, `TemporalRules.lean`. These counts reproduce the review's numbers exactly. `StateLocalTransfer.lean` is the shape the review names to copy: `# Title`, a framing paragraph, `## Main Results`, a "Why this is a separate module" section, `## References`, `## Tags`.

**Lock census in `FormalSystem/Semantics/`**: 20 `assert_not_exists` statements — 16 in the directory form `Axiom DerivationTree`, 3 in `DerivationTree FrameClass`, 1 in `DerivationTree Derivable PlusDerivationTree`.

**The clause-class tiers that decide item 3's statements** (`TruthClauses.lean`):
- `AllFutureClause.allFuture_clause : T M τ t e (allFuture φ) ↔ ∀ s, t < s → T M τ s e φ` (`:291-297`), and `AllPastClause` dually (`:300-306`). These are the *primitive* tenses, distinct from the derived `TruthClauses.allFuture` the existing persist lemmas use.
- `MinusFormula` has `TenseClauses` only (`MinusTruth.lean:128-138`) — `allFuture_clause`/`allPast_clause` are both `Iff.rfl`. It has no `untl`, which is exactly why the existing persist lemmas miss it.
- Naming precedent for this tier: `someFuture_iff_of_allFuture`, `somePast_iff_of_allPast`, `always_iff_of_tense`, plus primed derived operators `someFuture'`, `somePast'`, `always'`.

**The L⋆ side of item 3.** `starTruthAt_timeShift` (`StarTruth.lean:345`) has shape

```
StarTruthAt M (σ.timeShift Δ) t v φ ↔ StarTruthAt M σ (t + Δ) (fun i => v i + Δ) φ
```

— the stored-time vector **shifts**. `StarStateLocal.IsStateLocal` (`:190-193`) quantifies `(τ σ t v)` and fixes **one** `v` on both sides. `PointTransport`'s `Shifted Δ p q` (`:171`) and `SameStateNow p q` (`:145`) mention only `history` and `time`; `Point.env` is unconstrained in both, and `Shifted.intro`/`SameStateNow.intro` take two *independent* implicit environments `{e e'}`. For L and L⁺ this is harmless because `Env _ := PUnit`; for L⋆ it is the gap.

There is **no** L⋆ reversal to wrap (`grep` for `starTruthAt_rev`/`StarReversal` in `FormalSystem/StarLanguage/` returns nothing), confirming the review's parenthesis. `StarFormula` also has **no** derived `release`/`trigger` (`StarLanguage/Formula.lean` defines `neg`, `someFuture`, `allFuture`, `next` and no interval operators), so an L⋆ test row for the positive reading must spell the `(untl guard.neg event.neg).neg` encoding rather than a named operator — which is correct anyway, since the named operators belong to the signature-layer task.

**Precedent for `PointTransport` importing L⋆**: `StateLocalTransfer.lean` and `ValidityLayer.lean` are both `FormalSystem/Semantics/` modules that already import `StarLanguage`.

### External Resources

No Mathlib search was needed: every lemma here is a restatement over the project's own clause classes, and the only Mathlib ingredients used are `lt_trans`, `by_contra` and the `push Not` tactic (the spelling this toolchain's Mathlib uses, already used in `TruthClauses.lean:691`). Three rate-limited search tools were therefore not called at all.

### Recommendations

Three phases, in this order.

**R1 — Item (2), docstrings and the lock, first.** Give `TemporalRules.lean`, `TemporalIntervals.lean` and `RankProgress.lean` a `# ` title plus `## Main Results`, `## References` and `## Tags`, copying `StateLocalTransfer.lean`'s shape, and move their lock to the directory form `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`.
[VERIFIED: PASS -- `lake env lean` on a probe importing `FormalSystem.Semantics.TruthClauses` (the sole import of all three modules) with the directory-form lock: exit 0, no diagnostics]

**R2 — Item (2) for `PointTransport.lean`: the directory form is NOT available, keep a `DerivationTree`-rooted lock.** The review's stated ground for one spelling ("`FrameClass` and `Axiom` are declared in the same file, so excluding the first excludes the second") holds for the three generic modules but **not** for `PointTransport.lean`: `assert_not_exists FormalSystem.ProofSystem.Axiom` fails there, because `Semantics.HistoryMorphism → PlusLanguage.PlusValidity → Semantics.Validity → Semantics.ValidityLayer → Semantics.FrameClassValidity → ProofSystem.Axioms` already puts both `Axiom` and `FrameClass` in that module's environment (`#check @FormalSystem.ProofSystem.Axiom` succeeds after `import FormalSystem.Semantics.PointTransport`).
[VERIFIED: FAIL -- `lake env lean` on a probe carrying `PointTransport.lean`'s exact seven imports plus `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree FormalSystem.PlusLanguage.PlusDerivationTree`: `error: Declaration FormalSystem.ProofSystem.Axiom is not allowed to be imported by this file`, with the chain above printed; revised to: spell `PointTransport.lean`'s lock `assert_not_exists FormalSystem.ProofSystem.DerivationTree FormalSystem.PlusLanguage.PlusDerivationTree FormalSystem.StarLanguage.StarDerivationTree` — drop `Derivable` (implied: `ProofSystem/Derivable.lean` imports `ProofSystem/Derivation.lean`, which declares `DerivationTree`, so a module that could see `Derivable` could see `DerivationTree`), and add `StarDerivationTree` once the module imports L⋆ under R6. Record the import chain in the module docstring so the next reader does not "fix" the spelling back.]

**R3 — Item (1), the positive reading, as two new lemmas in `TemporalIntervals.lean`, proved from the existing ones.** Keep `release_iff`/`trigger_iff` (the posted review dropped the draft's "or drop them" option). Recommended names `release_iff_forall`/`trigger_iff_forall` — avoid `_pos`, which collides with Mathlib's positivity convention already in use in this tree (`List.length_pos_iff` appears at six call sites under `FormalSystem/Metalogic/`).

```lean
theorem release_iff_forall {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (neg (UntlClause.untl (neg guard) (neg event))) ↔
      ∀ s : F.Duration, t < s → TruthEnv.T M τ s e event ∨
        ∃ r : F.Duration, t < r ∧ r < s ∧ TruthEnv.T M τ r e guard := by
  rw [release_iff]
  constructor
  · intro h s hts
    by_contra hc
    push Not at hc
    exact h ⟨s, hts, hc.1, fun r htr hrs => hc.2 r htr hrs⟩
  · rintro h ⟨s, hts, hne, hg⟩
    rcases h s hts with he | ⟨r, htr, hrs, hgr⟩
    · exact hne he
    · exact hg r htr hrs hgr
```

`trigger_iff_forall` is the `snce`/`<`-reversed mirror, same proof skeleton, `rw [trigger_iff]`.
[VERIFIED: PASS -- both compile via `lake env lean`, exit 0. Measured axiom cost: `[propext, Classical.choice, Quot.sound]`, against `release_iff`'s `[propext, Quot.sound]`. The `Classical.choice` is unavoidable (`¬¬event s → event s` is the content of the `mp` direction) and is already the profile of the directly analogous `TruthClauses.someFuture_iff_of_allFuture` and `somePast_iff_of_allPast`, both of which use the same `by_contra`/`push Not` route. `TruthClauses.lean`'s "Classical discipline" note binds `neg_iff`/`top_true` specifically, not this tier.]

**R4 — Item (3a), two primitive-tense persistence siblings in `TemporalRules.lean`'s `Persistence` section.** Recommended names `allFuture_persist_of_tense`/`allPast_persist_of_tense`, following `always_iff_of_tense`. They need neither `BotClause` nor `ImpClause`.

```lean
theorem allFuture_persist_of_tense {L : Type} [TruthEnv L] [AllFutureClause L]
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {e : TruthEnv.Env L F}
    {t s : F.Duration} {P : L}
    (h : TruthEnv.T M τ t e (AllFutureClause.allFuture P)) (hts : t < s) :
    TruthEnv.T M τ s e (AllFutureClause.allFuture P) :=
  (AllFutureClause.allFuture_clause M τ s e P).mpr fun u hsu =>
    (AllFutureClause.allFuture_clause M τ t e P).mp h u (lt_trans hts hsu)
```

`allPast_persist_of_tense` dually, with `hst : s < t` and `lt_trans hus hst`.
[VERIFIED: PASS -- both compile, exit 0, and both instantiate at L⁻ (`allFuture_persist_of_tense (L := MinusFormula) (e := PUnit.unit) h hts` closes `MinusTruthAt M τ t (MinusFormula.allFuture P) → t < s → MinusTruthAt M τ s (MinusFormula.allFuture P)`). Measured axiom profile `[propext]` — strictly cleaner than the existing `TemporalRules.allFuture_persist`, which measures `[propext, Classical.choice, Quot.sound]` because its `untl`-derived `allFuture_iff` route goes through `top_true`.]

**R5 — Item (3b) prerequisite: two env-aware point relations in `PointTransport.lean`'s `Relations` section.** `Shifted` and `SameStateNow` must not be *changed* — `Shifted.intro` and `SameStateNow.intro` deliberately admit two different environments, and `plus_iffTransport_stateLocal` and its test row consume the weaker relation. Add alongside:

```lean
/-- Same time, same current world state, and the same evaluation environment. The environment
clause is vacuous where `Env F` is `PUnit`, and is what a stored-time language needs. -/
def SameStateNowEnv (p q : Point L F) : Prop := SameStateNow p q ∧ p.env = q.env

/-- `Shifted` with the evaluation environment carried along by `shift`. -/
def ShiftedEnv (Δ : F.Duration) (shift : TruthEnv.Env L F → TruthEnv.Env L F)
    (p q : Point L F) : Prop := Shifted Δ p q ∧ q.env = shift p.env
```

plus `.intro` lemmas in the directory's style (`SameStateNowEnv.intro τ σ t h : SameStateNowEnv ⟨τ,t,e⟩ ⟨σ,t,e⟩`, `ShiftedEnv.intro σ t Δ shift e : ShiftedEnv Δ shift ⟨σ.timeShift Δ, t, e⟩ ⟨σ, t + Δ, shift e⟩`, both `⟨⟨rfl, _⟩, rfl⟩`).
[VERIFIED: PASS -- all four declarations compile, exit 0. The strengthened relation remains usable with the existing L⁺ factory via `.1`: `(plus_iffTransport_stateLocal hφ M).apply h.1` typechecks for `h : SameStateNowEnv p q`.]

**R6 — Item (3b), the two L⋆ factories, in a new `Star` section of `PointTransport.lean`.** Add `import FormalSystem.StarLanguage.StarTruth` and `import FormalSystem.StarLanguage.StarStateLocal`.

```lean
theorem star_iffTransport_timeShift (M : TaskModel F) (Δ : F.Duration) (φ : StarFormula) :
    IffTransport (ShiftedEnv (L := StarFormula) Δ (fun v i => v i + Δ)) M M φ φ := by
  rintro ⟨τ, t, v⟩ ⟨σ, s, w⟩ ⟨⟨hτ, hs⟩, hw⟩
  dsimp only at hτ hs hw
  subst hτ hs hw
  exact starTruthAt_timeShift M φ σ t Δ v

theorem star_iffTransport_stateLocal {φ : StarFormula} (hφ : φ.StateLocal) (M : TaskModel F) :
    IffTransport (SameStateNowEnv (L := StarFormula)) M M φ φ := by
  rintro ⟨τ, t, v⟩ ⟨σ, s, w⟩ ⟨⟨hs, h⟩, hv⟩
  dsimp only at hs h hv
  subst hs hv
  exact isStateLocal_of_stateLocal hφ F M τ σ t v h
```

The `(L := StarFormula)` ascription on the relation is **load-bearing** in the first statement: without it `fun v i => v i + Δ` fails to elaborate (`Function expected at v but this term has type TruthEnv.Env ?m F`). The same ascription is needed at the `ShiftedEnv.intro` call site, together with an explicit `(fun (v : ℕ → F.Duration) i => v i + Δ)`.
[VERIFIED: FAIL then PASS -- the naive wrap over the *existing* `Shifted Δ` relation fails: `Type mismatch ... has type StarTruthAt M (σ.timeShift Δ) t v φ ↔ StarTruthAt M σ (t + Δ) (fun i => v i + Δ) φ but is expected to have type At M {history := σ.timeShift Δ, time := t, env := v} φ ↔ At M {history := σ, time := t + Δ, env := w} φ`, i.e. the unconstrained `w`. Over `ShiftedEnv`/`SameStateNowEnv` both compile, exit 0, with axiom profiles `[propext, Classical.choice, Quot.sound]` and `[propext]` — identical to their L⁺ counterparts `plus_iffTransport_timeShift` and `plus_iffTransport_stateLocal`. Adding the two L⋆ imports keeps `PointTransport.lean`'s `DerivationTree`-rooted lock green, including with `StarDerivationTree` added.]

**R7 — Test rows, one per new declaration, in the two existing test modules.** This is gate-backed, not optional: `scripts/check-module-invariants.sh`'s C17 dead-declaration scan flags base identifiers with zero occurrences outside their own declaring line, counting occurrences in `Tests/`. C16's `docBlame` likewise requires a docstring on each new declaration.
- `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` (already imports `MinusTruth`? **no** — add `import FormalSystem.MinusLanguage.MinusTruth`): the two L⁻ persistence rows, and the positive-reading rows at L and at L⋆ (one for `release_iff_forall`, one for `trigger_iff_forall`).
- `Tests/BimodalTest/Semantics/PointTransportTest.lean`: the two L⋆ factory rows, which also give `ShiftedEnv`, `SameStateNowEnv` and both `.intro` lemmas their references.
[VERIFIED: PASS -- seven candidate rows compiled in the consolidated probe, exit 0, covering L, L⁻, L⁺ and L⋆. The L⋆ positive-reading row is `((release_iff_forall (L := StarFormula) M τ t regs event guard).mp h s hts).resolve_left hne` against `h : StarTruthAt M τ t regs (StarFormula.untl guard.neg event.neg).neg`; note `StarFormula` has no named `release`, so the encoding is spelled out — correct, since the named operator belongs to the signature-layer task.]

**R8 — The whole delta compiles together.** Everything in R3-R7, plus the `DerivationTree PlusDerivationTree StarDerivationTree` lock, was compiled as a single file.
[VERIFIED: PASS -- `lake env lean` on the consolidated probe, exit 0, no diagnostics]

**R9 — No `docs/theorem-index.md` row is owed.** C15 asserts index-row → anchor, not declaration → index-row, and the four contributed modules carry no index rows today while the tree is green.
[VERIFIED: PASS -- read at `scripts/check-module-invariants.sh:45-48`; `grep` for the four module names in `docs/theorem-index.md` returns nothing]

## Decisions

- **Scope the `assert_not_exists` unification to the three generic modules.** `PointTransport.lean` cannot take the directory form; attempting it is a compile error, not a style preference. Decided on the compiled evidence in R2, against the posted review's blanket wording.
- **Add new relations rather than strengthen `Shifted`/`SameStateNow`.** Strengthening would break `Shifted.intro`/`SameStateNow.intro`'s two-environment signatures and change an API that merged at `72de818a4` (2026-11-23). Additive is both cheaper and non-breaking (R5).
- **Keep `release_iff`/`trigger_iff` and add the positive readings beside them.** The posted review's softened text keeps both; the draft's "or drop them" option was explicitly not posted.
- **Name the positive readings `_iff_forall`, not `_iff_pos`.** `_pos` means "positive" in the Mathlib convention this tree already consumes.
- **Name the primitive-tense siblings `_of_tense`, following `always_iff_of_tense`.** The alternative `_of_allFuture` suffix reads badly on a lemma whose subject is already `allFuture`.
- **State the positive readings over the clause-class encoding, not a named operator.** The named operators are `connective_signature_layer_shared_primitives`'s territory, stated as such in both the task description and the posted review.
- **Accept the `Classical.choice` delta on the positive readings.** It is intrinsic to the statement and matches the existing tense-tier precedent in the same layer.

## Risks & Mitigations

- **Risk**: an implementer "fixes" `PointTransport.lean`'s lock to the directory form on a later pass, hits the compile error, and either reverts the module's imports or weakens the lock. **Mitigation**: R2's import chain goes into the module docstring (which item 2 is rewriting anyway), so the reason is recorded where the next reader will be standing.
- **Risk**: the `(L := StarFormula)` ascriptions look redundant and get deleted during cleanup, producing an elaboration error that reads as unrelated (`Function expected at v`). **Mitigation**: a one-line comment at the `ShiftedEnv` application naming the reason.
- **Risk**: `lake lint`/C16 `docBlame` on the eight new declarations and the two new `def`s, including docstrings on the `SameStateNowEnv`/`ShiftedEnv` structure-like `def`s. **Mitigation**: write the docstrings with the declarations, as the recommendations above already do; the existing relations in the same section are the template.
- **Risk** (low): the three rewritten module docstrings drift from the four-module set — `PointTransport.lean` has a title but, like the other three, no `## Tags` or `## Main Results`. The posted comment asks only for titles "for the three generic modules". **Mitigation**: give all four the full `StateLocalTransfer.lean` shape; it is strictly within the ask and removes the asymmetry the review noticed.
- **Risk**: C17's dead-declaration scan fires on any new declaration that the plan forgets a test row for — in particular `trigger_iff_forall`, which is easy to leave untested once `release_iff_forall` has a row. **Mitigation**: R7 enumerates one row per new declaration; the plan should carry that enumeration as a checklist.

## Tactic Survey Results

Candidates were tested by direct compilation rather than through `lean_multi_attempt`, because every goal here is a known-shape restatement and the proof terms were written out in full. The two tactics that mattered:

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `release_iff_forall` / `trigger_iff_forall`, `mp` direction | `by_contra` + `push Not` | success | the toolchain's `push Not` spelling (not `push_neg`), as used at `TruthClauses.lean:691`; costs `Classical.choice` |
| `release_iff_forall` / `trigger_iff_forall`, reduction to the existing lemma | `rw [release_iff]` / `rw [trigger_iff]` | success | satisfies the task's "proved from the existing one" |
| `allFuture_persist_of_tense` / `allPast_persist_of_tense` | explicit term via `AllFutureClause.allFuture_clause` + `lt_trans` | success | no tactic needed; keeps the profile at `[propext]` |
| L⋆ factories, after `rintro`/`subst` | `exact starTruthAt_timeShift …` / `exact isStateLocal_of_stateLocal …` | success | needs `dsimp only at` before `subst`, exactly as the existing L⁺ factories do |
| L⋆ factories over the unmodified `Shifted`/`SameStateNow` | any | fail | type mismatch on the unconstrained `Point.env`; no tactic can close it |

## Context Extension Recommendations

- **Topic**: `assert_not_exists` lock spellings are not freely interchangeable across a directory.
- **Gap**: `.claude/context/project/lean4/` has no note on this. The review reasoned from "same declaring file ⇒ equivalent lock", which is sound for the *declaration* but says nothing about whether the stronger name is already in a given module's import closure. Two of this task's three items turned on that distinction, and the failure mode is a compile error whose message points at an import chain six modules long rather than at the lock.
- **Recommendation**: add `.claude/context/project/lean4/patterns/assert-not-exists-lock-scoping.md` — the rule ("a lock is only adoptable if every name in it is absent from *this* module's import closure; check by compiling the proposed lock against the module's own import list, not by comparing declaring files"), the diagnostic shape to recognise, and the cheap probe recipe (`lake env lean` on a file carrying just the imports plus the candidate lock).

## Appendix

**Probe files** (all under `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/c56b57e5-9ce6-4ce2-8276-0ad7f6ac6b6b/scratchpad/`, run as `lake env lean <file>` from the repo root against the already-built `.olean` tree; no `lake build` was required):

| Probe | What it established |
|---|---|
| `probe1.lean` | positive readings + primitive persistence compile; L⁻ instantiations; axiom profiles |
| `probe2.lean` | axiom baselines for `allFuture_persist`, `someFuture_iff_of_allFuture`, `somePast_iff_of_allPast`, `next_iff` |
| `probe3.lean` | **FAIL**: naive L⋆ time-shift wrap over `Shifted` |
| `probe4.lean` | env-aware relations + both L⋆ factories compile; L⁺ factory still usable via `.1` |
| `probe5.lean` | axiom baselines for the two L⁺ factories and `plusTruthAt_timeShift` |
| `probe6.lean` | directory-form lock is adoptable under `TruthClauses` alone |
| `probe7.lean` | **FAIL**: directory-form lock under `PointTransport`'s imports, with the printed chain |
| `probe8.lean` | `Axiom` and `FrameClass` are both in `PointTransport`'s environment |
| `probe9.lean` | `PointTransport`'s existing lock stays green after adding the two L⋆ imports |
| `probe10.lean` | the consolidated delta — ten declarations, seven test rows, the new lock — compiles clean |

**Shell probes**: module-docstring census over `FormalSystem/Semantics/*.lean` (47 / 44 / 28 / 23); lock census (20 / 16 / 3 / 1); `grep` for `starTruthAt_rev`, `StarReversal`, `StarFormula.release`, `_iff_pos`, and `theorem-index` references in the gate scripts.

**Search tools not used**: `lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_state_search`, `lean_hammer_premise`. No Mathlib lemma discovery was required — every result is a restatement over this project's own clause classes — so no rate limit was touched and no MCP fallback was needed.

**Documents read**: `specs/reviews/pr-reviews-2026-11-21/pr11-comment.md` (posted), `pr11-review.md` (draft, requests 5-7 and the "Moved to the after-merge list" section), `FOLLOWUP.md`, and the two archived review reports named under Sources/Inputs.
