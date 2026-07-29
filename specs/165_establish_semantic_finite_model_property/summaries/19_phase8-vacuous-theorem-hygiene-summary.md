# Phase 8 Summary: Hygiene — Vacuous Theorems and Documentation

- **Task**: 165 — establish_semantic_finite_model_property (rescoped to tableau decidability)
- **Phase**: 8 — Hygiene: Vacuous Theorems and Documentation
- **Status**: `[COMPLETED]` in one dispatch, three green commits
- **Date**: 2026-07-29
- **Plan**: `plans/01_tableau-decidability-two-track.md`
- **Dispatch scope**: Phase 8 only. Phase 7.3 was not attempted and was not this dispatch's target.

## What Landed

Three commits, each green before the next began:

| Commit | Content |
|--------|---------|
| `c174e98aa` | Retire `validity_decidable` and `validity_has_decision_procedure` as vacuous |
| `62cefe416` | Replace the two vacuous FMP bounds with the real `2 ^ \|cl(φ)\|` bound |
| `3fda9c843` | Correct the decidability and size-bound documentation (LaTeX + typst) |

### 1. The two `Correctness.lean` deletions

`validity_decidable (φ) : (⊨ φ) ∨ ¬(⊨ φ)` was proved by `exact Classical.em (⊨ φ)` — excluded
middle for an arbitrary proposition, true of every predicate, producing no procedure and no
`Decidable` instance. `validity_has_decision_procedure (φ) : ∃ decision : Bool, decision = true ↔ ⊨ φ`
was proved by `by_cases` supplying `true`/`false` according to the very proposition it purported to
decide — the same tautology with a `Bool` wrapped around it.

Both are deleted and replaced by a retirement note in the style already established by the
`sat_untl_neg`/`sat_snce_neg` and `branchTruthLemma` retirements in `CountermodelExtraction.lean`:
what each said, why its proof did not reach its name, what actually holds in their place, and what
is still owed. The module docstring's "Main Theorems" list is corrected to head with `decide_sound`.

**Blast radius: zero Lean consumers.** A project-wide grep found the names only in prose — the
typst chapter (two places) and the plan/report artifacts.

### 2. The two `FMP/FMP.lean` bounds are now real

The old bodies were vacuous by `∧ True` padding:

- `filtered_world_bound` concluded `∃ n, n ≤ 2 ^ cl.card ∧ ∀ (_S : FilteredWorld φ), True`,
  witnessed by `n := 2 ^ cl.card` — i.e. it asserted only `2 ^ cl.card ≤ 2 ^ cl.card`, and its
  second conjunct was discharged by `intro _; trivial`. It said nothing about `FilteredWorld`.
- `fmp_size_bound` concluded `∃ bound, bound = 2 ^ cl.card ∧ True`, witnessed by `rfl, trivial`.

**The replacement needed no new mathematics.** `filteredCharacteristicSet_injective`
(`FMP/FiniteModel.lean:96`) was already proved and already consumed by `FilteredWorld.finite` for
its `Finite` instance; it had simply never been read for cardinality. Three theorems now stand
where two vacuous ones did:

| Theorem | Statement |
|---------|-----------|
| `assignmentSpace_card` | `Nat.card (Set ↥(subformulaClosure φ)) = 2 ^ (subformulaClosure φ).card` — report 01 F8's **equality** |
| `filtered_world_bound` | `Nat.card (FilteredWorld φ) ≤ 2 ^ (subformulaClosure φ).card` |
| `fmp_size_bound` | The FMP terminus with the bound attached: `¬Derivable Base [] φ → ∃ S, φ ∉ S.carrier ∧ Finite (FilteredWorld φ) ∧ Nat.card (FilteredWorld φ) ≤ 2 ^ cl.card` |

`fmp_size_bound` was given the terminus form so its *name* means a size bound rather than bare
finiteness — the point of the FMP for decidability being not that some finite countermodel exists
but that its size is bounded by a computable function of `φ`.

`filtered_world_bound`'s docstring explicitly rules out the junk-value reading: `Nat.card` is `0`
on an infinite type, which would satisfy the inequality vacuously, so the note records that
`FilteredWorld.finite` is what makes it a real bound. This is a hygiene phase; a bound that is
technically true of an infinite type would have been a subtler version of the same defect.

All three verify to `{propext, Classical.choice, Quot.sound}` only — no `sorryAx`, no custom axiom.

