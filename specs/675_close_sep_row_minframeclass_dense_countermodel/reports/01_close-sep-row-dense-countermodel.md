# Research Report: Task #675

**Task**: 675 - Close the sep row of Axiom.minFrameClass by constructing a densely ordered countermodel
**Started**: 2026-09-25T00:00:00Z
**Completed**: 2026-09-25T00:00:00Z
**Effort**: Medium (single implementation phase; the whole proof is already machine-checked below)
**Dependencies**: None (`DenseRTimeSharpness.lean` and `Soundness.lean` are landed)
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Independence/`, `FormalSystem/Semantics/`, `FormalSystem/ProofSystem/Axioms.lean`), Mathlib source (`Mathlib/Data/Finsupp/Lex.lean`), lean-lsp MCP (`lean_run_code`), the dispatch's route survey
**Artifacts**: - specs/675_close_sep_row_minframeclass_dense_countermodel/reports/01_close-sep-row-dense-countermodel.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Route 2 works, and the whole countermodel is already machine-checked.** `D = Lex (ℚ →₀ ℚ)`
  with φ-region `{toLex (single γ 1) : γ > 0}` and `t = 0` refutes `Axiom.sep`'s atomic instance
  at frame level. `sep_minFrameClass_sharp` was elaborated end-to-end via `lean_run_code` and
  reports `depends on axioms: [propext, Classical.choice, Quot.sound]` — the pinned set, zero
  sorries. The complete proof text is in **Findings → The verified countermodel** below; the
  implementation phase is a transcription-and-docstring exercise, not a discovery exercise.
- **The dispatch's recorded instance gap is stale.** `IsOrderedAddMonoid (Lex (ℚ →₀ ℚ))` is
  *already* available from Mathlib via `Finsupp.Lex.isOrderedCancelAddMonoid`; no instance needs
  writing off `addLeftMono`/`addRightMono`. The one genuinely missing instance is
  `DenselyOrdered (Lex (ℚ →₀ ℚ))`, which is 14 lines (proof below, verified).
- **A stronger result than minimality is available and is *not* the shape the dispatch
  anticipated.** `Axiom.sep` is **valid at `.ZTime`** — schematically, for every `φ`, because
  `IsZTime` supplies a `SuccOrder` and hence a least positive duration, feeding the landed
  `sep_validOn_of_isLeastPos`. So the characterization is
  `ValidIn fc φ ↔ fc = .ZTime ∨ .RTime ≤ fc`, **not** `↔ .RTime ≤ fc`. Claiming the latter would
  be false. This is the one place where `sep` and `prior_U_gap` genuinely diverge.
- **Recommended landing site**: a new sibling module
  `FormalSystem/Metalogic/Independence/SepSharpness.lean`. `DenseRTimeSharpness.lean` is already
  400 lines and the new carrier brings its own ~90 lines of order machinery.
- **No sorry-deferral, no new axiom, no `[BLOCKED]` outcome is warranted.** A sorry-free path
  exists and has been exercised.

## Context & Scope

Researched: how to close the `sep` row of `Axiom.minFrameClass` — the sole remaining
upper-bound-only row — by exhibiting a densely ordered duration group on which `Axiom.sep`'s
atomic instance fails, thereby refuting it at both `.Base` and `.Dense` (the only two classes
strictly below `.RTime`, by the landed `base_or_dense_of_lt_rtime`).

Constraints honoured:

- The landed obstruction pair (`not_kPlus_of_isLeastPos`, `sep_validOn_of_isLeastPos`) plus
  `Semantics.duration_dense_or_least_pos` proves no discrete witness can exist. No discrete
  carrier was attempted.
- Frame-level refutation (`¬ F.ValidOn φ`) throughout, per the README's criterion: a bare
  non-validity claim validates nothing, so the `CoNotPriorU.lean` frame-versus-model obstruction
  does not bite.
- Atomic instance only (`Formula.atom a`), never a schematic `∀ φ` non-validity claim.
- Scope limited to `FormalSystem/` and the `sep` row.

Out of scope and untouched: the `density`, `dense_indicator`, `prior_U_gap` and `.ZTime` rows;
the compression/adequacy direction; the ModelChecker repository.

## Literature Proof Structure

Not applicable in the extraction sense: no external paper was supplied to this dispatch. The
relevant literature anchor is already transcribed in the tree —
`ProofSystem/Axioms.lean`'s `Axiom.sep` docstring cites Reynolds 1992, printed p.168, and
`Metalogic/Soundness.lean`'s `sep_valid` docstring records the one deliberate fidelity deviation
from Reynolds §7 (the `nested_core` substitution for the `S ≅ ℚ` step). Nothing below revisits
either; this task needs only the *negative* direction, which Reynolds does not treat.

One conceptual debt to the literature is worth recording, because it explains the carrier choice:
Reynolds' validity argument for Sep over ℝ runs on **separability** (a countable dense
suborder). The countermodel below is the exact dual — a duration group whose φ-region is
order-isomorphic to ℚ yet in which *no* point of the ambient order is a two-sided accumulation
point of that region. That is impossible in a separable flow and is what the infinite tower of
archimedean classes in `Lex (ℚ →₀ ℚ)` buys.

## Findings

### Codebase Patterns

- **`Axiom.sep`'s constructor** (`FormalSystem/ProofSystem/Axioms.lean`, constructor `sep`):
  `(K⁺φ ∧ ¬K⁺(φ ∧ untl φ.neg φ)) → K⁺(K⁺φ ∧ K⁻φ)`. Note the prose/constructor argument-order
  trap the Independence README already flags: the docstring's `U(φ,¬φ)` is event-first, the
  constructor's `Formula.untl φ.neg φ` is guard-first. The shape pin below makes this a compiler
  obligation.
- **Truth clauses** (`FormalSystem/Semantics/Truth.lean`): `Truth.kPlus_iff` reads `K⁺φ` at `t`
  as "for every `s > t` there is `r ∈ (t,s)` with `φ`", i.e. *right-accumulation of the φ-region
  at `t`*; `Truth.kMinus_iff` is the left dual; `Truth.untl_iff` is the raw `untl` clause.
  Translating the axiom into order language: `sep` says that if the φ-region accumulates at `t`
  from the right and the φ-points that have a gapped successor do *not* accumulate at `t` from
  the right, then the **two-sided** accumulation points of the φ-region accumulate at `t` from
  the right.
- **The default countermodel route** is the one the Independence README prescribes and both
  landed sharpness modules use: `translationFrame D` / `translationHist D` /
  `translationModel D A` / `translation_realizes` (`Semantics/Frames/Standard.lean` and
  `Semantics/Correspondence/DurationFrames.lean`). `translationFrame_isRegular` is a global
  instance, so `FrameClass.Sat .Base` is `inferInstance` and `Sat .Dense` is
  `⟨inferInstance, inferInstance⟩` once `DenselyOrdered ↑D` is in scope. Verified against the
  real project imports.
- **Order facts**: `by decide` fails on `FrameClass` `<`; `base_or_dense_of_lt_rtime`
  (`DenseRTimeSharpness.lean`) already supplies the two-class split for `.RTime`.
- **Lex-carrier precedent**: `Semantics/LexCarrier.lean` carries the `α ×ₗ ℤ` apparatus and
  `Independence/LexIntWitness.lean` instantiates it. That is `Prod.Lex`, not `Finsupp.Lex`, so it
  supplies style precedent (instance-pinning ritual carried once, generic in the first factor)
  but no reusable lemma.
- **Ledger conventions**: `FormalSystem/Metalogic/Independence.lean` and
  `FormalSystem/Metalogic/Independence/README.md` each enumerate **eleven** numbered results in
  the same order and both open with the sentence "Eleven results are carried here." Adding a
  twelfth means editing that count word in both files, not only appending an item. The README's
  `## Modules` table is a generated inventory block keyed by filename; a new file regenerates
  with `<!-- TODO: add description -->` and the description must then be hand-written,
  **pipe-free** (the generator splits rows on `|`).

