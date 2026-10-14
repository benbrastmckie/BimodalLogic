# Research Report: Task #791

**Task**: 791 - Prove prop:archimedean in the generality the paper states it (UZ and Z1 fail over every non-Archimedean Discrete temporal order)
**Started**: 2026-10-14T21:29:02Z
**Completed**: 2026-10-14T21:41:01Z
**Effort**: ~2 hours implementation (proof text already verified; see Findings)
**Dependencies**: Task 788 (complete — HEAD is `c77645f8d task 788: complete implementation`)
**Sources/Inputs**:
- Paper: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, `prop:archimedean` (line 3170) and its proof (lines 3174–3193); `def:canonical-frames` (line 3125 neighbourhood)
- Lean tree: `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`, `FormalSystem/Metalogic/Independence/LexIntWitness.lean`, `FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean`, `FormalSystem/Metalogic/Conservativity.lean`, `FormalSystem/Semantics/DurationClassification.lean`, `FormalSystem/Semantics/Frames/Standard.lean`, `FormalSystem/Semantics/Correspondence/DurationFrames.lean`, `FormalSystem/Semantics/FrameProperty.lean`, `FormalSystem/Semantics/Validity.lean`, `FormalSystem/Semantics/LexCarrier.lean`, `FormalSystem/MinusLanguage/Soundness.lean`, `FormalSystem/MinusLanguage/Translation.lean`, `FormalSystem/ProofSystem/Axioms.lean`
- Tools: `lean_run_code` (five compiled probes), `lean_local_search`, `lean-sorry-census.sh`, `lake-build-guard.sh result`
**Artifacts**:
- `specs/791_prop_archimedean_uz_z1_fail_non_archimedean/reports/01_uz-z1-fail-non-archimedean.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Both countermodels are already machine-checked, sorry-free, in this research phase.** Compiled
  probes (`lean_run_code`, success with zero diagnostics) prove `¬ (translationFrame D).toTaskFrame.ValidOn (Z1 p)`
  and `¬ (translationFrame D).toTaskFrame.ValidOn (UZ p)` over an **arbitrary** `(D : TemporalOrder)`
  carrying a least positive duration and `¬ Archimedean ↑D`. Implementation is transcription plus
  docstrings, not discovery.
- **The hypothesis can be stated at the paper's own Discrete clause**, not only at a `SuccOrder`.
  Four entry points to "there is a least duration `1 > 0`" all compile: the paper's bare Discrete
  clause read at `0`, `TaskFrame.IsDiscrete` of the translation frame, `[SuccOrder ↑D]` via
  `isLeast_pos_succ_zero`, and `¬ DenselyOrdered` via `duration_dense_or_least_pos`.
- **One new order lemma is needed and nothing else.** `¬ Archimedean D` plus a least positive `u`
  yields `∃ x, ∀ n : ℕ, n • u < x` — the paper's `y`. Verified; no Mathlib or in-tree equivalent
  exists at a bare ordered abelian group (`archimedean_iff_nat_lt` and friends need a semiring).
- **Decision recorded: `Z1Countermodel.lean` stays as the concrete L⁻ witness, unchanged.** It is
  not an instance of the general theorem and cannot be made one: it lives in the L⁻ language
  (`MinusTruthAt`) over `multiFamTaskFrameGen`, and `MinusLanguage.tr_ne_untl` makes `tr` of the
  L⁻ `Z1` syntactically distinct from L's `Z1` (L's `FGp` is a top-level `untl`; nothing in
  `tr`'s range is). `tmMinusCompleteZTime_refuted` and the CEF deliverables are untouched by
  construction.
- **New home recommended**: `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean`, with
  the order lemma in `FormalSystem/Semantics/DurationClassification.lean` and the frame-property
  lemma in `FormalSystem/Semantics/Correspondence/DurationFrames.lean`. `ZTimeSharpness.lean`'s
  module docstring must be amended: it currently asserts that "the non-Archimedean discrete
  carriers are a different story, told by `Independence/LexIntWitness.lean`".
- **Baseline measured this session**: `lean-sorry-census.sh FormalSystem` → `sorry_count: 0`;
  `lake-build-guard.sh result` → `state=complete exit_status=0` (build ending epoch 1792012413,
  i.e. at HEAD, before this dispatch began).

## Context & Scope

In scope: the semantic (frame-level) refutations of UZ and Z1 over the translation frame at an
arbitrary non-Archimedean carrier with a least positive duration, the order-theoretic glue they
need, their lift to the paper's `⊭_D` shape and to the bare Discrete class, and the disposition of
the existing `ℚ ×ₗ ℤ` module.

Out of scope, and deliberately: any change to `FrameClass.ZTime`'s soundness story (the refuting
frames are Discrete-but-not-`IsZTime`, so nothing here collides with `axiom_validIn_min`,
`prior_UZ_validIn_iff_ztime`, or `z1_validIn_iff_ztime`); any L⁻-language generalization; the
paper-side `% PORT:` marker (out-of-tree — see Decisions).

Constraints carried from the dispatch: `lake build FormalSystem` green and no new `sorry` at the
end of every phase.

## Literature Proof Structure

**Source**: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`,
`prop:archimedean` (statement line 3170; proof lines 3174–3193), citing `def:canonical-frames`
for `F^tr_D` and `σ_0`, and `def:BL-semantics` for the truth clauses.
**Strategy**: two direct countermodels on one shared frame and history, turning on one shared
division of `D`.

