# Truth-Layer Simp Normal Form — Research Report

**Task**: 521 — give `TruthAt` the `@[simp]` API its `BLTruthAt` mirror already has, and register a
named truth-level simp set.
**Scope**: READ-ONLY research dispatch. No source file modified; no `lake build` started.
**Method**: every claim below is either (a) re-measured against the working tree at commit
`2bd4dfba2`, or (b) verified by compiling a probe against the existing oleans via
`lean_run_code`. Claims that are reasoned rather than executed are marked **[reasoned]**.

---

## 1. Verdict

The change is sound and the design question has a clean answer. I built the proposed lemma set and
**compiled it**; it is confluent and terminating, and the three highest-risk sub-claims (A-17's two
lemmas, the ~50% proof-length reduction, the drop-in status of `Truth.imp_iff`) all check out
empirically.

Three defects in the charter must be fixed before planning:

1. **Step (1) asks for two `@[simp]` `always` forms. That is non-confluent and I reproduced the
   failure.** Only one may carry the attribute.
2. **The ≥80% acceptance gate contradicts the step-(6) scope statement.** The named proofs cover
   20 of Soundness.lean's 67 eligible sites — a 30% ceiling. 80% requires the sweep the charter
   explicitly defers.
3. **`@[simp]` tagging alone buys nothing at any existing site.** 199 of the ~209 sites are
   `simp only [...]`, which ignore the attribute entirely. Verified below.

Point 3 is the one that most changes how the work should be planned: this task is not really an
*attribute* change, it is a *call-site rewrite* that an attribute makes possible.

---

## 2. Re-measurement against the current tree

Every figure in the charter was taken 2026-09-01. Task 519 (`2bd4dfba2`) landed since.

| Charter claim | Measured now | Status |
|---|---|---|
| `279` `simp only [...TruthAt...]` live | **199** | **-29%.** 519 deleted `DenseValidity.lean` + `Core.lean`. |
| `229` in "core scope" | **199** live / 210 incl. Boneyard | Charter's live-vs-core split no longer reconstructible; use 199. |
| `144` simp lists naming `Formula.neg` | **270** | **Charter undercounted by ~2x.** |
| `51` simp lists naming `Formula.and` | **54** | Close. |
| `85` `by_contra` | **837** repo-wide | Charter's 85 was presumably scoped to a subset it did not name. |
| `~60` hand-rolled `exact h_conj (fun …)` | **63** | Confirmed. |
| four private `truth_and_iff` copies | **three + one variant** | See §2.1. |
| `and_of_not_imp_not` in 3 places | **confirmed** (Soundness:153, CoValidity:60, Decidable:2570 as `…'`) | 519 left these for this task, as stated. |
| nine `Formula.swap_temporal_*` lemmas | **eleven** (4 already `@[simp]`) | Charter undercounted. |
| `strong_release_iff`/`strong_trigger_iff` have zero uses | **confirmed** — zero references repo-wide | But see §3.4: recommend keeping them. |
| 8-site `rw [show tau.val = … from rfl, …]` at DurationFrames:409-531 | **8 sites, at 385-534** | Count exact, range shifted. |
| `Truth.imp_iff` is a drop-in at `DenseValidity.lean:302` | **file deleted — anchor void** | **Re-established live**; see §4.3. |

### 2.1 The `truth_and_iff` copies

Three genuine biconditional copies, not four:

- `Semantics/Correspondence/DurationFrames.lean:298` — `truth_and_iff` (public)
- `Metalogic/DedekindNonCompactness.lean:158` — `truth_and_iff'`, with the docstring at :155 that
  explicitly chooses duplication over widening imports
- `Metalogic/Independence/CoNotPriorU.lean:180` — `truth_and_iff`

The claimed fourth at `Decidability/Verified/Decidable.lean:1408` is **not** a `truth_and_iff`. It
is `truthAt_and`, a one-directional *introduction* lemma (`hφ → hψ → TruthAt (φ.and ψ)`). It is
still consolidatable — `truthAt_and hφ hψ` becomes `(Truth.and_iff _ _).mpr ⟨hφ, hψ⟩` — but the
plan must name it correctly or the edit will not be found.

A fourth biconditional does exist, out of scope:
`WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracket.lean:77` `temporal_truth_and_iff`. It is
stated for a *different* truth relation (monadic-signature temporal models, not `TruthAt`) and
**must not** be folded in.

