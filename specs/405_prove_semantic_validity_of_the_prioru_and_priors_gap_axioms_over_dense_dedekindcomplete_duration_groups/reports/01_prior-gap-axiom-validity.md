# Research Report: Semantic Validity of the Prior-U / Prior-S Gap Axioms

**Task**: 405 — prove semantic validity of the Prior-U and Prior-S gap axioms over dense
Dedekind-complete duration groups
**Date**: 2026-07-27
**Type**: lean4
**Status**: RESEARCHED — both proofs found, compiled, and verified sorry-free against the real
tree; full `lake build` green.

---

## 1. Executive Summary

Both target sorries are dischargeable **now**, with short direct proofs. This is not a
"recommended approach" report: the two proofs below were written, patched into
`FormalSystem/Metalogic/Soundness.lean`, and compiled. `lake build` completed successfully
(1892 jobs), and the `declaration uses 'sorry'` warning count in `Soundness.lean` dropped from
4 to 2 — the exact drop of 2 that the DONE-WHEN criterion requires. The working tree was then
reverted; the verified proof text is reproduced verbatim in section 6 and archived at
`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/51024596-e6d9-4261-a34c-cf493ee4da52/scratchpad/Soundness.lean.proved`.

Key findings:

1. The argument is a **single supremum construction** over the set of right endpoints of
   φ-intervals starting at `t` (and its infimum dual for the past). It closes in ~25 tactic
   lines each. There is no open-ended search.
2. Only **one** new helper is needed: `exists_isGLB_of_lub`, deriving greatest lower bounds
   from the binder set's least-upper-bound hypothesis via Mathlib's `isLUB_lowerBounds`.
3. The proofs use **no** `DenselyOrdered`, `Nontrivial`, `AddCommGroup`, `IsOrderedAddMonoid`,
   or `ShiftClosed` hypothesis. Nonetheless the lemmas must stay stated at
   `ValidDedekindDense` — see section 5.
4. The edit footprint is **confined to lines 1458–1472** of `Soundness.lean` plus one inserted
   private helper. It does not touch `sep_valid` (:1482) or `sep_swap_valid` (:1505), so it is
   compatible with task 406 operating on the same file.
5. No new axioms, no `sorry`, no vacuous definitions. `#print axioms` on both lemmas returns
   `[propext, Classical.choice, Quot.sound]`.

---

## 2. Literature Proof Structure

**Source**: Reynolds, "An Axiomatization for Until and Since over the Reals without the IRR
Rule", §1, printed p.168.
Local file: `/home/benjamin/Projects/Literature/sources/reynolds_1992/sec01_an-axiomatization-for-until-and-since-ov.md`
(read verbatim; provenance_fidelity: verified_conversion).

**Strategy**: Reynolds gives **no proof**. Line 120: *"It is clear that all these axioms are
valid over the reals."* Line 122 supplies the only substantive hint: *"In this paper we identify
gaps in a structure with supremum-less non-empty proper initial segments of the flow... The
axioms are valid in structures over the reals because there are no gaps at all so no definable
ones."*

That sentence **is** the proof sketch, and it dictates the construction: the relevant initial
segment is the φ-region immediately to the right of `t`, and Dedekind completeness supplies its
supremum, which is then shown to be the required Until-witness.

### Verbatim axiom statements (source lines 114, 116)

```
Prior-U:  U(⊤, p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)
Prior-S:  S(⊤, p) ∧ P¬p → S(¬p ∨ K⁻(¬p), p)
```

### Verbatim abbreviation table (source lines 74–79)

| Abbreviation | Definition | Reading |
|---|---|---|
| `FA` | `U(A, ⊤)` | A will be true |
| `PA` | `S(A, ⊤)` | A was true |
| `GA` | `¬F¬A` | A will always be true |
| `HA` | `¬P¬A` | A was always true |
| `K⁺A` | `¬U(⊤, ¬A)` | A will be true arbitrarily soon |
| `K⁻A` | `¬S(⊤, ¬A)` | A was true arbitrarily recently |