### Step Map

1. **Setup.** `D` nontrivial and Discrete ⇒ a least duration `1 > 0`. `D` not Archimedean ⇒ some
   `y > 0` with `y > n · 1` for every positive integer `n`. (Paper's illustration: `ℤ ×ₗ ℤ`,
   `1 = ⟨0,1⟩`, `y = ⟨1,0⟩`.) — Lean: new lemma, plus `isLeast_pos_succ_zero` /
   `duration_dense_or_least_pos` / the Discrete clause at `0`.
2. **Shared frame.** Both countermodels live on `F^tr_D` evaluated along `τ := σ_0`, so
   `τ(z) = z`. — Lean: `translationFrame D`, `translationHist D`, `translationModel D A`.
3. **Shared step fact.** `D` an ordered group ⇒ the least time above `z` is `z + 1`. — Lean:
   `isLeast_succ_of_isLeast_pos` (`Semantics/DurationClassification.lean`).
4. **Shared division.** `E := {z ∈ D | 0 < z < n · 1 for some n ∈ ℕ}` (the near times) and its
   complement (the times beyond every multiple), of which `y` is one.
5. **Z1, valuation.** `|p| = D \ E`.
6. **Z1, `FGp` at `0`.** Every `z > y` exceeds every `n · 1`, hence `z ∉ E`, hence `p` at `z`;
   so `Gp` at `y`, and `y > 0` gives `FGp` at `0`.
7. **Z1, `G(Gp → p)` at `0`.** For arbitrary `z > 0`: if `z ∉ E` then `p` at `z`; if `z ∈ E` then
   `z + 1 ∈ E` (from `0 < z < n·1` to `0 < z+1 < (n+1)·1`), so `p` fails at `z+1 > z` and `Gp`
   fails at `z`. Either way `Gp → p` holds at `z`.
8. **Z1, `¬Gp` at `0`.** `1 ∈ E` because `0 < 1 < 2 · 1`, so `p` fails at `1 > 0`.
9. **Z1, conclusion.** Steps 7, 6, 8 refute `G(Gφ → φ) → (FGφ → Gφ)` at `0`.
10. **UZ, valuation.** `|p| = {y + n · 1 | n ∈ ℤ}` — a copy of `ℤ` lying wholly above `0`, since
    `y` exceeds every multiple of `1`.
11. **UZ, `Fp` at `0`.** `y > 0` and `p` at `y`.
12. **UZ, `¬(¬p U p)` at `0`.** Each `p`-time `y + n·1` is preceded by the `p`-time
    `y + (n−1)·1 > 0`, so no `p`-time `z > 0` has `¬p` throughout `(0, z)`.
13. **UZ, conclusion.** Refutes `Fφ → (¬φ U φ)` at `0`.

### Dependencies

- Steps 5–9 (Z1) and 10–13 (UZ) each depend on steps 1–4; the two branches are independent of
  each other.
- Step 7 depends on step 3 (the `z + 1` step fact) and on step 4's definition of `E`.
- Step 12 depends on step 1's "`y` exceeds every multiple" in its full ℤ-indexed form (positivity
  of `y + n·1` for negative `n`).

### Potential Formalization Challenges

- **Step 1** is the only step with no in-tree counterpart. `Archimedean` is a `class`, so
  `¬ Archimedean D` must be opened by contraposition (`by_contra` + `push Not` + `⟨·⟩`
  reconstruction) rather than destructured. *Measured: verified, five lines.*
- **Step 12** needs `0 < y + n • u` at **ℤ**-indexed `n`, which splits on the sign of `n`; the
  negative branch needs `neg_zsmul`/`natCast_zsmul` to land back on the ℕ-indexed hypothesis.
  *Measured: verified, nine lines.*
- **Step 7** is stated contrapositively in the paper ("if `z ∈ E` then `Gp` fails at `z`"); in
  Lean it is cleaner to intro `Gp` and derive `z ∉ E` from it, which is the same argument read
  forwards. Flagged as a presentation reordering, not a deviation from the source's reasoning.
- **No notation or encoding mismatch** otherwise: the paper's `1`, `y`, `E`, `σ_0` and `F^tr_D`
  each have an exact in-tree counterpart (`u`, `y`, `E`, `translationHist D`, `translationFrame D`).
- `0` in the paper is literally `(0 : ↑D)`, and `translationHist D` is the identity assignment, so
  no base-point bookkeeping is needed.

## Findings

### Codebase Patterns

- **`ZTimeSharpness.lean` is the exact structural template.** `not_validOn_prior_UZ_dense` and
  `not_validOn_z1_dense` (`FormalSystem/Metalogic/Independence/ZTimeSharpness.lean:195`,
  `:215`) already refute the same two formulas on `(translationFrame D).toTaskFrame` at an
  arbitrary `[DenselyOrdered ↑D]`, with the same `translationModel`/`translationHist`/
  `translation_realizes` layer. The new results are the sibling story at the opposite branch of
  the duration dichotomy (least-positive instead of dense).