### 2.2 Soundness.lean line numbers are NOT void

The dispatch warned that every `Soundness.lean` line number is stale. Measured: they are almost
all still exact. `linear_until_valid` :715 → **715**. `linear_since_valid` :752 → **752**.
`temp_linearity_valid` :347 → **347**. The uniformity block "825-912" → **825-910**. The proof
comment cited at :779 is **at 779**. Drift elsewhere is ≤5 lines (`temp_l_valid` 293→297,
`enrichment_*` 610/632→605/625, `absorb_*` 673/692→668/690, `discreteness_forward` 472→473).
Only the `DenseValidity.lean` anchor is genuinely void.

### 2.3 Prerequisites and territory

- **Task 518: confirmed done.** `Automation/NormalizationAttr.lean` now declares `formula_unfold`
  and `formula_fold` as named `register_simp_attr` sets, and its docstring records the recursion
  blow-up that motivated pulling them out of the default set. No fold/unfold lemma is `@[simp]`.
  The precondition for this task is met.
- **No foreign modifications in my file scope.** Task 520's in-flight edits are confined to
  `Metalogic/Bundle/`, `Metalogic/Core/RestrictedMCS/`, `Syntax.lean`,
  `Syntax/SubformulaClosure/`, and `scripts/module-invariants-manifest.txt` — disjoint from the
  eight scoped files.

---

## 3. The simp-normal form (the load-bearing design question)

### 3.1 The proposed set — compiled and verified