### Source-to-tree encoding check (5-column mapping)

| Source item | Source loc | Tree symbol | Tree loc | Match |
|---|---|---|---|---|
| `U(A,B)` = ∃s>t, A(s) ∧ ∀u∈(t,s), B(u) | lines 58–61 | `TruthAt … (Formula.untl φ ψ)` | `Semantics/Truth.lean:134` | exact |
| `S(A,B)` = ∃s<t, A(s) ∧ ∀u∈(s,t), B(u) | lines 62–65 | `TruthAt … (Formula.snce φ ψ)` | `Semantics/Truth.lean:136` | exact |
| `FA = U(A,⊤)` | line 74 | `Formula.someFuture φ := untl φ top` | `Syntax/Formula.lean:131` | exact |
| `PA = S(A,⊤)` | line 75 | `Formula.somePast φ := snce φ top` | `Syntax/Formula.lean:141` | exact |
| `K⁺A = ¬U(⊤,¬A)` | line 78 | `Formula.kPlus φ := (untl top φ.neg).neg` | `Syntax/Formula.lean:180` | exact |
| `K⁻A = ¬S(⊤,¬A)` | line 79 | `Formula.kMinus φ := (snce top φ.neg).neg` | `Syntax/Formula.lean:193` | exact |
| Prior-U axiom | line 114 | `prior_U_gap_valid` statement | `Soundness.lean:1458-1460` | exact |
| Prior-S axiom | line 116 | `prior_S_gap_valid` statement | `Soundness.lean:1469-1471` | exact |

All eight encodings agree. The existing lemma statements are faithful transcriptions and need
**no** restatement.

### Step map (the argument Reynolds elides)

Fix a model, a history `τ`, and a time `t`. Write `p(r)` for `TruthAt M Ω τ r φ`.

1. Unfold `U(⊤,p)` at `t`: there is `s₀ > t` with `p` on the open interval `(t, s₀)`.
   The `⊤` conjunct is discharged trivially.
2. Unfold `F¬p` at `t`: there is `v > t` with `¬p(v)`.
3. Define the **φ-region right endpoints**
   `A := { u | t < u ∧ ∀ r, t < r < u → p(r) }`.
   This is Reynolds' "non-empty proper initial segment", relativised to `t`.
4. `A` is nonempty: `s₀ ∈ A` by step 1.
5. `A` is bounded above by `v`: if `u ∈ A` and `v < u` then `v ∈ (t,u)`, so `p(v)`,
   contradicting step 2.
6. Apply the binder set's LUB hypothesis: obtain `s` with `IsLUB A s`.
   *(This is the only use of Dedekind completeness. It is exactly the "no gaps" appeal.)*
7. `t < s`, since `s₀ ≤ s` (upper-bound half of `IsLUB`) and `t < s₀`.
8. **Guard clause**: `p` holds on `(t, s)`. Given `t < r < s`, `r` is not an upper bound of `A`,
   so `IsLUB.exists_between` yields `u ∈ A` with `r < u`; then `r ∈ (t,u)` gives `p(r)`.
9. **Endpoint clause**: `¬p(s) ∨ K⁺(¬p)(s)`. Argue by contradiction. Assume `¬¬p(s)`
   (hence `p(s)` classically) and `¬K⁺(¬p)(s)`. The latter unfolds to `U(⊤, ¬¬p)` at `s`:
   there is `w > s` with `¬¬p` on `(s, w)`.
10. Then `w ∈ A`: for `r ∈ (t, w)`, trichotomy on `r` vs `s` gives `p(r)` from step 8
    (`r < s`), from step 9 (`r = s`), or from step 9's interval (`s < r`).