### External Resources

Mathlib (pinned `v4.33.0-rc1`, resolved `79d0395a`), `Mathlib/Data/Finsupp/Lex.lean`:

| Needed for `TemporalOrder.of (Lex (ℚ →₀ ℚ))` | Status | Source |
|---|---|---|
| `AddCommGroup` | available (noncomputable) | `Lex` synonym transfer |
| `LinearOrder` | available | `Finsupp.Lex.linearOrder` |
| `Nontrivial` | available | synonym transfer |
| `IsOrderedAddMonoid` | **available** | `Finsupp.Lex.isOrderedCancelAddMonoid` |
| `DenselyOrdered` | **missing — must be written** | — |

All five probed directly with `lean_run_code`. The `IsOrderedAddMonoid` row corrects the
dispatch's recorded expectation (it anticipated a hand-written instance off
`Finsupp.Lex.addLeftMono` / `addRightMono`; none is needed).

Two Mathlib lemmas that look useful and are not usable as-is:

- `Finsupp.Lex.single_lt_iff` and `Finsupp.Lex.single_strictAnti` are **specialised away from a
  general value type** in the pinned snapshot — `#check` shows `α` as the only parameter, with the
  `1` fixed. They do not apply at value type `ℚ`. The three-line replacement is `sg_lt_sg` below,
  proved directly from `Finsupp.Lex.lt_iff`.