- **Formula shapes are pinned.** `ZTimeSharpness.lean:152–159` carries two `example` shape pins
  tying the refuted formulas to `Axiom.prior_UZ` and `CompletenessDerived.z1Thm`. The new module
  should carry the same two pins, so the generality claim is a compiler obligation.
- **`ZTimeSharpness.lean`'s docstring contradicts the new result's placement.** Its section "What
  is refuted is discreteness, not the Archimedean property" states: "It is **not** the Archimedean
  property, and no claim is made here that either axiom is refutable specifically over ℚ, or
  specifically over a non-Archimedean order... The non-Archimedean discrete carriers are a
  different story, told by `Independence/LexIntWitness.lean`." Once the new module exists, that
  sentence must point at it. Adding the new theorems *inside* `ZTimeSharpness.lean` would force a
  larger rewrite of that section for no gain, which is why a new module is recommended.
- **The translation-frame layer is complete and needs no extension.** `translationFrame`
  (`FormalSystem/Semantics/Frames/Standard.lean:73`), `translationFrame_isRegular` (`:103`),
  `translationFrame_taskRel` (`:106`), `translationHist` /`translationModel` /
  `translation_realizes` /`translation_realizes_allFuture`
  (`FormalSystem/Semantics/Correspondence/DurationFrames.lean:117`, `:124`, `:141`, `:153`).
- **The duration-order glue is complete.** `isLeast_succ_of_isLeast_pos`
  (`FormalSystem/Semantics/DurationClassification.lean:216`), `isLeast_pos_succ_zero` (`:253`),
  `archimedean_of_succ` (`:296`), `duration_dense_or_least_pos` (`:342`),
  `TaskFrame.exists_pos_of_nontrivial`.
- **The non-Archimedean carriers are available off the shelf.** `LexInt.isLeast_pos` and
  `LexInt.not_archimedean` (`FormalSystem/Semantics/LexCarrier.lean:153`, `:235`) hold at
  `α ×ₗ ℤ` for any nontrivial `α`, so both `ℤ ×ₗ ℤ` and `ℚ ×ₗ ℤ` instantiate the general theorem
  directly. (`Rigidity.lexRat_not_archimedean` is at `ℚ ×ₗ ℚ`, which is dense and therefore has
  no least positive duration — not a usable instantiation here.)
- **Validity-over-a-set-of-frames already exists**: `ValidOnFrames (P : TaskFrame → Prop) (φ)`
  (`FormalSystem/Semantics/Validity.lean:337`), and `ValidIn fc := ValidOnFrames fc.Sat`.
  The bare Discrete class of record is `{F | F.IsRegular ∧ F.IsDiscrete}`, the set
  `galoisClosed_isDiscrete` is stated over
  (`FormalSystem/Semantics/Correspondence/Indicator.lean:182`).
- **The paper's `⊭_D` has a settled in-tree rendering**: `validOn_df_iff_isDiscrete`
  (`FormalSystem/Semantics/Correspondence/DurationFrames.lean:302`) renders `⊨_D` as
  `∀ (F : FrameOver D) (φ), F.toTaskFrame.ValidOn ...`. The new results should carry a corollary
  in that shape, since `prop:archimedean` is stated in exactly that idiom.
- **Post-788 naming, confirmed**: the base `Axiom` inductive has no `z1` constructor; only
  `Axiom.prior_UZ` carries `minFrameClass = .ZTime` (`FormalSystem/ProofSystem/Axioms.lean:306`,
  `:603`). Z1 is the derived `Metalogic.CompletenessDerived.z1Thm`
  (`FormalSystem/Metalogic/CompletenessDerived.lean:63`), with validity from
  `SoundnessLemmas.z1_valid`. New docstrings must use those names.