11. `w ∈ A` forces `w ≤ s` by the upper-bound half of `IsLUB`, contradicting `s < w`. ∎
12. Steps 1–11 dualise: replace `A` by `B := { u | u < t ∧ ∀ r, u < r < t → p(r) }`,
    `IsLUB` by `IsGLB`, and reverse every inequality.

**Dependencies**: step 8 depends on 6–7; step 10 depends on 8 and 9; step 11 depends on 6
and 10. Step 12 depends on the whole of 1–11 plus the GLB helper (section 4).

**Formalization challenges (all resolved)**:
- *Step 9's double negation*: `¬K⁺(¬p)` unfolds to a `¬¬p` guard, not a `p` guard, because
  `kPlus` and `neg` each insert an `imp bot`. Resolved by `Classical.byContradiction` — the
  tree is already classical (`and_of_not_imp_not` at `Soundness.lean:105` uses it).
- *Step 12's GLB*: the `ValidDedekindDense` binder set supplies **only** a least-upper-bound
  hypothesis. Resolved by the derived helper in section 4.
- *Conjunction/disjunction encoding*: `Formula.and`/`Formula.or` are `imp`/`neg` sugar with no
  `Truth.and_iff`/`Truth.or_iff` characterisation lemmas in the tree. Resolved by
  `simp only [TruthAt, Formula.and, Formula.or, Formula.neg, …]` plus the pre-existing
  `and_of_not_imp_not`.

---

## 3. The TRAP, checked

The task description warns against confusing these with `prior_UZ` / `prior_SZ` at
`FormalSystem/ProofSystem/Axioms.lean:315,:320`. Confirmed distinct and **not touched**:

| | Prior-U/S gap (this task) | Prior-UZ/SZ (not this task) |
|---|---|---|
| Statement | `U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺¬p, p)` | `F(φ) → U(φ, ¬φ)` |
| `minFrameClass` | `.Dedekind` | `.Discrete` |
| Validity predicate | `ValidDedekindDense` | `ValidDiscrete` |
| Already proved? | no (this task) | yes, via `derivable_implies_swap_valid_discrete` |
| Frame relation | `Discrete ≰ Dedekind` — mutually eliminated by `absurd h_fc` at `Soundness.lean:1573-1575, 1604-1606` | same |

The two families never interact: the `.Dedekind` dispatcher explicitly discharges the
`prior_UZ`/`prior_SZ` arms as absurd.

---

## 4. Mathlib findings

| Need | Mathlib lemma | Signature | Verified |
|---|---|---|---|
| "below the sup, find a member" | `IsLUB.exists_between` | `IsLUB s a → b < a → ∃ c ∈ s, b < c ∧ c ≤ a` (`Mathlib.Order.Bounds.Basic`) | loogle + compiled |
| dual of the above | `IsGLB.exists_between` | dual form, same module | compiled |
| GLB from LUB-of-lowerBounds | `isLUB_lowerBounds` | `IsLUB (lowerBounds s) a ↔ IsGLB s a` | `exact?` + compiled |

**Not found and not needed**: there is no Mathlib `IsLUB.neg` / `IsGLB.neg` order-antitone
bridge reachable by the searches run, so the negation route (`D` is an ordered additive group,
so `x ↦ -x` reverses order) was **not** used. The `isLUB_lowerBounds` route is shorter and
avoids any `AddCommGroup` dependency.

The GLB helper, compiled and sorry-free (`#print axioms` → `[propext]`):

```lean
private theorem exists_isGLB_of_lub {D : Type} [LinearOrder D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    {B : Set D} (hne : B.Nonempty) (hbdd : BddBelow B) : ∃ x, IsGLB B x := by
  obtain ⟨a, ha⟩ := hne
  obtain ⟨x, hx⟩ := h_lub (lowerBounds B) hbdd ⟨a, fun _ hb => hb ha⟩
  exact ⟨x, isLUB_lowerBounds.mp hx⟩
```