- `Finsupp.Lex.lt_iff` carries `set_option backward.isDefEq.respectTransparency false` upstream,
  but applies cleanly through `.mp` / `.mpr` — it was used a dozen times below without trouble.
  It must be applied to terms whose type is *syntactically* `Lex (ℚ →₀ ℚ)`; writing the helper
  lemmas at `(sepOrder : Type)` (i.e. `TemporalOrder.carrier`) makes `ofLex r j` fail to elaborate
  ("Function expected at `ofLex r`"). **State every helper at the bare carrier abbreviation and
  let reducibility bridge to `sepOrder` at the frame-level theorem.** This was a real failure
  observed during probing and is the single most likely way to lose an hour re-deriving.

### Why the carrier is what it is

`D = Lex (ℚ →₀ ℚ)` is the Hahn group `⊕_{γ∈ℚ} ℚ`. Write `sg γ := toLex (single γ 1)`. Then
`γ ↦ sg γ` is **order-reversing** (`sg_lt_sg : sg δ < sg γ ↔ γ < δ`), every `sg γ` is positive,
and `sg γ → 0` as `γ → ∞` in the order sense. The φ-region `A = {sg γ : γ > 0}` therefore:

1. **accumulates at `0` from the right** — given `s > 0` with leading index `i`, `sg (max i 0 + 1)`
   sits strictly between. This is `K⁺φ` at `0`, the first antecedent conjunct.
2. **is densely ordered in itself** (anti-isomorphic to `ℚ_{>0}`), so no `sg γ` has a gapped
   successor in `A`: between `sg γ` and any larger `sg ε` sits `sg ε'` for any `ε < ε' < γ`. So
   `φ ∧ U(φ,¬φ)` is false *everywhere*, and the second antecedent conjunct
   `¬K⁺(φ ∧ U(φ,¬φ))` holds at `0`.
3. **has no right-accumulation point above `0`** — the elements of `A` are mutually infinitely
   separated in the ambient order, so `K⁺φ` fails at every `r > 0`, hence `K⁺φ ∧ K⁻φ` fails at
   every `r > 0`, hence the consequent `K⁺(K⁺φ ∧ K⁻φ)` fails at `0`.

Points 1 and 2 pull in opposite directions and that tension is exactly what the axiom is about:
(2) forces the index order to be **dense** (over `ℕ →₀ ℚ` each `sg (n+1)` *would* have the gapped
successor `sg n`, and those accumulate at `0`, killing the second antecedent conjunct), while (1)
forces the index order to be **unbounded above**. Both are properties of `ℚ` as the *index*, and
the value type must be `ℚ` (or any densely ordered group) to make `D` itself densely ordered.

This also explains, independently, why the dispatch's route 1 cannot work: a two-level
`ℚ ×ₗ ℚ` has only one infinitesimal scale, so the natural φ-region `{(0,q) : q > 0}` *is*
dense-in-itself in the ambient order and every one of its points is a two-sided accumulation
point — the consequent holds and there is nothing to refute. Confirmed by hand; route 1 is
correctly recorded as a dead end, and the reason is sharper than "a group has no fibre tops": one
level is never enough, and neither is any finite number.

**Route 3 (bespoke Cantor set in ℚ) was analysed and is not recommended.** It is not obviously
impossible, but the required φ-region must be a set every one of whose points is isolated from
both sides while the set of its right-limit points is itself non-scattered — a Cantor–Bendixson
regress that has to be built by recursion and then have three separate order properties proved
about it. Route 2 replaces that recursion with a single algebraic carrier. Route 3 should be
recorded as excluded-by-cost, not refuted.

### The verified countermodel

The following elaborated with **zero errors and zero sorries** under the real project imports
(`lean_run_code`, Lean v4.33.0-rc1). The final `#print axioms` line returned
`'sep_minFrameClass_sharp' depends on axioms: [propext, Classical.choice, Quot.sound]`.