The whole set below **compiles** against the current tree (`lean_run_code`, clean except
`push_neg` deprecation warnings; use `push Not` to match BLTruth's house style).

In `namespace Truth`, tag the primitive clauses `attribute [simp] bot_false imp_iff box_iff`, add
`@[simp] untl_iff` / `snce_iff` (both `Iff.rfl`), and add:

| Lemma | Normal form (RHS) | Proof |
|---|---|---|
| `neg_iff` | `¬ TruthAt M τ t φ` | `Iff.rfl` |
| `top_true` | `True` | `id` |
| `and_iff` | `A ∧ B` | `simp only [Formula.and, Formula.neg, TruthAt]; tauto` |
| `or_iff` | `A ∨ B` | same shape |
| `diamond_iff` | `∃ σ, σ.IsTotal ∧ TruthAt M σ t φ` | classical `¬∀¬` step |
| `always_iff` | `∀ s, TruthAt M τ s φ` | via `always_iff_tri` + `lt_trichotomy` |
| `kPlus_iff` | `∀ s, t < s → ∃ r, t < r ∧ r < s ∧ TruthAt M τ r φ` | `push Not` |
| `kMinus_iff` | `∀ s, s < t → ∃ r, s < r ∧ r < t ∧ TruthAt M τ r φ` | `push Not` |

`untl_iff`/`snce_iff` are not in the charter but are **required**: without them the normal form is
incomplete, because nothing else reduces a raw `Formula.untl`/`snce` head once `TruthAt`'s
equations are no longer reached by an explicit `simp only [TruthAt]`.

### 3.2 Confluence and termination — measured, not argued

The decisive property is that **every alternative spelling converges on the same normal form**.
Each of these was compiled and closed by bare `simp`:

- `TruthAt (Formula.imp φ Formula.bot)` ≡ `TruthAt (Formula.neg φ)` → both `¬A`
- `TruthAt (Formula.imp (Formula.imp φ (Formula.imp ψ Formula.bot)) Formula.bot)` → `A ∧ B`
  (the raw double-negation spelling of `and` lands on the `and_iff` normal form)
- `TruthAt (Formula.neg (Formula.someFuture (Formula.neg φ)))` ≡ `TruthAt (Formula.allFuture φ)`
  → both `∀ s, t < s → …`; likewise for the past
- `TruthAt (Formula.untl Formula.top φ)` ≡ `TruthAt (Formula.someFuture φ)` → both `∃ s, t < s ∧ …`
- **`TruthAt (Formula.bot.imp Formula.bot)` → `True`**, and
  `TruthAt (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))` →
  `∃ s, t < s ∧ ∀ r, t < r → r < s → False`. This matters: `Formula.bot.imp Formula.bot` is the
  raw spelling the five uniformity axioms actually use, and it converges with `Formula.top`.
- Termination under nesting: `always (always (and φ ψ))` reduces to
  `∀ u, TruthAt M τ u φ ∧ TruthAt M τ u ψ` (the vacuous outer binder is discharged);
  `box (diamond φ)` composes without looping.

No loop against the default simp set was found. The structural reason **[reasoned]**: every LHS is
headed by `TruthAt` applied to a *distinct* `Formula` constructor or derived `def`, and since task
518 no `Formula` operator is unfolded by the default set, the discrimination tree selects exactly
one rewrite per node and every RHS is strictly smaller in `Formula` depth.

### 3.3 Defect 1: the charter's two `always` forms are non-confluent — reproduced

Step (1) asks for "both the three-conjunct form BLTruth uses and a collected `forall s` form." I
registered both `@[simp]` and compiled it. Result: `simp` applies the **first-registered** lemma
only. The goal stated against the collected form fails with

```
⊢ ((∀ s < t, TruthAt M τ s φ) ∧ TruthAt M τ t φ ∧ ∀ s, t < s → TruthAt M τ s φ)
    ↔ ∀ (s : F.Duration.carrier), TruthAt M τ s φ
```

Two `@[simp]` lemmas with identical LHS and different RHS make the normal form an artifact of
declaration order, and silently strand every proof written against the loser.

**Recommendation: the collected `∀ s` form is the `@[simp]` normal form.** Keep the three-conjunct
version as a plain, untagged `always_iff_tri` for introduction. Rationale beyond confluence:

- `DurationFrames.truth_of_always` does the trichotomy *by hand* precisely because the tri form is
  the wrong shape to consume; with the collected form it is `(always_iff _).mp h u`.
- `CoValidity.always_elim` (:73) is stated in the tri shape and can be derived in one line.
- The collected form makes `sometimes` fall out clean: I verified
  `TruthAt M τ t (Formula.sometimes φ) ↔ ∃ s, TruthAt M τ s φ` by
  `simp [Formula.sometimes]`. Under the tri form this does not close.

`F.Duration` is a `LinearOrder` (`TemporalOrder.linearOrder`, attribute-instance at
`TemporalOrder.lean:91`), so the two forms are genuinely equivalent — this is a choice of normal
form, not a strengthening.

### 3.4 `strong_release_iff` / `strong_trigger_iff`: keep them, keep the attribute

The charter says "drop the attribute or delete." I recommend **neither**. They have zero uses
*today*, but `strongRelease`/`strongTrigger` appear 87 times outside `Formula.lean`, and once
`untl_iff` is `@[simp]` these two are the only lemmas that reduce a `strongRelease` head — without
them the normal form has a hole exactly where a live operator sits. I verified they compose
correctly with the new set: `TruthAt (strongRelease φ ψ)` reduces, with `and_iff` firing on the
nested conjunction, to
`∃ s, t < s ∧ (TruthAt M τ s ψ ∧ TruthAt M τ s φ) ∧ ∀ r, t < r → r < s → TruthAt M τ r ψ`.
Their zero-use count is evidence they were never reachable, not that they are unwanted.

### 3.5 Defect 3: `@[simp]` alone changes nothing at existing sites

**Verified.** The old idiom `simp only [Formula.and, Formula.neg, TruthAt]` behaves *identically*
before and after the new attributes land, because `simp only` consults only its named lemmas.

Worse, and also verified: **adding** the new lemmas to an existing list without **removing** the
syntax-unfolding ones is a no-op. simp rewrites subterms bottom-up, so `Formula.and`/`Formula.or`/
`Formula.neg` unfold the argument before the `TruthAt`-headed characterization lemma can match. I
reproduced the stranded goal:

```
⊢ ((TruthAt M τ t φ → ¬TruthAt M τ t ψ) → ∀ x, x.IsTotal → ¬TruthAt M x t χ) ↔ …
```

— i.e. the old pathological `(A → ¬B) → C` shape, untouched.

**Consequence for the plan**: every sweep edit must *delete* `Formula.and`, `Formula.or`,
`Formula.neg`, and usually `TruthAt`, from the `simp only` list, replacing them with the
`Truth.*_iff` names. A plan phase that only adds attributes and declares victory will produce zero
measurable movement on the acceptance metric.

### 3.6 Blast radius is small

Because `simp only` sites are inert, the disruption surface is exactly the bare
`simp`/`simp_all`/`aesop` calls that can see a `TruthAt` goal. Measured: **48** such lines across
all files that mention `TruthAt` at all (against 793 repo-wide), and most of those sit on
Finset/decidability goals rather than truth goals. Concentrations: `Verified/Decidable.lean` (17),
`BiLasso/Extraction.lean` (8), `CountermodelExtraction.lean` (4). None of the eight scoped files
has more than 2. This is a genuinely low-risk attribute change.

### 3.7 `truth_norm` and `swap_norm`

`register_simp_attr` must live in a module upstream of every use site — tagging in the declaring
file fails with `Unknown attribute`. `Automation/NormalizationAttr.lean` already exists for exactly
this and its docstring says "It must not acquire any other content." Adding `truth_norm` and
`swap_norm` there contradicts that instruction; adding them elsewhere duplicates the module's
purpose. **Recommend**: add both sets to `NormalizationAttr.lean` and amend that sentence to name
the module's real invariant (attribute declarations only, no lemmas), rather than creating a second
attribute-declaration module.

`swap_norm` covers **eleven** `Formula.swap_temporal_*` lemmas, not nine; four
(`some_future`, `some_past`, `all_future`, `all_past`) are already `@[simp]`, so `swap_norm` is
additive for the other seven (`involution`, `diamond`, `neg`, `next`, `prev`, `strong_release`,
`strong_trigger`).

---

## 4. Verified sub-claims

### 4.1 A-17 holds — both lemmas compile

`truthAt_atomFree_history_indep` and `truthAt_gap_shift` are real and I proved both:

```lean
theorem truthAt_atomFree_history_indep (M : TaskModel F) (φ : Formula) (hφ : φ.atoms = ∅) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration), TruthAt M τ t φ ↔ TruthAt M σ t φ
```
by induction on `Formula`, splitting `hφ` with `Finset.union_eq_empty`; the `box` case is `rfl`
(the clause does not mention `τ`) and the temporal cases go through `exists_congr` /
`and_congr` / `forall_congr'`.

`truthAt_gap_shift` moves a gap witness by translation (`sub_sub_cancel`, `add_sub_sub_cancel`),
and is best stated through an intermediate

```lean
theorem truthAt_gap : TruthAt M τ t (Formula.untl .bot (.bot.imp .bot)) ↔
    ∃ s, t < s ∧ ∀ r, t < r → r < s → False
```

whose RHS mentions neither `M` nor `τ` — which is the whole content of the uniformity block.

**Payoff, compiled**: three of the five uniformity proofs (currently 17, 17 and 9 lines) collapse
to a single term each:

```lean
fun σ _ => (truthAt_atomFree_history_indep M _ rfl τ σ t).mp h          -- discrete_box_necessity
(Truth.future_iff _).mpr fun u _ => truthAt_gap_shift M τ t u h          -- discrete_propagate_fwd
(Truth.past_iff  _).mpr fun u _ => truthAt_gap_shift M τ t u h           -- discrete_propagate_bwd
```

The remaining two (`discrete_symm_fwd/bwd`, which cross between `untl`-gaps and `snce`-gaps) need a
dual `truthAt_cogap` plus a symmetry lemma; I did not prove those, but they are the same argument
mirrored and I see no obstruction. **[reasoned]**

### 4.2 The 50% proof-length target is comfortably beatable

I rewrote `linear_until_valid` — the charter's worst-named proof, 37 lines — against the new API.
**It compiles.** Proof body: 15 tactic lines against 30, i.e. 50% of the body and 51% of the whole
declaration, and it removes both hand-rolled `and_of_not_imp_not` unfoldings, both `by_contra`s and
all four `exfalso; apply h_neg` scaffolds. The `simp only` line becomes

```lean
simp only [Truth.and_iff, Truth.or_iff, Truth.untl_iff, Truth.imp_iff]
```

and the three trichotomy branches become three `exact .inl (.inr ⟨…⟩)`-style terms. `linear_since_valid`
(39 lines) is the mirror image and will behave the same.

### 4.3 The void `DenseValidity.lean:302` anchor, re-established live

The charter's validation anchor for "`Truth.imp_iff` is a drop-in for `simp only [TruthAt]`" points
at a deleted file. **Re-established**: in the `linear_until_valid` rewrite above, `Truth.imp_iff`
(together with `and_iff`/`or_iff`/`untl_iff`) replaces the live
`simp only [Formula.and, Formula.or, Formula.neg, TruthAt]` at
`FormalSystem/Metalogic/Soundness.lean:723`, and the resulting proof compiles. The claim survives
its anchor.

---

## 5. Is BLTruth a safe template? — Yes, with one caveat

The two relations really are parallel where it matters. `BLTruthAt`'s `atom`, `bot`, `imp` and
`box` clauses are **character-identical** to `TruthAt`'s, including the deliberately-inherited
`∃ (ht : τ.domain t)` domain conjunct (Decision A). The divergence is structural but harmless: BL's
`allPast`/`allFuture` are *primitive* constructors, so `BLTruth.past_iff`/`future_iff` are
`Iff.rfl`, whereas in BL⁺ they are derived from `untl`/`snce` and are *proved* theorems — already
present and already `@[simp]`. The statements agree; only the proofs differ.

Two things the mirror does **not** cover, which the plan must supply from scratch:
`untl_iff`/`snce_iff` and `kPlus_iff`/`kMinus_iff` (BL has no such operators).

**Caveat — the attribute set diverges either way.** `BLTruth` tags `neg/top/and/or/diamond/
somePast/someFuture/always` but leaves `bot_false/imp_iff/box_iff/past_iff/future_iff` untagged;
`Truth` already tags `future_iff/past_iff/some_future_iff/some_past_iff/strong_release_iff/
strong_trigger_iff`. Exact parity is therefore already unachievable and is not worth chasing. In
particular, if §3.3 is accepted, `Truth.always_iff` will be the collected form while
`BLTruth.always_iff` is the tri form. **This is safe**: `BLTruth.always_iff` has **zero** uses
outside `BLTruth.lean`, and `BaseLanguageSoundness.truthAt_tr` is proved by induction on
`BLFormula`'s six *constructors* and never touches `always`. Aligning `BLTruth.always_iff` to the
collected form is a nice-to-have, not a prerequisite.

Also note the naming skew, which will bite a careless sweep: BL has `somePast_iff`/`someFuture_iff`;
`Truth` has `some_past_iff`/`some_future_iff`.

---

## 6. Defect 2: the ≥80% acceptance gate is unreachable under the stated scope

Measured distribution of the 199 live `simp only [...TruthAt...]` sites:

| File | Sites | Note |
|---|---|---|
| `Metalogic/Soundness.lean` | 67 | the real target |
| `SoundnessLemmas/FrameClassVariants.lean` | 37 | **not in the charter's file scope** |
| `Decidability/Verified/Decidable.lean` | 27 | not in scope |
| `Semantics/Truth.lean` | 19 | **irreducible** — these *are* the characterization proofs |
| `Semantics/BLTruth.lean` | 5 | irreducible, same reason |
| `SoundnessLemmas/CoValidity.lean` | 1 | in scope |
| the other four scoped files | **0** | DurationFrames, Dedekind, Discrete, CoNotPriorU use `rw`, not `simp only` |
| elsewhere | 43 | not in scope |

The eight scoped files hold **92** sites, of which **24 are structurally irreducible** (Truth.lean's
19 + BLTruth's 5 — you cannot prove `and_iff` without unfolding `TruthAt`). Eligible: **68**.

Now the contradiction. Step (6) rewrites ~10 named proofs and says "the mechanical sweep of the
remaining soundness-layer sites is a separate re-scoped charter." I mapped the sites to the
declarations:

**The 17 named-and-adjacent proofs contain 20 of Soundness.lean's 67 sites. 47 lie outside them.**

So the maximum reduction achievable *within the stated scope* is 20/68 ≈ **30%**, against an
acceptance gate of **80%**. The two cannot both be satisfied.

**Recommendation**: keep the deferral and **restate the gate** as one of

- "≥80% of `simp only [...TruthAt...]` sites *within the rewritten declarations*" (achievable —
  the rewrites eliminate essentially all 20), or
- an absolute target: "Soundness.lean's site count drops from 67 to ≤47."

Either is honest and checkable. Silently keeping 80% guarantees the task reports failure or the
implementer quietly widens scope. Also note the two largest reservoirs (`FrameClassVariants.lean`
37, `Decidable.lean` 27) are **outside the charter's file scope** entirely — if the intent was ever
a repo-wide 80%, the file scope needs widening, which I would not recommend in one task.

---

## 7. Recommended phase ordering

The constraint is that adding `@[simp]` is globally visible while rewriting proofs is local. Since
§3.6 shows the blast radius is only 48 bare-simp lines, attributes can land early — which is what
makes the rest independently buildable.

- **P1 — API, no attributes.** Add all new lemmas to `Truth` *untagged*, plus `always_iff_tri`.
  Add `truth_norm`/`swap_norm` to `NormalizationAttr.lean` and the `truth_simp` macro. Purely
  additive; cannot break anything. Green by construction.
- **P2 — attributes.** Tag `bot_false`/`imp_iff`/`box_iff` and the new lemmas; settle
  `always_iff` on the collected form (§3.3) and keep `strong_*_iff` (§3.4). This is the only
  globally disruptive phase, and the only one that can redden files outside the scope; the 48
  bare-simp sites are the audit list. Keep it alone in its own phase and commit on green.
- **P3 — delete the duplicates.** The three `truth_and_iff` copies, `Decidable.truthAt_and`, the
  three `and_of_not_imp_not`, `DurationFrames.truth_always_of_forall`/`truth_of_always`,
  `CoValidity.always_elim`. Mechanical, and each deletion has a named replacement. Do **not**
  touch `ExteriorBracket.temporal_truth_and_iff` (§2.1).
- **P4 — `validOn_iff_total` move** (`Correspondence/FwdRec.lean:75` → `Semantics/Validity.lean` as
  `TaskFrame.validOn_iff_total`). One caller to update: `FwdRecBridge.lean:158`, plus the internal
  use at `FwdRec.lean:96` and the doc reference at `FwdRec.lean:41`. Independent of P1-P3.
- **P5 — atom-truth lemmas** (C-05): tag the four `@[simp]` and add `tau.val`-normalised forms so
  the 8 `rw [show τ.val = … from rfl, …]` sites at DurationFrames 385-534 become `simp`. Depends
  on P2 only.
- **P6 — A-17**: `truthAt_atomFree_history_indep`, `truthAt_gap`, `truthAt_gap_shift` beside
  `Truth.box_const` (:733), then rederive the five uniformity proofs (Soundness 825-910). Three
  are one-liners already verified; budget the two `discrete_symm_*` proofs for the dual lemma.
- **P7 — the ten named soundness rewrites.** Largest phase; `linear_until_valid` is done and can
  be lifted from §4.2 as the pattern. Split into two phases if it exceeds one agent run.

P4 through P7 are mutually independent given P2 and can be resequenced or parallelised.

---

## 8. Actions required before planning

1. **Choose one `always` normal form.** Recommend the collected `∀ s` form; keep
   `always_iff_tri` untagged. Non-negotiable — the alternative is verified-broken.
2. **Restate the ≥80% gate** per §6, or widen the file scope. As written it is unreachable.
3. **Fold `untl_iff`/`snce_iff` into step (1).** Not in the charter; the normal form is incomplete
   without them.
4. **Correct step (3)'s target**: `Decidable.lean:1408` is `truthAt_and`, an introduction lemma,
   not a `truth_and_iff` biconditional; the count is three copies plus one variant.
5. **Reverse step (1)'s `strong_*_iff` instruction** per §3.4, or state a reason to accept the hole.
6. **Amend `NormalizationAttr.lean`'s "must not acquire any other content"** sentence, or the two
   new attribute declarations violate an explicit in-file instruction.
7. **Record in the plan** that sweep edits must *remove* `Formula.and`/`or`/`neg` from simp lists,
   not merely add the new names (§3.5) — otherwise the work produces no measurable movement.
8. State the chosen normal form in `Truth.lean`'s module docstring, as the charter asks; §3.1's
   table is the content.

---

## Appendix: probe provenance

All probes run through `lean_run_code` against the existing oleans at commit `2bd4dfba2`; no build
was started and no source file was written. Probes: (1) full lemma set compiles; (2) twelve
confluence/termination goals under bare `simp`; (3) A-17's two lemmas plus three uniformity
collapses; (4) the `linear_until_valid` rewrite; (5) the dual-`always` non-confluence failure;
(6) the `Formula.or`-unfolding-defeats-`or_iff` failure. Probes 5 and 6 are *expected* failures
recorded as evidence.