Note that `BddBelow B` is definitionally `(lowerBounds B).Nonempty`, so it is passed straight
through as the nonemptiness argument; and any `a ∈ B` is an upper bound of `lowerBounds B`.

---

## 5. Binder-set decision: keep `ValidDedekindDense` (SETTLED, do not revisit)

The proofs consume only the `h_lub` hypothesis and `LinearOrder D`. They therefore also prove
the *stronger* `ValidDedekind` statement. **Do not restate them that way.** Reasons, in order
of force:

1. The task description names `ValidDedekindDense` as the REQUIRED binder set and records the
   choice as settled by task 391.
2. The call sites demand it: `axiom_dedekind_valid` (`Soundness.lean:1577-1578`) and
   `axiom_dedekind_swap_valid` (`:1597-1599`) both expect `ValidDedekindDense`. Restating at
   `ValidDedekind` would force four extra `validDedekindDense_of_validDedekind` hops
   (`Semantics/Validity.lean:303`) for zero gain.
3. `soundness_dedekind` must target `ValidDedekindDense` because `Dense ≤ Dedekind` makes
   `Axiom.density` and `Axiom.dense_indicator` admissible in a `.Dedekind` derivation, and both
   are false on `ℤ`, which satisfies every `ValidDedekind` binder. This is documented at
   `Semantics/Validity.lean:209-224` and `Soundness.lean:1418-1425`.

The correct reading of "density is unused" is **informational**, not actionable: it records that
the Prior gap axioms are valid on *every* Dedekind-complete linear order (including `ℤ`, where
they hold vacuously-ish because `U(⊤,p)` is trivially true and the least `¬p` point serves as
witness), and that the `DenselyOrdered` binder is present for chain consistency, not
mathematical necessity. Capture this as a docstring note; do not act on it.

---

## 6. Verified implementation

Both bodies below were compiled inside `FormalSystem/Metalogic/Soundness.lean` (namespace
`FormalSystem.Metalogic`, with `open FormalSystem.Syntax / ProofSystem / Semantics` already in
scope at line 99-101). They reuse the pre-existing private helper `and_of_not_imp_not`
(`Soundness.lean:105`) — no new classical helper is required.

### 6.1 Placement

Insert `exists_isGLB_of_lub` as a `private theorem` immediately **above** `prior_U_gap_valid`
(i.e. after the section comment ending at line 1447), then replace the two `sorry`s.

**Why this placement and not a new file**: the FILE-SCOPE WARNING for task 406 applies. This
placement keeps every edit inside the contiguous region lines 1448–1472, which is ~10 lines
clear of `sep_valid` (:1482) and ~35 clear of `sep_swap_valid` (:1505). It adds no import line,
no new module, and no change to the build graph — so task 406's diff and this one land as
disjoint hunks. A new `SoundnessLemmas/*.lean` file would also work but would touch the import
block at line 9 and change the build graph for no benefit.

### 6.2 `prior_U_gap_valid`