### 3. Documentation

**`latex/subfiles/04-Metalogic.tex` needed more than a citation update.** It did not merely cite
the vacuous theorem; it **restated it as a `\begin{theorem}[Decidability]`** in prose ("Validity in
TM bimodal logic is decidable: for any formula φ, either ⊨φ or ¬⊨φ"). Marking a reference stale
would have left a false theorem standing in the reference document. It is converted to a
`\begin{remark}` recording what the old claim was, why excluded middle is not decidability, and
what is proved instead (`ruleSound_of_mem_allRulesForFC`, 34 rules, four frame classes). The
`2^|cl(φ)|` bound is marked **proved**, naming both new theorems.

**`typst/chapters/p2-decidability-practice.typ`**, four edits: the size-bound passage marked proved
with the injection named; the Correctness-Properties bullet rewritten from "vacuous, included for
documentation purposes" to a deletion record plus the `ruleSound_of_mem_allRulesForFC` entry that
is the real content; two new status-table rows (rule soundness, size bound) with the constructive-
decidability row restated to name what is actually owed; and the semantics-bridge passage extended.

## Plan Deviations

Two, both in the same direction — the plan asked for a stronger claim than the tree supports.

1. **The `isValid φ fc = true ↔ ⊨ φ` replacement was deliberately not stated.** The plan licenses
   it "where natural"; the condition is unmet. Phase 7.3 is `[BLOCKED]`, so `valid_iff_allClosed`
   does not exist and neither do the `Decidable` instances. Writing the iff would have put a
   true-looking name over a proof that cannot reach it — the exact defect this phase removes. The
   retirement note names the obligation instead, including that it must also cover `serialityRule`
   and `timeLinearity`, which sit outside `allRulesForFC` as stages 2 and 3 of `expandOnce`.

2. **`typst:26-28` records what landed, not "Track A's completion of the semantics bridge".** Track
   A did not complete. The passage states which half landed (rule soundness at 34/34) and which did
   not (`valid_iff_allClosed`, the `Decidable` instances), and the status-table row stays
   "Open problem". The plan's own governing phrase for the documentation task is "per what actually
   landed", which is what this follows.

## Verification

| Gate | Result |
|------|--------|
| Full `lake build` | Green, **1983 jobs — matching the recorded baseline exactly** |
| Scoped builds | `Decidability.Correctness`, `Decidability.FMP.FMP` green (1379 jobs) |
| Sorry census, `Decidability/` | **0**, empty inventory (`lean-sorry-census.sh`) |
| Axiom count, `FormalSystem/` | 2, unchanged — no new axioms |
| `Classical.em` theorem bodies in `Decidability/` | **none** — remaining grep hits are prose only |
| `∧ True`-padded conclusions in `Decidability/` | **none** — remaining hits are prose or genuine field proofs |
| Vacuous-definition grep, all `FormalSystem/` | 1 hit, pre-existing and out of tree (see below) |
| `typst compile BimodalReference.typ` | Exit 0 (only pre-existing font-family warnings) |
| `latexmk -g -pdf -halt-on-error BimodalReference.tex` | Exit 0 on a **forced full rebuild** |
| New theorems' axiom dependencies | `{propext, Classical.choice, Quot.sound}` for all three |

**Inspected and cleared, not ignored**: the single vacuous-pattern grep hit is
`FormalSystem/Examples/TemporalStructures.lean:279`, `int_domain_universal (t : Int) :
intTimeHistory.domain t := trivial`. Pre-existing, outside `Decidability/`, and a true statement
about a total history whose `domain` is by design `fun _ => True` — not a placeholder. Likewise
`Verified/Bridge/Omega.lean:195` (`regionHistory_domain ... := trivial`) is an honest `@[simp]`
lemma about a definition that really does have a total domain.

## Carried Forward

- **Phase 7 remains `[BLOCKED]` with 7.3 the single open item.** Nothing in Phase 8 changed that,
  and nothing in Phase 8 gives evidence that the `[BLOCKED]` marker is now wrong. 7.3 still needs
  the fuel/termination side and the truth-lemma gate on top of the completed rule ledger, plus
  obligations for the two rules outside `allRulesForFC`.
- **7.3 must still be planned against six accepted `TemporalWitnessProbe` rows, not eight.** The
  prior dispatch's correction stands untouched.
- The task is **not** fully complete: 7 of 8 phases done, Phase 7 blocked.