```lean
import FormalSystem.Metalogic.Independence.DenseRTimeSharpness
import Mathlib.Data.Finsupp.Lex

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem Finsupp

/-- The Hahn group over a dense index order: finitely supported `ℚ → ℚ`, lexicographic. -/
abbrev DD := Lex (ℚ →₀ ℚ)

instance : DenselyOrdered DD where
  dense := by
    intro x y h
    obtain ⟨i, hlt, hi⟩ := Finsupp.Lex.lt_iff.mp h
    refine ⟨toLex (ofLex x + Finsupp.single i ((ofLex y i - ofLex x i)/2)), ?_, ?_⟩
    · refine Finsupp.Lex.lt_iff.mpr ⟨i, ?_, ?_⟩
      · intro j hj
        rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_neg (ne_of_gt hj), add_zero]
      · rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_pos rfl]; linarith
    · refine Finsupp.Lex.lt_iff.mpr ⟨i, ?_, ?_⟩
      · intro j hj
        rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_neg (ne_of_gt hj), add_zero]
        exact hlt j hj
      · rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_pos rfl]; linarith

noncomputable abbrev sepOrder : TemporalOrder := TemporalOrder.of DD
noncomputable def sg (γ : ℚ) : DD := toLex (Finsupp.single γ (1:ℚ))
def AA : Set DD := {x | ∃ γ : ℚ, 0 < γ ∧ x = sg γ}

@[simp] theorem sg_apply (γ j : ℚ) : ofLex (sg γ) j = if γ = j then 1 else 0 := by
  simp [sg, Finsupp.single_apply]

theorem sg_pos (γ : ℚ) : (0 : DD) < sg γ := by
  refine Finsupp.Lex.lt_iff.mpr ⟨γ, ?_, ?_⟩
  · intro j hj; simp [ne_of_gt hj]
  · simp

theorem sg_lt_of_index_lt {r : DD} {i γ : ℚ} (h0 : ∀ j, j < i → ofLex r j = 0)
    (hi : 0 < ofLex r i) (hγ : i < γ) : sg γ < r := by
  refine Finsupp.Lex.lt_iff.mpr ⟨i, ?_, ?_⟩
  · intro j hj; rw [h0 j hj]; simp [ne_of_gt (hj.trans hγ)]
  · simpa [ne_of_gt hγ] using hi

theorem lt_sg_of_lt_index {r : DD} {i γ : ℚ} (h0 : ∀ j, j < i → ofLex r j = 0)
    (hγ : γ < i) : r + r < sg γ := by
  refine Finsupp.Lex.lt_iff.mpr ⟨γ, ?_, ?_⟩
  · intro j hj
    have hz : ofLex r j = 0 := h0 j (hj.trans hγ)
    simp [hz, ne_of_gt hj]
  · have hz : ofLex r γ = 0 := h0 γ hγ
    simp [hz]

theorem pos_index {r : DD} (h : 0 < r) : ∃ i, (∀ j, j < i → ofLex r j = 0) ∧ 0 < ofLex r i := by
  obtain ⟨i, h1, h2⟩ := Finsupp.Lex.lt_iff.mp h
  exact ⟨i, fun j hj => (h1 j hj).symm, h2⟩

theorem sg_lt_sg {γ δ : ℚ} : sg δ < sg γ ↔ γ < δ := by
  constructor
  · intro h
    obtain ⟨i, h1, h2⟩ := Finsupp.Lex.lt_iff.mp h
    rw [sg_apply, sg_apply] at h2
    have hγi : γ = i := by
      by_contra hne
      rw [if_neg hne] at h2
      split at h2 <;> linarith
    subst hγi
    rcases lt_trichotomy γ δ with h' | h' | h'
    · exact h'
    · subst h'; simp at h2
    · have h3 := h1 δ h'
      rw [sg_apply, sg_apply, if_pos rfl, if_neg (ne_of_gt h')] at h3
      exact absurd h3 (by norm_num)
  · intro h
    refine Finsupp.Lex.lt_iff.mpr ⟨γ, ?_, ?_⟩
    · intro j hj
      rw [sg_apply, sg_apply, if_neg (ne_of_gt hj),
        if_neg (by intro hh; exact absurd (hh ▸ hj) (by linarith))]
    · simp [ne_of_gt h]

/-- The φ-region accumulates at `0` from the right. -/
theorem L1 (s : DD) (hs : 0 < s) : ∃ r, 0 < r ∧ r < s ∧ r ∈ AA := by
  obtain ⟨i, h0, hi⟩ := pos_index hs
  refine ⟨sg (max i 0 + 1), sg_pos _, ?_, ⟨max i 0 + 1, by positivity, rfl⟩⟩
  exact sg_lt_of_index_lt h0 hi (by have := le_max_left i 0; linarith)

/-- No φ-point has an immediate φ-successor across a gap. -/
theorem L2 (r : DD) (hr : r ∈ AA) :
    ¬ ∃ s, r < s ∧ s ∈ AA ∧ ∀ u, r < u → u < s → u ∉ AA := by
  rintro ⟨s, hrs, ⟨ε, hε, rfl⟩, hgap⟩
  obtain ⟨γ, hγ, rfl⟩ := hr
  have hεγ : ε < γ := sg_lt_sg.mp hrs
  obtain ⟨ε', h1, h2⟩ := exists_between hεγ
  exact hgap (sg ε') (sg_lt_sg.mpr h2) (sg_lt_sg.mpr h1) ⟨ε', hε.trans h1, rfl⟩

/-- No `r > 0` is a right-accumulation point of the φ-region. -/
theorem L3 (r : DD) (hr : 0 < r) : ∃ s, r < s ∧ ∀ u, r < u → u < s → u ∉ AA := by
  obtain ⟨i, h0, hi⟩ := pos_index hr
  rcases le_or_gt (sg i) r with hc | hc
  · refine ⟨r + r, lt_add_of_pos_left r hr, ?_⟩
    rintro u hru hus ⟨γ, hγ, rfl⟩
    rcases lt_trichotomy γ i with hh | hh | hh
    · exact absurd (lt_sg_of_lt_index h0 hh) (not_lt.mpr hus.le)
    · exact absurd (hh ▸ hru) (not_lt.mpr hc)
    · exact absurd (sg_lt_of_index_lt h0 hi hh) (not_lt.mpr hru.le)
  · refine ⟨sg i, hc, ?_⟩
    rintro u hru hus ⟨γ, hγ, rfl⟩
    exact absurd (sg_lt_of_index_lt h0 hi (sg_lt_sg.mp hus)) (not_lt.mpr hru.le)

theorem not_validOn_sep (a : Atom) :
    ¬ (translationFrame sepOrder).toTaskFrame.ValidOn
      ((Formula.and (Formula.kPlus (Formula.atom a))
        (Formula.kPlus (Formula.and (Formula.atom a)
          (Formula.untl (Formula.atom a).neg (Formula.atom a)))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus (Formula.atom a))
          (Formula.kMinus (Formula.atom a))))) := by
  intro h
  have hval := h (translationModel sepOrder AA) (translationHist sepOrder) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel sepOrder AA) (translationHist sepOrder) 0
      (Formula.and (Formula.kPlus (Formula.atom a))
        (Formula.kPlus (Formula.and (Formula.atom a)
          (Formula.untl (Formula.atom a).neg (Formula.atom a)))).neg) := by
    rw [Truth.and_iff]
    constructor
    · rw [Truth.kPlus_iff]
      intro s hs
      obtain ⟨r, hr0, hrs, hrA⟩ := L1 s hs
      exact ⟨r, hr0, hrs, (translation_realizes sepOrder AA a r).mpr hrA⟩
    · rw [Truth.neg_iff, Truth.kPlus_iff]
      intro hk
      obtain ⟨r, hr0, _, hr⟩ := hk (sg 1) (sg_pos 1)
      rw [Truth.and_iff] at hr
      obtain ⟨hrA, hru⟩ := hr
      rw [Truth.untl_iff] at hru
      obtain ⟨s, hrs, hsA, hgap⟩ := hru
      refine L2 r ((translation_realizes sepOrder AA a r).mp hrA)
        ⟨s, hrs, (translation_realizes sepOrder AA a s).mp hsA, ?_⟩
      intro u hru' hus huA
      exact (Truth.neg_iff _).mp (hgap u hru' hus) ((translation_realizes sepOrder AA a u).mpr huA)
  have hcon := hval hant
  rw [Truth.kPlus_iff] at hcon
  obtain ⟨r, hr0, _, hr⟩ := hcon (sg 1) (sg_pos 1)
  rw [Truth.and_iff] at hr
  obtain ⟨hkp, _⟩ := hr
  rw [Truth.kPlus_iff] at hkp
  obtain ⟨s', hrs', hgap'⟩ := L3 r hr0
  obtain ⟨u, hru, hus, hu⟩ := hkp s' hrs'
  exact hgap' u hru hus ((translation_realizes sepOrder AA a u).mp hu)

theorem not_validIn_dense_sep (a : Atom) : ¬ ValidIn FrameClass.Dense (/- same formula -/ _) :=
  fun h => not_validOn_sep a (h _ ⟨inferInstance, inferInstance⟩)

theorem not_validIn_base_sep (a : Atom) : ¬ ValidIn FrameClass.Base (/- same formula -/ _) :=
  fun h => not_validOn_sep a (h _ inferInstance)

theorem sep_minFrameClass_sharp (a : Atom) {fc : FrameClass} (hfc : fc < FrameClass.RTime) :
    ¬ ValidIn fc (/- same formula -/ _) := by
  rcases Metalogic.Independence.base_or_dense_of_lt_rtime hfc with rfl | rfl
  · exact not_validIn_base_sep a
  · exact not_validIn_dense_sep a

/-- Shape pin: the formula refuted above is exactly `Axiom.sep`'s. -/
example (φ : Formula) : Axiom ((Formula.and (Formula.kPlus φ)
    (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
    (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := Axiom.sep φ
```