```lean
theorem prior_U_gap_valid (φ : Formula) :
    ValidDedekindDense ((Formula.and (Formula.untl Formula.top φ) φ.neg.someFuture).imp
      (Formula.untl (Formula.or φ.neg (Formula.kPlus φ.neg)) φ)) := by
  intro D _ _ _ _ _ h_lub F M Omega h_sc τ h_mem t h_ant
  simp only [TruthAt, Formula.and, Formula.neg, Formula.someFuture, Formula.top] at h_ant
  obtain ⟨h1, h2⟩ := and_of_not_imp_not h_ant
  obtain ⟨s0, hts0, -, hp0⟩ := h1
  obtain ⟨v, htv, hnpv, -⟩ := h2
  set A : Set D := {u : D | t < u ∧ ∀ r : D, t < r → r < u → TruthAt M Omega τ r φ} with hA
  have hs0A : s0 ∈ A := ⟨hts0, hp0⟩
  have hAbdd : BddAbove A := by
    refine ⟨v, ?_⟩
    intro u hu
    by_contra hvu
    exact hnpv (hu.2 v htv (lt_of_not_ge hvu))
  obtain ⟨s, hs⟩ := h_lub A ⟨s0, hs0A⟩ hAbdd
  have hts : t < s := lt_of_lt_of_le hts0 (hs.1 hs0A)
  have hguard : ∀ r : D, t < r → r < s → TruthAt M Omega τ r φ := by
    intro r htr hrs
    obtain ⟨u, huA, hru, -⟩ := hs.exists_between hrs
    exact huA.2 r htr hru
  simp only [TruthAt, Formula.or, Formula.neg, Formula.kPlus, Formula.top]
  refine ⟨s, hts, ?_, hguard⟩
  intro hnn
  rintro ⟨w, hsw, -, hw⟩
  have hps : TruthAt M Omega τ s φ := Classical.byContradiction hnn
  have hwA : w ∈ A := by
    refine ⟨lt_trans hts hsw, ?_⟩
    intro r htr hrw
    rcases lt_trichotomy r s with h | h | h
    · exact hguard r htr h
    · exact h ▸ hps
    · exact Classical.byContradiction (hw r h hrw)
  exact absurd (hs.1 hwA) (not_le_of_gt hsw)
```

Line-by-line correspondence to the step map: `obtain h1/h2` = steps 1–2; `set A` = step 3;
`hs0A` = step 4; `hAbdd` = step 5; `obtain ⟨s, hs⟩` = step 6; `hts` = step 7; `hguard` =
step 8; the final block = steps 9–11.

### 6.3 `prior_S_gap_valid`

```lean
theorem prior_S_gap_valid (φ : Formula) :
    ValidDedekindDense ((Formula.and (Formula.snce Formula.top φ) φ.neg.somePast).imp
      (Formula.snce (Formula.or φ.neg (Formula.kMinus φ.neg)) φ)) := by
  intro D _ _ _ _ _ h_lub F M Omega h_sc τ h_mem t h_ant
  simp only [TruthAt, Formula.and, Formula.neg, Formula.somePast, Formula.top] at h_ant
  obtain ⟨h1, h2⟩ := and_of_not_imp_not h_ant
  obtain ⟨s0, hs0t, -, hp0⟩ := h1
  obtain ⟨v, hvt, hnpv, -⟩ := h2
  set B : Set D := {u : D | u < t ∧ ∀ r : D, u < r → r < t → TruthAt M Omega τ r φ} with hB
  have hs0B : s0 ∈ B := ⟨hs0t, hp0⟩
  have hBbdd : BddBelow B := by
    refine ⟨v, ?_⟩
    intro u hu
    by_contra huv
    exact hnpv (hu.2 v (lt_of_not_ge huv) hvt)
  obtain ⟨s, hs⟩ := exists_isGLB_of_lub h_lub ⟨s0, hs0B⟩ hBbdd
  have hst : s < t := lt_of_le_of_lt (hs.1 hs0B) hs0t
  have hguard : ∀ r : D, s < r → r < t → TruthAt M Omega τ r φ := by
    intro r hsr hrt
    obtain ⟨u, huB, -, hur⟩ := hs.exists_between hsr
    exact huB.2 r hur hrt
  simp only [TruthAt, Formula.or, Formula.neg, Formula.kMinus, Formula.top]
  refine ⟨s, hst, ?_, hguard⟩
  intro hnn
  rintro ⟨w, hws, -, hw⟩
  have hps : TruthAt M Omega τ s φ := Classical.byContradiction hnn
  have hwB : w ∈ B := by
    refine ⟨lt_trans hws hst, ?_⟩
    intro r hwr hrt
    rcases lt_trichotomy r s with h | h | h
    · exact Classical.byContradiction (hw r hwr h)
    · exact h ▸ hps
    · exact hguard r h hrt
  exact absurd (hs.1 hwB) (not_le_of_gt hws)
```