- **Post-788 doc drift (not blocking, flagged)**: five docstrings still name a nonexistent
  `Axiom.z1` — `FormalSystem/ProofSystem/Axioms.lean:541` ("ZTime (2 axioms: prior_UZ, z1)"),
  `FormalSystem/Semantics/FrameProperty.lean` (the `IsZTime` docstring's "`Axiom.prior_UZ`,
  `DerivedAxioms.priorSZ` and `Axiom.z1` all carry `.ZTime`"),
  `FormalSystem/Metalogic/Conservativity.lean:113`,
  `FormalSystem/Metalogic/Independence.lean:80`, and
  `FormalSystem/Metalogic/Independence/StaticFrame.lean:55`/`:300`/`:303`.
- **The prose claim this task converts into a theorem** is at
  `FormalSystem/Metalogic/Conservativity.lean:197–206` and
  `FormalSystem/Semantics/FrameProperty.lean`'s `IsZTime` docstring: both *restate* the paper's
  every-non-Archimedean-order claim without proving it. Both should gain a pointer to the new
  theorems once they land.

### External Resources

- **No Mathlib lemma opens `¬ Archimedean` at a bare ordered abelian group.**
  `archimedean_iff_nat_lt` / `_nat_le` / `_int_lt` / `_int_le` / `_rat_lt` / `_rat_le`
  (`.lake/packages/mathlib/Mathlib/Algebra/Order/Archimedean/Basic.lean:311–343`) all require a
  `StrictOrderedSemiring`-flavoured carrier, which a `TemporalOrder` is not. The class itself is
  `Archimedean.arch : ∀ (x) {y}, 0 < y → ∃ n : ℕ, x ≤ n • y`
  (`.lake/packages/mathlib/Mathlib/Algebra/Order/Archimedean/Defs.lean:31`).
- Mathlib lemmas consumed by the verified proofs: `nsmul_le_nsmul_right`, `nsmul_nonneg`,
  `succ_nsmul`, `two_nsmul`, `sub_zsmul`, `one_zsmul`, `neg_zsmul`, `natCast_zsmul`,
  `sub_eq_add_neg`, `sub_pos`, `sub_lt_self`, `lt_add_of_pos_right`,
  `add_lt_add_of_lt_of_le`, `add_lt_add_of_le_of_lt`, `le_add_of_nonneg_right`, `le_or_gt`,
  `lift ... using`.
- Deprecation note measured during probing: `push_neg` now warns and asks for `push Not`
  (which is already the repo's idiom in `ZTimeSharpness.lean`). Use `push Not`.
- `le_or_lt` does **not** resolve in this toolchain's ambient namespace; `le_or_gt` does.

### Recommendations

A sorry-free path exists and has been exercised end to end. Recommended decomposition:

1. **Order lemma** → `FormalSystem/Semantics/DurationClassification.lean`, beside
   `archimedean_of_succ` (the positive side of the same picture), at the file's existing weakest
   binder bundle `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`:

   `exists_gt_nsmul_of_not_archimedean (hu : IsLeast {z : D | 0 < z} u) (hna : ¬ Archimedean D) : ∃ x : D, ∀ n : ℕ, n • u < x`

   Verified proof (compiled, zero diagnostics):
   ```lean
   by_contra hc
   push Not at hc
   refine hna ⟨fun x y hy => ?_⟩
   obtain ⟨n, hn⟩ := hc x
   exact ⟨n, hn.trans (nsmul_le_nsmul_right (hu.2 hy) n)⟩
   ```

2. **Frame-property lemma** → `FormalSystem/Semantics/Correspondence/DurationFrames.lean`
   (`TaskFrame.IsDiscrete` is already in its import closure, via
   `Correspondence/Indicator.lean` → `Correspondence/Galois.lean`), beside the other
   translation-frame facts:

   `translationFrame_isDiscrete (D) (hu : IsLeast {z : ↑D | 0 < z} u) : (translationFrame D).toTaskFrame.IsDiscrete := fun x _ => ⟨x + u, isLeast_succ_of_isLeast_pos hu x⟩`

   Verified. Also verified there: the converse direction, `(translationFrame D).toTaskFrame.IsDiscrete → ∃ u, IsLeast {z | 0 < z} u`,
   by reading the clause at `0` with `TaskFrame.exists_pos_of_nontrivial` as the guard witness —
   which is what lets the countermodels be stated at the paper's own Discrete hypothesis.

3. **New module** `FormalSystem/Metalogic/Independence/ArchimedeanSharpness.lean`, importing
   `FormalSystem.Semantics.Correspondence.DurationFrames`,
   `FormalSystem.Metalogic.Soundness`, `FormalSystem.Metalogic.CompletenessDerived` (for the Z1
   shape pin) and `FormalSystem.Semantics.LexCarrier` (for the concrete instantiation):
   - two `example` shape pins against `Axiom.prior_UZ` and `CompletenessDerived.z1Thm`, copied
     from `ZTimeSharpness.lean:152–159`;
   - `not_validOn_z1_nonArchimedean` and `not_validOn_prior_UZ_nonArchimedean` at binders
     `(D : TemporalOrder) {u : ↑D} (hu : IsLeast {z : ↑D | 0 < z} u) (hna : ¬ Archimedean ↑D) (p : Atom)`
     — both verified in full (proof text below in Appendix);
   - the four hypothesis-entry wrappers (Discrete clause at `0`, `IsDiscrete` of the frame,
     `[SuccOrder ↑D]`, `¬ DenselyOrdered ↑D`) — all four verified;
   - the paper-shape corollaries `¬ ∀ F : FrameOver D, F.toTaskFrame.ValidOn φ` — verified;
   - the class-level corollaries `¬ ValidOnFrames (fun F => F.IsRegular ∧ F.IsDiscrete) φ` for
     both formulas, instantiated at `TemporalOrder.of (ℤ ×ₗ ℤ)` via `LexInt.isLeast_pos` /
     `LexInt.not_archimedean` — verified, including that the witness frame is regular and
     `IsDiscrete` yet **not** `IsZTime`.
4. **Docstring amendments** (prose only, no proof change):
   - `ZTimeSharpness.lean`'s "What is refuted is discreteness, not the Archimedean property"
     section: redirect its closing sentence to the new module.
   - `FormalSystem/Metalogic/Conservativity.lean:197–206` and
     `FormalSystem/Semantics/FrameProperty.lean`'s `IsZTime` docstring: replace "restates the
     paper's claim" prose with a citation of the two new theorems.
   - Optionally, in the same pass, fix the five stale `Axiom.z1` mentions listed above. Keep this
     as its own phase objective so it can be dropped without touching the mathematics.
5. **`Z1Countermodel.lean`: no change.** See Decisions.

Suggested phase shape: (1)+(2) as one phase (order and frame glue, builds the two files already in
`FormalSystem.Semantics`), (3) as one phase (the new module, where the mathematics lands), (4) as a
documentation phase. Each phase ends with a guarded scoped build; the final phase ends with a
guarded full build and `lean-sorry-census.sh FormalSystem`.

## Decisions

- **`FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean` stays as the concrete witness and
  is not touched.** It is not an instance of the general theorem, and cannot be made one without
  building a second, L⁻-language countermodel. Three independent reasons, each measured:
  1. *Different language.* The module's results are about `MinusTruthAt` on `MinusFormula`
     (`z1_not_true_at_zero`, `not_minus_derivable_z1`); the general theorem is about `TruthAt` on
     `Formula`. There is no single lemma both can factor through.
  2. *The translation does not bridge the gap.* `MinusLanguage.tr` does not commute with
     `someFuture`, and by `MinusLanguage.tr_ne_untl` nothing in `tr`'s range is a top-level
     `untl`, while L's `FGp` is one (`FormalSystem/MinusLanguage/Translation.lean:37–55`). So
     `tr (Conservativity.Z1 ψ)` is not L's Z1 formula, and the L-level refutation cannot discharge
     the L⁻-level claim.
  3. *Different countermodel.* The module's valuation is `1 ≤ (ofLex w.2).1` (the ℚ-coordinate
     upper set), which refutes Z1 at `ℚ ×ₗ ℤ` but is not the paper's construction. The paper's
     `E` at that carrier is `{z | z.1 = 0 ∧ z.2 > 0}`, giving `|p| = {z | z.1 ≠ 0 ∨ z.2 ≤ 0}` — a
     different set. The two are siblings, not generalization and instance.
  Consequence: `tmMinusCompleteZTime_refuted` and the CEF deliverables keep compiling because
  nothing they depend on changes. The only edit recommended to that module is a docstring
  cross-reference to the new general theorems.
- **Hypothesis form: `IsLeast {z : ↑D | 0 < z} u`, not `[SuccOrder ↑D]`.** It is the paper's own
  "there is a least duration `1 > 0`" verbatim, it is strictly weaker than a `SuccOrder` (which is
  data, not a `Prop`, and would drag instance-unification concerns of the kind
  `permissiveFrame`'s explicit `so` binder exists to avoid), and the `SuccOrder` form is recovered
  as a one-line wrapper via `isLeast_pos_succ_zero`. The dispatch's "`SuccOrder`" is therefore
  satisfied by a wrapper rather than by the primary binder.
- **New module rather than extending `ZTimeSharpness.lean`.** That module's docstring explicitly
  disclaims the Archimedean story and assigns it elsewhere; honouring the disclaimer with a
  redirect is a smaller and more honest edit than rewriting the section.
- **Both formulas stay at `Formula.atom p`, never schematic in `φ`.** Forced, for the reason
  `ZTimeSharpness.lean` already records: `Axiom.prior_UZ ⊥` has an unsatisfiable antecedent and so
  is valid everywhere, which would falsify a `∀ φ` form.
- **The `% PORT:` marker is raised as a non-blocking `user_decision`, not silently actioned.** It
  lives at `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex:3174`, outside
  this repository's working tree, and the dispatch also assigns the `prop:archimedean` rewording to
  PossibleWorlds task 172. Recommendation: this task delivers the Lean theorems and names the exact
  identifiers for the eventual `\leanproof{\texttt{...}}` citation; the paper-side edit (deleting
  the `% PORT:` line and adding the `\leanproof{}` macro, as the 29 already-ported proofs do) is
  left to task 172.

## Risks & Mitigations

- **Risk**: `translationFrame_isDiscrete` placed in `DurationFrames.lean` could surprise a reader
  expecting frame-property lemmas beside `translationFrame_isRegular` in `Frames/Standard.lean`.
  **Mitigation**: `Frames/Standard.lean`'s import list is deliberately `TaskFrame` and nothing
  else (its module docstring records why), and `TaskFrame.IsDiscrete` is not in that closure.
  `DurationFrames.lean` already hosts the translation frame's history, model and realisation
  lemmas, so it is the correct home; say so in the lemma's docstring.
- **Risk**: an implementer could read "no claim is made here that either axiom is refutable...
  specifically over a non-Archimedean order" in `ZTimeSharpness.lean` as a standing prohibition
  and mark the task blocked. **Mitigation**: that sentence scopes what *that module* claims, not
  what the tree may prove; the amendment in step 4 removes the ambiguity. Do the amendment in the
  same phase set, not later.
- **Risk**: concurrent sibling dispatches (756, 789, 790, 792, 793, 794) share this working tree;
  789/790/792/793/794 declare no `file_scope`. `DurationClassification.lean` and
  `DurationFrames.lean` are not in 756's declared scope, but an undeclared sibling could touch
  them. **Mitigation**: re-read each file immediately before editing, stage only this task's own
  hunks with an explicit file list, never `git add` a directory or glob, and treat a build failure
  outside this task's own files as possibly a sibling's in-flight edit.
- **Risk**: an unguarded `lake` invocation by a sibling collides with this task's build and the
  build is lost. **Mitigation**: route every build through `lake-build-guard.sh build --timeout 1800 -- ...`,
  detached, and read the verdict from the guard's `result` subcommand rather than a pipe exit code.
- **Risk**: adding the class-level corollary at `{F | F.IsRegular ∧ F.IsDiscrete}` could be
  misread as contradicting `prior_UZ_validIn_iff_ztime` / `z1_validIn_iff_ztime`.
  **Mitigation**: the refuting frame is Discrete-and-regular but **not** `IsZTime`, and that fact
  is itself provable in three lines (verified: `rintro ⟨so, -, hsa, -⟩` then
  `LexInt.not_archimedean (@archimedean_of_succ _ _ _ _ so _ hsa)`). State it as its own named
  lemma in the new module so the non-collision is on the record rather than in a reader's head.
- **Risk**: scope creep into an L⁻ twin. `minus_soundness_ztime_succ`
  (`FormalSystem/MinusLanguage/Soundness.lean:503`) is generic over any regular frame with
  `SuccOrder` **and** `PredOrder` on the duration, so an L⁻ version of the general countermodel
  *would* generalize `not_minus_derivable_z1` to every such carrier. **Mitigation**: this is
  beyond the dispatch's stated DELIVER (which names the L-level `ValidOn`), needs a `PredOrder`
  hypothesis the L-level results do not, and should be a separate task if wanted. Recorded here so
  the option is not lost; explicitly **not** recommended for this task.

## Tactic Survey Results

Candidate tactics were exercised directly against the live goals inside compiled `lean_run_code`
probes rather than through `lean_multi_attempt`, because the goals only exist inside a
half-constructed countermodel (no stable file position to attempt against). Results are therefore
measurements of the final proof text, not of isolated attempts.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `¬ Archimedean D → ∃ x, ∀ n, n • u < x` | `by_contra` + `push Not` + `refine ⟨·⟩` | success | `nsmul_le_nsmul_right`, `hu.2` |
| same | `push_neg` | success with deprecation warning | prefer `push Not` |
| `0 < z + u` from `0 < z`, `0 < u` | `lt_trans · (lt_add_of_pos_right _ hu0)` | success | — |
| `z + u < (n+1) • u` from `z < n • u` | `add_lt_add_right hn u` | fail (produced `u + z < u + n • u`) | argument order not as expected |
| same | `add_lt_add_of_lt_of_le hn le_rfl` after `rw [succ_nsmul]` | success | `succ_nsmul` |
| `u < 2 • u` | `rw [two_nsmul]; exact lt_add_of_pos_right u hu0` | success | `two_nsmul` |
| `0 ≤ n • u` for `n : ℤ`, `0 ≤ n` | `lift n to ℕ using hn; simpa using nsmul_nonneg hu0.le n` | success | `nsmul_nonneg` |
| `0 < y + n • u` for `n : ℤ`, `n < 0` | `obtain ⟨k, _⟩ : ∃ k : ℕ, n = -(k:ℤ) := ⟨(-n).toNat, by omega⟩` then `rw [neg_zsmul, natCast_zsmul, ← sub_eq_add_neg]; exact sub_pos.mpr (hy k)` | success | `omega` on the ℤ side only |
| `y + (n-1) • u < y + n • u` | `add_lt_add_of_le_of_lt le_rfl ·` + `rw [sub_zsmul, one_zsmul, ← sub_eq_add_neg]` + `sub_lt_self _ hu0` | success | first attempt without `← sub_eq_add_neg` failed |
| sign split on `n : ℤ` | `rcases le_or_lt 0 n` | fail (`Unknown identifier le_or_lt`) | use `le_or_gt` |
| same | `rcases le_or_gt 0 n` | success | — |
| `IsDiscrete` of `translationFrame D` | `fun x _ => ⟨x + u, isLeast_succ_of_isLeast_pos hu x⟩` | success | term mode, no tactics |
| `¬ IsZTime (translationFrame lexZOrder)` | `rintro ⟨so, -, hsa, -⟩` + `LexInt.not_archimedean (@archimedean_of_succ ...)` | success | pattern copied from `lexIntStaticFrame_not_sat` |
| `linarith` on any duration goal | not attempted | — | `DurationClassification.lean` records that it does not fire on a bare ordered abelian group |

`lean_hammer_premise` was not used: no stable in-file proof position existed to query, and every
goal closed on the first or second hand-chosen candidate. No decomposition (APOLLO) pass was
needed — no goal required a `sorry` skeleton at any point.

## Context Extension Recommendations

- **Topic**: opening a negated Mathlib `class` hypothesis (`¬ Archimedean`, `¬ IsSuccArchimedean`,
  `¬ DenselyOrdered`) in a proof.
  **Gap**: `.claude/context/project/lean4/` has no note on this, and the pattern recurs across
  `LexCarrier.lean`, `LexIntWitness.lean`, `RigiditySharpness.lean` and now this task. The
  structure-projection route (`h.arch`) works only in the positive direction; the negative
  direction needs `by_contra` + `push Not` + anonymous-constructor reconstruction, which is not
  obvious and was the one step of this task with no in-tree precedent to copy.
  **Recommendation**: add `context/project/lean4/patterns/negated-class-hypotheses.md` with the
  three-line idiom and the `Archimedean` worked example.
- **Topic**: `push_neg` → `push Not` migration.
  **Gap**: `.claude/rules/lean4.md`'s "Common Tactics" list does not mention it; `push_neg` now
  emits a deprecation warning on every use, which a zero-warning gate would surface as noise.
  **Recommendation**: one line in `rules/lean4.md` naming `push Not` as the current form.

## Appendix

### Verified proof text

Both theorem bodies below were compiled as-is by `lean_run_code` (`success: true`, zero
diagnostics) against imports `FormalSystem.Semantics.Correspondence.DurationFrames` and
`FormalSystem.Metalogic.Soundness`, under
`open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem`.

```lean
theorem not_validOn_z1_nonArchimedean (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := by
  intro h
  have hu0 : (0 : (D : Type)) < u := hu.1
  obtain ⟨y, hy⟩ := exists_gt_nsmul_of_not_archimedean hu hna
  have hy0 : (0 : (D : Type)) < y := by simpa using hy 0
  set E : Set (D : Type) := {z | 0 < z ∧ ∃ n : ℕ, z < n • u} with hE
  set A : Set (D : Type) := Eᶜ with hA
  have hEstep : ∀ z, z ∈ E → z + u ∈ E := by
    rintro z ⟨hz0, n, hn⟩
    refine ⟨lt_trans hz0 (lt_add_of_pos_right _ hu0), n + 1, ?_⟩
    rw [succ_nsmul]
    exact add_lt_add_of_lt_of_le hn le_rfl
  have hAbove : ∀ z, y < z → z ∈ A := by
    intro z hz hzE
    obtain ⟨-, n, hn⟩ := hzE
    exact absurd (lt_trans (hy n) hz) (not_lt.mpr hn.le)
  have huE : u ∈ E := ⟨hu0, 2, by rw [two_nsmul]; exact lt_add_of_pos_right u hu0⟩
  have hval := h (translationModel D A) (translationHist D) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel D A) (translationHist D) 0
      ((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture := by
    rw [Truth.future_iff]
    intro s _
    rw [Truth.imp_iff]
    intro hGp
    rw [translation_realizes_allFuture] at hGp
    rw [translation_realizes]
    intro hsE
    exact hGp (s + u) (lt_add_of_pos_right s hu0) (hEstep s hsE)
  have hcons := hval hant
  rw [Truth.imp_iff] at hcons
  have hFGp : TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom p).allFuture.someFuture := by
    rw [Truth.some_future_iff]
    refine ⟨y, hy0, ?_⟩
    rw [translation_realizes_allFuture]
    exact hAbove
  have hnotGp : ¬ TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom p).allFuture := by
    rw [translation_realizes_allFuture]
    intro hall
    exact hall u hu0 huE
  exact hnotGp (hcons hFGp)
```

```lean
theorem not_validOn_prior_UZ_nonArchimedean (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) (hna : ¬ Archimedean (D : Type)) (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) := by
  intro h
  have hu0 : (0 : (D : Type)) < u := hu.1
  obtain ⟨y, hy⟩ := exists_gt_nsmul_of_not_archimedean hu hna
  have hy0 : (0 : (D : Type)) < y := by simpa using hy 0
  set A : Set (D : Type) := {z | ∃ n : ℤ, z = y + n • u} with hA
  have hpos : ∀ n : ℤ, (0 : (D : Type)) < y + n • u := by
    intro n
    rcases le_or_gt 0 n with hn | hn
    · have hnn : (0 : (D : Type)) ≤ n • u := by
        lift n to ℕ using hn
        simpa using nsmul_nonneg hu0.le n
      exact lt_of_lt_of_le hy0 (le_add_of_nonneg_right hnn)
    · obtain ⟨k, hk⟩ : ∃ k : ℕ, n = -(k : ℤ) := ⟨(-n).toNat, by omega⟩
      subst hk
      rw [show (-(k : ℤ)) • u = -((k : ℕ) • u) by rw [neg_zsmul, natCast_zsmul],
        ← sub_eq_add_neg]
      exact sub_pos.mpr (hy k)
  have hval := h (translationModel D A) (translationHist D) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom p).someFuture := by
    rw [Truth.some_future_iff]
    exact ⟨y, hy0, (translation_realizes D A p y).mpr ⟨0, by simp⟩⟩
  obtain ⟨s, h0s, hps, hguard⟩ := hval hant
  rw [translation_realizes] at hps
  obtain ⟨n, rfl⟩ := hps
  have hpred : y + (n - 1) • u < y + n • u := by
    refine add_lt_add_of_le_of_lt le_rfl ?_
    rw [sub_zsmul, one_zsmul, ← sub_eq_add_neg]
    exact sub_lt_self _ hu0
  have hne := hguard (y + (n - 1) • u) (hpos (n - 1)) hpred
  rw [Truth.neg_iff] at hne
  exact hne ((translation_realizes D A p _).mpr ⟨n - 1, rfl⟩)
```

### Verified glue (four hypothesis entry points, frame property, two corollary shapes)

```lean
theorem isLeast_pos_of_isDiscrete (D : TemporalOrder)
    (hdisc : ∀ x : (D : Type), (∃ y, x < y) → ∃ y', IsLeast {z : (D : Type) | x < z} y') :
    ∃ u : (D : Type), IsLeast {z : (D : Type) | 0 < z} u := by
  obtain ⟨q, hq⟩ := TaskFrame.exists_pos_of_nontrivial (D := (D : Type))
  exact hdisc 0 ⟨q, hq⟩

theorem isLeast_pos_of_translationFrame_isDiscrete (D : TemporalOrder)
    (hdisc : (translationFrame D).toTaskFrame.IsDiscrete) :
    ∃ u : (D : Type), IsLeast {z : (D : Type) | 0 < z} u := by
  obtain ⟨q, hq⟩ := TaskFrame.exists_pos_of_nontrivial (D := (D : Type))
  exact hdisc 0 ⟨q, hq⟩

theorem isLeast_pos_of_succ (D : TemporalOrder) [SuccOrder (D : Type)] :
    IsLeast {z : (D : Type) | 0 < z} (Order.succ (0 : (D : Type))) :=
  isLeast_pos_succ_zero

theorem isLeast_pos_of_not_dense (D : TemporalOrder) (h : ¬ DenselyOrdered (D : Type)) :
    ∃ u : (D : Type), IsLeast {z : (D : Type) | 0 < z} u :=
  (duration_dense_or_least_pos (D := (D : Type))).resolve_left h

theorem translationFrame_isDiscrete (D : TemporalOrder) {u : (D : Type)}
    (hu : IsLeast {z : (D : Type) | 0 < z} u) :
    (translationFrame D).toTaskFrame.IsDiscrete :=
  fun x _ => ⟨x + u, isLeast_succ_of_isLeast_pos hu x⟩

-- the paper's own `⊭_D` shape
example (D : TemporalOrder) (φ : Formula)
    (hfail : ¬ (translationFrame D).toTaskFrame.ValidOn φ) :
    ¬ ∀ F : FrameOver D, F.toTaskFrame.ValidOn φ :=
  fun h => hfail (h (translationFrame D))

-- the bare Discrete class
example (D : TemporalOrder) {u : (D : Type)} (hu : IsLeast {z : (D : Type) | 0 < z} u)
    (φ : Formula) (hfail : ¬ (translationFrame D).toTaskFrame.ValidOn φ) :
    ¬ ValidOnFrames (fun F : TaskFrame => F.IsRegular ∧ F.IsDiscrete) φ :=
  fun h => hfail (h _ ⟨inferInstance, translationFrame_isDiscrete D hu⟩)

-- the concrete instantiation, and the non-collision with `Sat .ZTime`
noncomputable abbrev lexZOrder : TemporalOrder := TemporalOrder.of (ℤ ×ₗ ℤ)

example : IsLeast {z : (lexZOrder : Type) | 0 < z} (toLex ((0 : ℤ), (1 : ℤ))) :=
  LexInt.isLeast_pos

example : ¬ Archimedean (lexZOrder : Type) := LexInt.not_archimedean

example : ¬ (translationFrame lexZOrder).toTaskFrame.IsZTime := by
  rintro ⟨so, -, hsa, -⟩
  exact LexInt.not_archimedean (@archimedean_of_succ (ℤ ×ₗ ℤ) _ _ _ so _ hsa)
```

### Searches and probes run

- `lean_local_search`: `ValidOnFrames`, `archimedean_iff_nat_lt`, `isDiscrete_of`,
  `not_archimedean`. Index reported `warming` throughout, so empty results were not treated as
  proof of absence; every absence claim in this report is backed by a `grep` sweep instead.
- `lean_run_code`: five probes — the order lemma alone; the Z1 countermodel (three iterations:
  `rintro` binder shape, then `add_lt_add_right` argument order, then green); the UZ countermodel
  (two iterations: `le_or_lt`/`sub_zsmul`, then green); the frame-property and corollary glue; the
  four hypothesis entry points.
- `grep` sweeps over `FormalSystem/` for `translationFrame`, `ValidOn`, `IsDiscrete`, `Axiom.z1`,
  `tr_ne_untl`, `sorry`-shaped declarations, and the `Axiom` constructor list.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem` → `sorry_count: 0`, empty inventory.
- `bash .claude/scripts/lake-build-guard.sh result` → `state=complete`, `exit_status=0`,
  `end_epoch=1792012413` (at HEAD `c77645f8d`, before this dispatch's `dispatch_start_ts`
  `1792013342`).

### Paper references

- `prop:archimedean`, statement: `possible_worlds.tex:3170`.
- `prop:archimedean`, proof: `possible_worlds.tex:3174`–`3193`; `% PORT:` marker at `:3174`.
- Consumers of the proposition in the paper: `:1485` (the `DF`-versus-`UZ`/`Z1` contrast) and
  `:3772` (the ℤ-time pinning of `TM_z`'s soundness class).
- Rendering convention for a ported proof: `\leanproof{\texttt{<theorem name>}}`, used 29 times in
  the file (e.g. `:3165` for `validOn_df_iff_isDiscrete`).