(The three `/- same formula -/ _` placeholders stand for the fully written-out formula, identical
to `not_validOn_sep`'s; they are elided here only to keep the block readable. In the verified run
they were written out in full.)

### The `.ZTime` row of `sep` is positive, and closes the characterization

Separately verified, sorry-free, same axiom set:

```lean
theorem isLeastPos_of_succOrder (F : TaskFrame) (so : SuccOrder F.Duration) :
    IsLeast {x : F.Duration | 0 < x} (Order.succ 0) :=
  ⟨Order.lt_succ (0 : F.Duration), fun _ hx => Order.succ_le_of_lt hx⟩

theorem sep_validIn_ztime (φ : Formula) :
    ValidIn FrameClass.ZTime ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := by
  intro F hF
  obtain ⟨-, so, -, -⟩ := hF
  exact sep_validOn_of_isLeastPos (isLeastPos_of_succOrder F so) φ
```

`NoMaxOrder F.Duration` is found by instance search, so `Order.lt_succ` needs no side condition.
Note this is **schematic in `φ`** — unusually, since it is a validity claim, not a non-validity
claim, the `∀ φ` form is sound here.

With all four classes settled the exhaustive statement is available:

```lean
theorem sep_validIn_iff (a : Atom) (fc : FrameClass) :
    ValidIn fc (…sep at atom a…) ↔ (fc = FrameClass.ZTime ∨ FrameClass.RTime ≤ fc)
```