Note the deliberate ordering asymmetry against 6.2: in the past case the trichotomy branches
run `r < s` → `hw` (the `K⁻` interval is now to the *left*), `r = s`, `s < r` → `hguard`.

### 6.4 Not needed

- **No** temporal-duality transfer. The tree has no generic time-reversal semantic lemma —
  `SoundnessLemmas/Core.lean:70` only gives `swapTemporal ∘ swapTemporal = id` on truth, and
  `DenseValidity.lean` proves its nine `swap_axiom_*_valid` lemmas individually. Proving
  Prior-S directly matches that established convention and is cheaper than building the
  transfer.
- **No** change to `axiom_dedekind_valid` or `axiom_dedekind_swap_valid`: both already
  reference these two lemmas by name (`:1577-1578`, `:1597-1599`), and
  `axiom_dedekind_swap_valid` already exploits the `rfl`-level fact that
  `(prior_U_gap ψ).swapTemporal` is `prior_S_gap ψ.swapTemporal`.
- **No** new `Truth.and_iff` / `Truth.or_iff` characterisation lemmas. Adding them would be a
  broad refactor of `Semantics/Truth.lean` affecting every soundness lemma, which is out of
  scope and against the file-scope constraint.

---

## 7. Verification evidence

| Check | Command | Result |
|---|---|---|
| Prior-U isolated | `lake env lean …/PriorTest.lean` | clean (one cosmetic `intro`-merge hint) |
| Prior-S isolated | `lake env lean …/PriorSTest.lean` | clean, no output |
| Prior-U axioms | `#print axioms` | `[propext, Classical.choice, Quot.sound]` |
| Prior-S axioms | `#print axioms` | `[propext, Classical.choice, Quot.sound]` |
| GLB helper axioms | `#print axioms` | `[propext]` |
| Module build (patched) | `lake build FormalSystem.Metalogic.Soundness` | `Build completed successfully (726 jobs)` |
| Full build (patched) | `lake build` | `Build completed successfully (1892 jobs)` |
| Sorry count (baseline) | `lake build` warning count | 5 (`Soundness.lean` ×4, `WeakCanonical/Transfer.lean` ×1) |
| Sorry count (patched) | `lake build` warning count | 3 (`Soundness.lean` ×2 = `sep_valid` :1549, `sep_swap_valid` :1572; `Transfer.lean` ×1) |
| **Net drop** | — | **exactly 2** ✅ DONE-WHEN satisfied |

The working tree was reverted after verification; `git status --porcelain` shows no
modification to `FormalSystem/Metalogic/Soundness.lean`.

---

## 8. Tactic survey results

`lean_multi_attempt` sweeps were not needed — the goals are existential constructions over an
abstract `LinearOrder`, on which no closing automation is applicable. Recorded for completeness:

| Goal | Tactic class | Applicability |
|---|---|---|
| `TruthAt … (Prior-U axiom)` | `simp` / `aesop` / `omega` / `decide` | not applicable — goal is an ∃ over an abstract order with a model-relative predicate; no decidable structure and no relevant simp set |
| `IsLUB (lowerBounds B) a → IsGLB B a` | `exact?` | **succeeded**: `isLUB_lowerBounds.mp` |
| `IsLUB s a → b < a → ∃ c ∈ s, b < c` | `loogle` type pattern | **succeeded**: `IsLUB.exists_between` |
| unfolding `Formula.and`/`or`/`kPlus` | `simp only [TruthAt, Formula.*]` | **succeeded** — definitional unfolding only, no search |

The productive tools here were `exact?` and `loogle`, not proof search. The proof structure came
from the literature (section 2), per literature-fidelity policy.

---

## 9. Risks and scope notes