by `cases fc`: `.Base` and `.Dense` by the two refutations, `.ZTime` by `sep_validIn_ztime`,
`.RTime` by `sep_valid` (`Metalogic/Soundness.lean`, which is `ValidRTime`, i.e.
`ValidIn FrameClass.RTime`, definitionally).

**Do not state `ValidIn fc φ ↔ .RTime ≤ fc`.** It is false: `.RTime ≰ .ZTime`, yet `sep` is
`.ZTime`-valid. This is the concrete answer to the dispatch's "consider whether `.ZTime` is
reachable" question — it is reachable, but as a *positive* result, and it makes `sep`'s row
shape differ from `prior_U_gap`'s (which deliberately claims nothing at `.ZTime`, and correctly
so: `prior_U_gap` is refuted on the clock frame, which is `ℚ`-carried, and no analogous
`.ZTime` validity was established for it here).

### Recommendations

1. **Land a new module `FormalSystem/Metalogic/Independence/SepSharpness.lean`** rather than
   extending `DenseRTimeSharpness.lean`. Rationale: the latter is already 400 lines; the new
   carrier brings ~90 lines of `Finsupp.Lex` order machinery that has nothing to do with the
   `.Dense` rows; and the build-cost note in the dispatch is satisfied either way (a new
   Independence module does not force a full-tree rebuild). Import surface:
   `FormalSystem.Metalogic.Independence.DenseRTimeSharpness` (for `base_or_dense_of_lt_rtime` and
   `sep_validOn_of_isLeastPos`) plus `Mathlib.Data.Finsupp.Lex`. Expected size with this
   repository's docstring density: 380–460 lines.
2. **Declare `DenselyOrdered (Lex (ℚ →₀ ℚ))` locally in that module.** It is a concrete,
   diamond-free instance at one closed type. A generalised
   `[LinearOrder α] [AddCommGroup N] [LinearOrder N] [DenselyOrdered N] →
   DenselyOrdered (Lex (α →₀ N))` (which holds — replace the midpoint `(y i - x i)/2` by
   `exists_between` in `N`, dropping the need for division) would be genuinely Mathlib-shaped and
   could go to `FormalSystem/ForMathlib/Order/`. **Recommended: local for now**, because a new
   `ForMathlib/` file is a recorded C24 exception requiring edits to
   `scripts/CheckInitImportsMain.lean` and `FormalSystem/Init.lean`, which is churn out of
   proportion to a 14-line instance. Record the generalisation in the module docstring as an
   upstreaming candidate.
3. **State exactly four named results plus the characterization**: `not_validOn_sep_lexHahn`,
   `not_validIn_base_sep`, `not_validIn_dense_sep`, `sep_minFrameClass_sharp`, and
   `sep_validIn_ztime` + `sep_validIn_iff`. Add `not_derivable_dense_sep` through
   `soundness_validIn`, matching `not_derivable_dense_prior_U_gap`.
4. **Carry the shape pin.** `example (φ : Formula) : Axiom (…) := Axiom.sep φ`, in a *Shape pins*
   section, exactly as both landed sharpness modules do.
5. **Docstring edits, batched into one full rebuild**: `Axiom.minFrameClass`'s docstring in
   `ProofSystem/Axioms.lean` (replace the "`sep` is the one row still carrying the upper bound
   only" paragraph with the closed row, citing `sep_minFrameClass_sharp` and `sep_validIn_iff`);
   `DenseRTimeSharpness.lean`'s "The `sep` row" section and its *Row 4* section docstring (rewrite
   the three-route survey as "closed, see `SepSharpness.lean`" — do not delete
   `not_kPlus_of_isLeastPos` / `sep_validOn_of_isLeastPos`, which `sep_validIn_ztime` now
   *consumes*); `Metalogic/Independence.lean` and `Independence/README.md` ledgers.
6. **Ledger arithmetic**: both ledgers say "Eleven results are carried here." Adding result 12
   requires changing that word in both files as well as appending the item. Alternatively fold
   the new result into item 11; the cleaner choice is a new item 12, because item 11 is already
   the longest entry and its closing sentence ("`Axiom.sep` is the one row still
   upper-bound-only") becomes false and must be rewritten regardless.
7. **A sorry-free path exists and has been exercised.** No `sorry`, no new axiom, no
   `[BLOCKED]` outcome is warranted for this task.

## Decisions

- **Route 2 selected and verified** (`Lex (ℚ →₀ ℚ)`), not assumed. Route 1 independently
  re-analysed and confirmed dead (and the reason sharpened: one infinitesimal level is never
  enough, and neither is any finite number). Route 3 excluded on cost, not on impossibility.
- **`t = 0`, φ-region `{sg γ : γ > 0}`** as recorded in the dispatch. The `γ > 0` restriction is
  not load-bearing (the unrestricted `{sg γ : γ ∈ ℚ}` works identically); keeping it costs one
  `max i 0` in `L1` and matches the recorded route, so keep it.
- **Failure of `K⁺φ` at every `r > 0`** is the lemma to prove, rather than failure of
  `K⁺φ ∧ K⁻φ`, and rather than failure of `K⁻φ`. Reason: the `K⁻` route needs a three-way case
  split on the leading coefficient of `r` (`> 1`, `= 1`, `< 1`); the `K⁺` route needs only a
  two-way split on `sg i ≤ r` versus `r < sg i`, and the `K⁻` conjunct is then never touched.
  This was derived by working both and is the single largest proof-size saving found.
- **Helper lemmas stated at `DD`, not at `(sepOrder : Type)`.** Forced: `ofLex r j` does not
  elaborate when `r : TemporalOrder.carrier sepOrder`.
- **Frame-level (`¬ F.ValidOn`) form chosen before starting**, per the Independence README's
  criterion. No validation-while-refuting is involved, so the `CoNotPriorU.lean` obstruction does
  not apply.

## Risks & Mitigations

- **Risk: the INV gate fails because a docstring edit grew a file after inventory regeneration.**
  Mitigation: run `bash scripts/check-module-invariants.sh --emit-inventory` **after** the last
  docstring edit, never before. `scripts/readme-inventory.sh` is a pointer script and is not the
  regenerator.
- **Risk: the new README row's description is silently truncated.** The inventory generator splits
  rows on `|`. Keep the `SepSharpness.lean` description **pipe-free** — in particular do not write
  `|p|` or any absolute-value bars, and note that this description will *want* to mention the
  φ-region, so write it as "the region of single-support generators" rather than with set-builder
  bars.
- **Risk: C20 tier 2 failure on README prose.** The tree is at zero `file.lean` line-number
  citations under `FormalSystem/`. Cite declaration names and bare file names only.
- **Risk: growing `ProofSystem/Axioms.lean` shifts live line-number citations elsewhere.**
  Remedy: `scripts/reanchor-lean-citations.py --by-name`.
- **Risk: budget overrun from repeated full rebuilds.** `Axioms.lean` invalidates on whole-file
  hash. Do all verification with `lean_run_code` and a scoped build of
  `FormalSystem.Metalogic.Independence`, then batch every `Axioms.lean` and ledger edit into a
  **single** detached `scripts/lake-build-guard.sh build --timeout 1800 -- build` (note the
  `lake` subcommand after the bare `--`; omitting it exits 77).
- **Risk: overclaiming the characterization.** Mitigated by `sep_validIn_ztime`: the correct form
  is `↔ fc = .ZTime ∨ .RTime ≤ fc`. A reviewer copying `density_validIn_iff`'s shape mechanically
  would write the false statement.
- **Risk: `AddCommGroup (Lex (ℚ →₀ ℚ))` is noncomputable**, so `sepOrder` must be a
  `noncomputable abbrev` (matching `denseSharpOrder` and `ztimeSharpOrder`) and `sg` a
  `noncomputable def`. Forgetting this produces "failed to compile definition, consider marking it
  as 'noncomputable'".
- **Risk: concurrent sibling task 676 shares this working tree** and declares no `file_scope`.
  Re-read any file immediately before editing; stage only this task's own hunks with an explicit
  file list, never a directory or glob `git add`.

## Tactic Survey Results

Tactic candidates were exercised directly against the real goals via `lean_run_code` rather than
against a scratch position, so the table records what actually discharged each obligation.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `0 < z → 0 < (1/2) • z` in `Lex (ℚ →₀ ℚ)` | `exact?` | fail | no `PosSMulStrictMono` instance; abandoned in favour of the explicit `single`-midpoint construction |
| `DenselyOrdered` witness comparisons | `rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_neg …]` then `linarith` | success | explicit `rw` chain required; bare `simp` over-simplified the `<` goal to `False` |
| `sg_apply` normal form | `simp [sg, Finsupp.single_apply]` | success | — |
| index-comparison goals (`sg_pos`, `sg_lt_of_index_lt`, `lt_sg_of_lt_index`) | `simp [ne_of_gt …]` / `simpa [ne_of_gt …] using hi` | success | direction of the `if` condition is `if i = j`, so `ne_of_gt`, not `ne_of_lt` |
| `sg_lt_sg` forward direction | `split at h2 <;> linarith` | success | after `rw [if_neg hne] at h2` |
| `L1` positivity side goal | `positivity` | success | on `0 < max i 0 + 1` |
| `sep_validIn_ztime` | `obtain ⟨-, so, -, -⟩ := hF` then `exact …` | success | `IsZTime` is a nested existential; destructure, do not `haveI` |
| whole-formula manipulation | `rw [Truth.imp_iff]`, `Truth.and_iff`, `Truth.kPlus_iff`, `Truth.neg_iff`, `Truth.untl_iff` | success | the named clause lemmas, never `simp [TruthAt]` |
| `FrameClass` `<` elimination | — | n/a | not needed here; `base_or_dense_of_lt_rtime` already packages it (and `by decide` would fail on `<`) |

`lean_hammer_premise` and `lean_state_search` were not needed: every goal was discharged by a
named lemma identified from the file under edit or from `Mathlib/Data/Finsupp/Lex.lean` read
directly.

## Context Extension Recommendations

- **Topic**: Hahn-group / `Finsupp.Lex` duration carriers.
- **Gap**: `context/project/lean4/` and `FormalSystem/Metalogic/Independence/README.md`'s
  countermodel kit cover the translation-frame route and the `Prod.Lex` carrier
  (`Semantics/LexCarrier.lean`), but nothing records the *infinitely-many-levels* carrier or the
  two elaboration traps found here (helpers must be stated at the bare carrier abbreviation;
  `Finsupp.Lex.single_lt_iff` is value-type-specialised upstream and unusable at `ℚ`).
- **Recommendation**: after landing, add a short subsection to
  `FormalSystem/Metalogic/Independence/README.md`'s countermodel-construction kit titled "When one
  infinitesimal level is not enough", pointing at `SepSharpness.lean` and stating the two traps.
  This is a docstring edit in the same batch as the ledger edits, not a separate task.

## Appendix

### Probes run

All via `lean_run_code` (lean-lsp MCP), Lean v4.33.0-rc1 / Mathlib `79d0395a`:

1. Instance availability at `Lex (ℚ →₀ ℚ)`: `AddCommGroup`, `LinearOrder`, `Nontrivial`,
   `IsOrderedCancelAddMonoid`, `IsOrderedAddMonoid`, `DenselyOrdered`, `Module ℚ`.
2. `DenselyOrdered` instance — proved.
3. `sg_apply`, `sg_pos`, `sg_lt_of_index_lt`, `lt_sg_of_lt_index`, `pos_index`, `sg_lt_sg` —
   proved standalone.
4. `L1`, `L2`, `L3` — proved standalone.
5. `FrameClass.Sat .Base` / `.Dense` for `translationFrame sepOrder` — both discharged by
   `inferInstance` / `⟨inferInstance, inferInstance⟩` under real project imports.
6. Full formula-level `not_validOn_sep` against `sorry`-ed `L1`/`L2`/`L3` — succeeded, isolating
   the wiring from the order theory.
7. Full integration: everything above in one file, plus `not_validIn_base_sep`,
   `not_validIn_dense_sep`, `sep_minFrameClass_sharp`, and the `Axiom.sep` shape pin —
   **succeeded with no diagnostics**; `#print axioms sep_minFrameClass_sharp` returned
   `[propext, Classical.choice, Quot.sound]`.
8. `isLeastPos_of_succOrder` + `sep_validIn_ztime` — succeeded, same axiom set.

### Files read

- `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` (full)
- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` (structure + the `.Base`/`.Dense`
  instantiation sections)
- `FormalSystem/Metalogic/Independence/README.md` (full, including the countermodel kit and the
  frame-versus-model criterion)
- `FormalSystem/Metalogic/Independence.lean` (ledger)
- `FormalSystem/Metalogic/Independence/LexIntWitness.lean` (carrier precedent)
- `FormalSystem/ProofSystem/Axioms.lean` (`Axiom.sep`, `Axiom.minFrameClass` and its docstring)
- `FormalSystem/Semantics/Truth.lean` (`TruthAt`, `untl_iff`, `kPlus_iff`, `kMinus_iff`)
- `FormalSystem/Semantics/TemporalOrder.lean`, `FormalSystem/Semantics/FrameProperty.lean`,
  `FormalSystem/Semantics/FrameClassValidity.lean`
- `FormalSystem/Semantics/Frames/Standard.lean`,
  `FormalSystem/Semantics/Correspondence/DurationFrames.lean`
- `FormalSystem/Semantics/LexCarrier.lean` (header), `FormalSystem/ForMathlib/README.md`
- `FormalSystem/Metalogic/Soundness.lean` (`sep_valid`), `FormalSystem/Semantics/Validity.lean`
  (`ValidRTime`)
- `.lake/packages/mathlib/Mathlib/Data/Finsupp/Lex.lean` (full instance and lemma inventory)
- `scripts/check-module-invariants.sh` (`--emit-inventory` semantics, C20/C24 notes)