| Risk | Severity | Mitigation |
|---|---|---|
| Merge conflict with task 406 in `Soundness.lean` | low | Edits confined to lines 1448–1472; task 406 edits :1482 and :1505. Disjoint hunks. If 406 lands first, line numbers shift but the anchor text (`theorem prior_U_gap_valid`) is unique. |
| Docstring `-- sorry:` comment blocks left stale | medium | The `-- sorry: assumes …; follow-up: task 405.` blocks at :1452-1457 and :1465-1468 MUST be removed/rewritten when the sorries go, or the tree will claim debt that no longer exists. |
| Section comment at :1435-1447 says "Four lemmas … the ONLY debt" | medium | Must be updated to "two lemmas" once these land. Coordinate wording with task 406, which will empty it entirely. |
| Temptation to restate at `ValidDedekind` | low | Explicitly forbidden — see section 5. |
| `set … with hA` unused-variable lint | cosmetic | `hA`/`hB` are unused; either drop `with hA` or prefix `_`. Did not warn in the compiled run. |

**Out of scope, confirmed**: completeness (the rational-flowed Prior/Sep model, Reynolds
Theorems 4/5 = D1/D2, the Doets real-flow transfer, `completeness_dedekind`) — per
`specs/390_dedekind_carrier_construction_research/reports/01_dedekind-carrier-construction.md`
phases 6–9. Nothing in this report advances or depends on it.

**Also out of scope**: `sep_valid` / `sep_swap_valid` (task 406). Reynolds himself defers Sep to
his §7 lemma 10 (source line 124), so it is genuinely separate work with a different proof
technique (separability of ℝ).

---

## 10. Recommended plan shape

A single-phase plan suffices. Suggested decomposition:

**Phase 1** — Discharge both Prior gap sorries (single agent run, ~60 lines of output):
1. Insert `private theorem exists_isGLB_of_lub` above `prior_U_gap_valid`.
2. Replace the `sorry` at `Soundness.lean:1461` with the body in section 6.2.
3. Replace the `sorry` at `Soundness.lean:1472` with the body in section 6.3.
4. Rewrite the two `-- sorry: …` docstring blocks into proof-summary prose citing Reynolds
   1992 p.168 and the supremum/infimum construction.
5. Update the section comment at :1435-1447 from "Four lemmas for three axioms" to reflect two
   remaining.
6. Verify: `lake build`, then confirm the `Soundness.lean` sorry-warning count is exactly 2.

No blockers. No decomposition beyond one phase is warranted — the proofs are already verified.

---

## 11. References

- Reynolds 1992, §1, printed p.168 —
  `/home/benjamin/Projects/Literature/sources/reynolds_1992/sec01_an-axiomatization-for-until-and-since-ov.md`
  lines 58–65 (semantics), 74–79 (abbreviations), 114/116 (Prior-U/S), 120/122 (validity
  assertion and the gap/supremum gloss), 124 (Sep deferral).
- `FormalSystem/Metalogic/Soundness.lean:1435-1509` — the four strategic sorries and their
  section comment.
- `FormalSystem/Semantics/Validity.lean:231-262` — `ValidDedekind` / `ValidDedekindDense` and
  the settled-binder rationale.
- `FormalSystem/Semantics/Truth.lean:128-137` — `TruthAt` clauses for `untl` / `snce`.
- `FormalSystem/Syntax/Formula.lean:118-193, 433-438` — `top`, `neg`, `someFuture`, `somePast`,
  `kPlus`, `kMinus`, `and`, `or`.
- `FormalSystem/ProofSystem/Axioms.lean:315,:320` — `prior_UZ` / `prior_SZ` (the TRAP; distinct).
- `specs/391_frameclass_dedekind_scaffolding/summaries/01_frameclass-dedekind-scaffolding-summary.md`
  — origin of the four strategic sorries and the `rfl`-level swap fact.
- Mathlib `Mathlib.Order.Bounds.Basic` — `IsLUB.exists_between`, `IsGLB.exists_between`,
  `isLUB_lowerBounds`.
