# Research Report: Task #900

**Task**: 900 - Bridge: ZTime-valid L formulas yield TM-plus theorems under PlusFormula substitution
**Started**: 2026-11-12T03:14:30Z
**Completed**: 2026-11-12T03:24:00Z
**Effort**: Small-to-medium — one new Metalogic module (~120 lines of proof + docstring), one
one-line relocation in an Expressiveness module, one regenerated library root. Both proof bodies
are already compiled and recorded verbatim below, so the implementation phase is transcription
plus siting, not discovery.
**Dependencies**: Task 899 (COMPLETED) — no live dependency on its artifacts was needed; every
ingredient of this bridge is already landed.
**Sources/Inputs**:
- Codebase: `FormalSystem/PlusLanguage/Substitution.lean`, `FormalSystem/Metalogic/StrongCompleteness.lean`, `FormalSystem/Semantics/Validity.lean`, `FormalSystem/Semantics/IntTransfer.lean`, `FormalSystem/Semantics/Truth.lean`, `FormalSystem/Metalogic/Expressiveness/Separation/{Defs,SemanticBridge}.lean`, `FormalSystem/Metalogic/{AuxiliaryAtoms,ZTimeProvability}.lean`
- Compiled gates: `scripts/check-metalogic-cycles.sh`, `scripts/measure-refactor-partitions.py` (`LANGUAGE_FILE_LAYERS`), `scripts/check-module-invariants.sh` (C6, C14/C15)
- lean-lsp MCP: `lean_run_code` (4 compile probes), `lean_local_search`
- Literature source (held, read this session): M. Reynolds, *An Axiomatization of Full Computation Tree Logic*, JSL 66(3), 2001 — `/home/benjamin/Projects/Literature/sources/reynolds_2001/` (markdown extraction + `Reynolds_2001_Axiomatization_Full_CTL_star.pdf` for page numbers)
**Artifacts**:
- specs/900_linear_ztime_validity_tm_plus_substitution_bridge/reports/01_ztime-validity-tm-plus-substitution-bridge.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The task's named home for the bridge is blocked by a compiled gate.**
  `FormalSystem/PlusLanguage/Substitution.lean` is **layer 0** in `LANGUAGE_FILE_LAYERS`
  (`scripts/measure-refactor-partitions.py`). Measured: adding
  `import FormalSystem.Metalogic.StrongCompleteness` there makes `scripts/check-metalogic-cycles.sh`
  Assertion B fail (`SURPLUS … Substitution -> …StrongCompleteness`, exit 1); adding
  `import FormalSystem.Semantics.Validity` fails Assertion B *and* Assertion C
  (`SYNTAX->SEMANTICS`, exit 1). Baseline is exit 0. The bridge must be sited in a layer-3
  Metalogic module; `FormalSystem/PlusLanguage/Substitution.lean` stays untouched.
- **Both deliverables are already proved.** The two-step bridge and the box-free linear corollary
  both compile sorry-free, measured axiom profile `[propext, Classical.choice, Quot.sound]` (the
  repo's `pcq` baseline). The complete proof bodies are transcribed in Findings below.
- **The linear fragment already exists in the tree** as `IntStructure` (a valuation
  `Atom → Set ℤ`, i.e. a bi-infinite Z-word) and `IntTruth`, in
  `FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean`. What was missing is the bridge
  from `IntTruth` to task-frame `TruthAt`; no such bridge existed anywhere in the tree. It is a
  clean structural induction, because `TruthAt`'s `untl`/`snce` clauses are history-internal and
  `box` is its only history-quantifying clause.
- **Recommended approach**: one new module `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean`
  at the Metalogic root, beside `AuxiliaryAtoms.lean` and `ZTimeProvability.lean`, with a
  gate-verified four-import set; plus relocating `isBoxFree` one file down, from
  `Separation/SemanticBridge.lean` to `Separation/Defs.lean`, so the bridge's import closure does
  not pull in `Expressiveness.Table`/`MonadicFO`.
- **Fidelity note**: Reynolds' linear reasoning is over **ω-sequences** (one-sided, `G`/`X`); this
  bridge is over **bi-infinite Z-words** (two-sided, `U` and `S`). That asymmetry is the whole
  point of the two-sided transposition and must be stated in the module docstring, not elided.

## Context & Scope

Researched: where the two-step bridge can legally live; whether each of its two steps already
exists; what the box-free "linear fragment" means in this tree's existing vocabulary; and whether
both statements are provable with the landed API. Compiled probes were run for every load-bearing
claim.

Not researched (out of scope): the Reynolds automaton construction itself, the ban/lull mechanism,
or the determinization obstruction — those are the subject of the companion paper-proof and
no-go reports and are untouched by this bridge.

Territory: this dispatch wrote only inside
`specs/900_linear_ztime_validity_tm_plus_substitution_bridge/`. Two temporary probe mutations were
made under `FormalSystem/` (an import line in `Substitution.lean`; a four-line candidate module at
`Metalogic/ZTimeSubstitutionBridge.lean`) and both were reverted —
`git status --short FormalSystem/` is empty. The concurrent sibling's declared file scope
(`specs/901_…/reports/01_….md`, `specs/905_…/issues.jsonl`) was deliberately not read, to avoid
relying on a mid-edit state; the Reynolds primary source was read instead, which H3 prefers anyway.

## Literature Proof Structure

**Source**: M. Reynolds, *An Axiomatization of Full Computation Tree Logic*, Journal of Symbolic
Logic 66(3), 2001, §9 and §13.2 / §15.
**Strategy**: prove a fact about linear sequences **semantically**, then convert it into a theorem
of the branching system by invoking **PLTL completeness** (written `⊢_L`), and consume that theorem
inside the branching-time consistency and chronicle arguments.

### Step Map

1. Fix a `K_C`-consistent CTL\* formula `φ`; introduce three languages — `φ`'s own CTL\* language,
   a PLTL language, and an extended CTL\* language with fresh atoms `Q` — [Reynolds 2001] §9,
   p. 1026ff.
2. Build the automaton `A` and the formulas `χ₀`, `χ₁`, `θ_A`; `χ₁` holds at a fullpath `b` iff
   `A` accepts `b` iff `b` is bad — [Reynolds 2001] §9, p. 1030.
3. **Claim 1** — the linear step: `⊢_L (χ₁ ∧ s₀ ∧ G⋀_{s∈Q, c⊆ecl φ}(s ∧ ĉ → X p(s,c)) ∧
   G⋀_{r≠s∈Q}¬(r ∧ s)) → ¬χ₀`. Proved by taking an arbitrary ω-sequence `a` of subsets of
   `ecl φ ∪ Q`, running `A` on it, and showing by induction on `i` that the fresh state letters
   track the run — [Reynolds 2001] Lemma 7, Claim 1, p. 1030. **The theorem-hood of this linear
   validity is supplied by PLTL completeness, nothing else.**
4. **Claim 2** — `⊢ K_0 ∧ ¬Eχ₁`: C9, C11, C14 plus simple PLTL reasoning reduce the branching
   statement to the antecedent of Claim 1, and Claim 1 is then cited as a PLTL theorem —
   [Reynolds 2001] Lemma 7, Claim 2, p. 1030.
5. **Lemma 7** — if `φ` is consistent then so is `φ⁺ = θ_A ∧ χ₀ ∧ ¬Eχ₁`, via Claims 1–3 —
   [Reynolds 2001] Lemma 7, p. 1030.
6. **Lemma 17** — ban preservation: for hues `h, h' ∈ H(φ⁺)` and banning conditions `B, B'`, if
   `h' ∈ P_n(h, B)` and `B'` extends `B` by pairs whose hue avoids `V_p` and meets `U_q`, then
   `⊢ ŷ_{h'} → ¬E¬ζ_{B'}`. The LC consumer — [Reynolds 2001] Lemma 17, p. 1043.
7. **Lemma 23** — `⊢ φ → (χ₀ ∨ Eζ_B)`, the fair-scheduling/truth-lemma step — [Reynolds 2001]
   Lemma 23, p. 1050.

### Dependencies

- Step 4 depends on Step 3 (Claim 2 cites Claim 1 as a PLTL theorem).
- Step 5 depends on Steps 3 and 4.
- Steps 6 and 7 depend on Step 5 and re-use the same linear-to-branching import pattern.

### Potential Formalization Challenges

- **Step 3 (the one this task formalizes)**: Reynolds' `⊢_L` is PLTL over **ω-sequences** —
  one-sided, future-only, `G`/`X`-based. This development's linear fragment is over **bi-infinite
  Z-words** with both `U` and `S`. The transposition therefore needs `completeness_ztime` (a
  two-sided ℤ engine), not a PLTL engine, and the linear semantics must be the two-sided
  `IntStructure`/`IntTruth` pair, not an ω-word semantics. No ω-word semantics exists in this
  tree, and none should be added for this purpose.
- **The substituted arguments**: Reynolds substitutes state formulas `ŝ` and fresh state letters
  for PLTL sentence letters. Here `substPlus σ` carries each L atom to an arbitrary
  `PlusFormula` — so `⊡`-headed (stab-headed) arguments and fresh atoms both land, which is
  exactly the shape Steps 4, 6 and 7 consume.
- **Steps 4, 6, 7 are not in this task's scope** and are blocked elsewhere (determinization); the
  bridge is their prerequisite, not their formalization.

### Lemma-Level Mapping Table (H3 Tier 1)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|---------------|-----------------|----------------|--------|
| [Reynolds 2001] | Lemma 7, Claim 1, p. 1030 (the `⊢_L` step itself) | `FormalSystem.Metalogic.plusDerivable_substPlus_of_validZTime` | `∀ {φ : Formula} (σ : Atom → PlusFormula), ValidZTime φ → PlusDerivable FrameClass.ZTime [] (substPlus σ φ)` | transcribed (compiled in probe; not yet landed) |
| [Reynolds 2001] | Lemma 7, Claim 1, p. 1030 (its linear-semantics half) | `FormalSystem.Metalogic.plusDerivable_substPlus_of_boxFree_intTruth` | `∀ {φ : Formula} (σ : Atom → PlusFormula), isBoxFree φ = true → (∀ (W : IntStructure) (t : ℤ), IntTruth W t φ) → PlusDerivable FrameClass.ZTime [] (substPlus σ φ)` | transcribed (compiled in probe; not yet landed) |
| [Reynolds 2001] | Lemma 7, Claim 1, p. 1030 (supporting truth lemma) | `FormalSystem.Metalogic.truthAt_iff_intTruth_of_boxFree` | `∀ {F : FrameOver intOrder} [F.IsRegular] (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (φ : Formula), isBoxFree φ = true → ∀ t : ℤ, TruthAt M τ t φ ↔ IntTruth (wordOf M τ) t φ` | transcribed (compiled in probe; not yet landed) |
| [Reynolds 2001] | Lemma 7, Claim 2, p. 1030 | — (consumer; not in this task) | — | pending |
| [Reynolds 2001] | Lemma 17, p. 1043 | — (consumer; not in this task) | — | pending |
| [Reynolds 2001] | Lemma 23, p. 1050 | — (consumer; not in this task) | — | pending |

Sorry-inventory cross-reference: every row marked `transcribed` was compiled with
`#print axioms` showing `[propext, Classical.choice, Quot.sound]` and **no** `sorryAx`. There are
no `sorry` rows, so the inventory for this task is empty.

## Findings

### Codebase Patterns

**Step 1 of the bridge is already a one-liner over landed API.**
`FormalSystem/Metalogic/SetConsequence.lean` defines
`WeakCompleteness fc := ∀ ψ, ValidIn fc ψ → Derivable fc [] ψ`, and
`FormalSystem/Metalogic/StrongCompleteness.lean` proves
`completeness_ztime : WeakCompleteness FrameClass.ZTime`. `ValidZTime := ValidIn .ZTime`
(`FormalSystem/Semantics/Validity.lean:638`) is a plain abbreviation, so `completeness_ztime φ h`
applies to a `ValidZTime` hypothesis with no transport.
`FormalSystem/PlusLanguage/Substitution.lean:229` already supplies the other half:
`plusDerivable_substPlus_nil σ : Derivable fc [] φ → PlusDerivable fc [] (substPlus σ φ)`.
Verification method: `lean_run_code`, both forms (`ValidZTime` and the generic
`ValidIn FrameClass.ZTime`) compiled with zero diagnostics. **Confidence: High** — two independent
sources agree (the read declarations and a successful compile).

**`FormalSystem/PlusLanguage/Substitution.lean` cannot host the bridge.** The module is layer 0 in
`LANGUAGE_FILE_LAYERS` (`scripts/measure-refactor-partitions.py:194`: `"Substitution": 0`), which
`scripts/check-metalogic-cycles.sh` Assertions B and C both police. Measured results below under
Recommendations. Note the module's own docstring claim — "Nothing under
`FormalSystem/PlusLanguage/` imports anything from `FormalSystem/Semantics/`" — is **overbroad as
written**: 12 of the 17 modules in that directory are layer 1 and several do import
`FormalSystem.Semantics.*` (`PlusTruth.lean`, `PlusValidity.lean`, `PlusDeterminism.lean`,
`PlusIntTransfer.lean`, `PlusLimitClosure.lean`, `PlusRayFibre.lean`, `PlusReversal.lean`). The
invariant that actually holds, and that the gate enforces, is the per-*file* one: no layer-0 file
of a language directory imports a semantics file. Verification method: `grep "^import"` across all
17 files plus the layer table. **Confidence: High.**

**The linear fragment already has a semantics in this tree, and it is two-sided.**
`FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean:41` defines
`structure IntStructure where val : Atom → Set ℤ` — GHR94's linear temporal structure at `T = ℤ`,
i.e. precisely a bi-infinite Z-word — and `:50` defines `IntTruth` with honest strict `untl`/`snce`
clauses over `ℤ`. `Defs.lean` imports only `FormalSystem.Syntax.Formula` and two Mathlib order
files, so it is very light. `isBoxFree : Formula → Bool` lives one file up, in
`Separation/SemanticBridge.lean:43`. Verification method: direct read of both files plus
`grep "^import"`. **Confidence: High.**

**No `IntTruth` ↔ `TruthAt` bridge existed.** `grep -rl IntTruth` returns seven files; the only
existing bridge, `int_truth_eq_temporal_truth_Z` (`SemanticBridge.lean:57`), connects `IntTruth` to
`TemporalTruth` on an `OrderedMonadicStructure`, not to task-frame `TruthAt`. The rest of the hits
are the verified-tableau `Bridge/IntTruth.lean` cluster, which is a different `branchTruthAt`
object. Verification method: `grep -rn IntTruth` filtered for `TruthAt|TaskModel|Valid`; nothing
matched. **Confidence: High** — `lean_local_search` was also consulted for the companion names, but
note its `index` field reported `warming` on the one call made, so that call alone is not proof of
absence; the grep sweep is the evidence of record here.

**Why the box-free truth lemma is a clean induction.** `FormalSystem/Semantics/Truth.lean:232`
gives `TruthAt` six clauses; `untl`/`snce` quantify over `F.Duration` **on the same history** `τ`,
and `box φ => ∀ σ : WorldHistory F, TruthAt M σ t φ` is the only clause that leaves `τ`. So for a
box-free formula, truth at `(M, τ, t)` is a function of the ℤ-indexed valuation trace of `τ` —
which is what `wordOf` packages. Verification method: direct read of the definition plus a
successful compile of the induction. **Confidence: High.**

**Carrier normalization closes the gap to `ValidZTime`.**
`FormalSystem/Semantics/IntTransfer.lean:338` proves
`validZTime_iff_validInt : ValidZTime φ ↔ ValidInt φ`, where
`ValidInt φ := ∀ (F : FrameOver intOrder) [F.IsRegular] (M) (τ) (t : ℤ), TruthAt M τ t φ`
(`:315`). So the box-free corollary needs no reasoning about arbitrary discrete carriers; it
rewrites to the single carrier `ℤ` and applies the truth lemma. Verification method: read plus
compile. **Confidence: High.**

**Thematic neighbours for siting.** `FormalSystem/Metalogic/AuxiliaryAtoms.lean` is the landed
Reynolds Auxiliary-Atoms rule module (903 lines; `aa_sound_ztime`, `aa_reflectTime_sound_ztime`),
and `FormalSystem/Metalogic/ZTimeProvability.lean` is the landed ℤ-time provability module
(`derivable_iff_validZTime`, `decidableDerivableZTime`). Both are Metalogic-root files, both at
layer 3, and both are the natural neighbours of this bridge: `AuxiliaryAtoms.lean` supplies the
*soundness* half of the Reynolds rule machinery, this bridge supplies the *derivability* import
route. Verification method: direct read of both headers and declaration lists. **Confidence: High.**

### External Resources

- **Mathlib**: nothing needed. The bridge is entirely over this repository's own API; the only
  Mathlib contact is `imp_congr`, already available. No Mathlib search was required, and none is
  claimed.
- **Reynolds 2001**: held locally at `/home/benjamin/Projects/Literature/sources/reynolds_2001/`
  (14 markdown section files plus the PDF). The markdown extraction's OCR is degraded in the
  formula bodies — `χ`, `⊢`, subscripts and set-builder braces are unreliable — but lemma
  numbering, prose and proof structure are legible, and the PDF supplied the page numbers quoted
  above. Load-bearing use here is confined to the proof *structure* of Lemma 7 Claim 1 and the
  fact that its theorem-hood comes from PLTL completeness; both are legible in the prose and
  corroborated by the Claim 2 passage, which cites Claim 1 as `⊢_L`.
- **`references.bib:185`** carries the BibKey `reynolds2001`; `specs/literature/README.md:187`
  records that "Reynolds 2003" in older notes should read **Reynolds 2001** (JSL 66(3)) — so
  citations in the new module's docstring should use `reynolds2001`.

### Recommendations

1. **Do not touch `FormalSystem/PlusLanguage/Substitution.lean`; site the bridge in a new
   Metalogic-root module `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean`, namespace
   `FormalSystem.Metalogic`, with exactly these four imports:**
   `FormalSystem.Metalogic.StrongCompleteness`, `FormalSystem.PlusLanguage.Substitution`,
   `FormalSystem.Semantics.IntTransfer`,
   `FormalSystem.Metalogic.Expressiveness.Separation.Defs`.
   [VERIFIED: PASS — wrote that exact four-import stub to
   `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean` and ran
   `bash scripts/check-metalogic-cycles.sh`: all three assertions PASS, exit 0 ("exactly 1
   directory-level import cycle"; "upward import set is exactly the recorded 10 line(s)"; "no
   language-directory syntax module imports a semantics module"). Probe file removed;
   `git status --short FormalSystem/` empty. A variant substituting
   `Metalogic.BXCanonical.Completeness` for `StrongCompleteness`, and a variant importing
   `Separation.SemanticBridge` instead of `Separation.Defs`, were each also run and also exit 0 —
   so the gate does not force the choice between them.]

2. **Reject the task description's stated location.** Putting the bridge in
   `FormalSystem/PlusLanguage/Substitution.lean` is not merely stylistically wrong; it fails a
   compiled gate.
   [VERIFIED: FAIL — added `import FormalSystem.Metalogic.StrongCompleteness` to
   `FormalSystem/PlusLanguage/Substitution.lean` and ran `bash scripts/check-metalogic-cycles.sh`:
   `SURPLUS FormalSystem.PlusLanguage.Substitution -> FormalSystem.Metalogic.StrongCompleteness`,
   `FAIL upward import set is not the recorded allowlist (1 surplus, 0 shortfall)`, exit 1.
   Replaced it with `import FormalSystem.Semantics.Validity` and re-ran: the same SURPLUS plus
   `SYNTAX->SEMANTICS FormalSystem.PlusLanguage.Substitution -> FormalSystem.Semantics.Validity`
   and `FAIL syntax before semantics: 1 import line(s)`, exit 1. Baseline (unmodified tree) exit 0.
   File reverted from a scratchpad copy; `git status --short FormalSystem/` empty.
   **Revised to**: recommendation 1 above — land the bridge in a layer-3 Metalogic module and
   leave `Substitution.lean` unchanged, since `plusDerivable_substPlus_nil` is already exactly the
   piece of it the bridge needs and requires no edit.]

3. **Relocate `isBoxFree` from `Separation/SemanticBridge.lean` to `Separation/Defs.lean`** (a
   pure move, no signature change), so the bridge imports `Separation.Defs` rather than
   `Separation.SemanticBridge` and its closure excludes `Expressiveness.Table` and
   `Expressiveness.MonadicFO`. `SemanticBridge.lean` imports `Separation.Defs`, so every existing
   `isBoxFree` call site in it keeps resolving with no further edit.
   [VERIFIED: PASS — `lean_run_code` with imports
   `{Metalogic.StrongCompleteness, PlusLanguage.Substitution, Semantics.IntTransfer,
   Metalogic.Expressiveness.Separation.Defs}` and `isBoxFree` re-declared in the
   `…Separation` namespace (standing in for the relocated definition) compiled the whole chain
   with zero errors; `#print axioms` on both headline theorems reported
   `[propext, Classical.choice, Quot.sound]`. `Separation/Defs.lean` already imports
   `FormalSystem.Syntax.Formula`, which is all `isBoxFree` needs. The gate was separately run
   against the `Separation.Defs` import variant: exit 0.]

4. **Land these four declarations, in this order, with these exact bodies** (all compiled; the
   plan's `## Lean Challenge Statements` section should pin these signatures verbatim):

   ```lean
   /-- The bi-infinite Z-word read off a model and a world history over the carrier `ℤ`. -/
   def wordOf {F : FrameOver intOrder} [F.IsRegular] (M : TaskModel F.toTaskFrame)
       (τ : WorldHistory F.toTaskFrame) : IntStructure where
     val a := { t : ℤ | M.valuation (τ.state t) a }

   /-- Box-free truth is a datum of the Z-word alone. -/
   theorem truthAt_iff_intTruth_of_boxFree {F : FrameOver intOrder} [F.IsRegular]
       (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) :
       ∀ (φ : Formula), isBoxFree φ = true → ∀ t : ℤ,
         (TruthAt M τ t φ ↔ IntTruth (wordOf M τ) t φ) := by
     intro φ
     induction φ with
     | atom a => intro _ t; exact Iff.rfl
     | bot => intro _ t; exact Iff.rfl
     | imp φ ψ ih1 ih2 =>
       intro hbf t
       simp only [isBoxFree, Bool.and_eq_true] at hbf
       exact imp_congr (ih1 hbf.1 t) (ih2 hbf.2 t)
     | box _ _ => intro hbf; simp [isBoxFree] at hbf
     | untl ψ φ ih1 ih2 =>
       intro hbf t
       simp only [isBoxFree, Bool.and_eq_true] at hbf
       constructor
       · rintro ⟨s, hts, hs, hmid⟩
         exact ⟨s, hts, (ih2 hbf.1 s).mp hs, fun r h1 h2 => (ih1 hbf.2 r).mp (hmid r h1 h2)⟩
       · rintro ⟨s, hts, hs, hmid⟩
         exact ⟨s, hts, (ih2 hbf.1 s).mpr hs, fun r h1 h2 => (ih1 hbf.2 r).mpr (hmid r h1 h2)⟩
     | snce ψ φ ih1 ih2 =>
       intro hbf t
       simp only [isBoxFree, Bool.and_eq_true] at hbf
       constructor
       · rintro ⟨s, hst, hs, hmid⟩
         exact ⟨s, hst, (ih2 hbf.1 s).mp hs, fun r h1 h2 => (ih1 hbf.2 r).mp (hmid r h1 h2)⟩
       · rintro ⟨s, hst, hs, hmid⟩
         exact ⟨s, hst, (ih2 hbf.1 s).mpr hs, fun r h1 h2 => (ih1 hbf.2 r).mpr (hmid r h1 h2)⟩

   /-- A box-free formula true on every bi-infinite Z-word is `ZTime`-valid. -/
   theorem validZTime_of_boxFree_intTruth {φ : Formula} (hbf : isBoxFree φ = true)
       (h : ∀ (W : IntStructure) (t : ℤ), IntTruth W t φ) : ValidZTime φ := by
     rw [validZTime_iff_validInt]
     intro F _ M τ t
     exact (truthAt_iff_intTruth_of_boxFree M τ φ hbf t).mpr (h _ t)

   /-- **The bridge.** A `ZTime`-valid L formula yields a TM⁺ theorem at every substitution. -/
   theorem plusDerivable_substPlus_of_validZTime {φ : Formula} (σ : Atom → PlusFormula)
       (h : ValidZTime φ) : PlusDerivable FrameClass.ZTime [] (substPlus σ φ) :=
     plusDerivable_substPlus_nil σ (completeness_ztime φ h)

   /-- **The corollary.** Linear validity over bi-infinite Z-words yields TM⁺ theorems at every
   substitution. -/
   theorem plusDerivable_substPlus_of_boxFree_intTruth {φ : Formula} (σ : Atom → PlusFormula)
       (hbf : isBoxFree φ = true) (h : ∀ (W : IntStructure) (t : ℤ), IntTruth W t φ) :
       PlusDerivable FrameClass.ZTime [] (substPlus σ φ) :=
     plusDerivable_substPlus_of_validZTime σ (validZTime_of_boxFree_intTruth hbf h)
   ```

   Note the arm order in `isBoxFree`: its `untl`/`snce` arms read
   `isBoxFree φ && isBoxFree ψ`, i.e. the *second* constructor argument first, which is why
   `hbf.1` feeds `ih2` and `hbf.2` feeds `ih1` above.
   [VERIFIED: PASS — compiled as a single `lean_run_code` snippet (both the
   `Separation.SemanticBridge` and the relocated-`isBoxFree` variants):
   `{"success": true, "timed_out": false}` with the only diagnostics being the two requested
   `#print axioms` info lines, `[propext, Classical.choice, Quot.sound]` for both headline
   theorems. No `sorryAx`, no warnings, no `declaration uses 'sorry'`.]

5. **Regenerate the library root in the same phase that adds the module.** C6 in
   `scripts/check-module-invariants.sh` fails on any live module unreachable from a Lake target
   root, and `FormalSystem.lean` (755 import lines) is generated by
   `lake exe mk_all --lib FormalSystem` and committed. Adding a module without regenerating it
   leaves the module out of every build closure.
   [No compiled gate applicable — the C6 obligation was read off
   `scripts/check-module-invariants.sh` (C6 narrative at lines 27, 114, 764, 1421-1459) and
   `scripts/module-invariants-manifest.txt`'s header rather than measured, because measuring it
   requires actually landing the module, which this research dispatch must not do.]

6. **Add four `docs/theorem-index.md` rows** (one per landed theorem, plus `wordOf` if the
   convention covers definitions) with Paper label `—` or a `reynolds2001`-anchored label as the
   paper-definitions record allows, Frame class `ZTime`, and Axioms cell `pcq pinned:C14`.
   `docs/theorem-index.md`'s own "How to read a row" fixes `pcq` as exactly
   `[propext, Classical.choice, Quot.sound]`, which is the measured profile; C15's second
   assertion requires every row be anchored at its declaration, and the Lean name must be fully
   qualified.
   [No compiled gate applicable — the row text does not exist yet, so there is nothing for C14/C15
   to decide; the *axiom value* the row will carry is, however, measured (see recommendation 4).]

7. **State the ω-word / Z-word asymmetry explicitly in the module docstring**, citing
   [Reynolds 2001] Lemma 7 Claim 1, p. 1030: Reynolds' `⊢_L` is PLTL over one-sided ω-sequences
   with `G`/`X`, whereas this bridge runs `completeness_ztime` over two-sided bi-infinite Z-words
   with `U` and `S`. Do not describe the module as "the PLTL bridge"; it is the two-sided
   transposition of that step.
   [No compiled gate applicable — a docstring-content recommendation; no predicate in the
   codebase decides its acceptance.]

## Decisions

- **Host module**: a new Metalogic-root file rather than appending to `ZTimeProvability.lean` or
  `AuxiliaryAtoms.lean`. Reason: `ZTimeProvability.lean` is tightly scoped to decidability (it
  pulls the whole `Decidability/WitnessFamily/Compression/Assembly` closure, which this bridge
  does not need), and `AuxiliaryAtoms.lean` is 903 lines of soundness machinery for one rule. Both
  alternatives were checked for import weight; neither is a better fit than a fresh 120-line
  module. The gate accepts the fresh module (recommendation 1).
- **Completeness engine**: use `completeness_ztime` (`Metalogic.StrongCompleteness`), as the task
  description names, rather than the more primitive `BXCanonical.derivable_of_validZTime`. The
  gate accepts both (both variants measured exit 0), so description fidelity decides. Recorded as a
  deliberate choice, not an oversight: `derivable_of_validZTime` would shrink the import closure
  slightly, and a planner may revisit it on that ground, but it is a different declaration from the
  one the task names.
- **Linear semantics**: reuse the existing `IntStructure`/`IntTruth` pair rather than defining a
  fresh Z-word semantics in the bridge module. Reason: one linear semantics in the tree, and
  reuse keeps the door open to composing existing Separation results (e.g.
  `int_truth_eq_temporal_truth_Z`) with the bridge. The cost is the dependency on `IntTruth`'s
  degenerate `box` arm — see Risks.
- **`isBoxFree` relocation** rather than duplication. Duplicating a syntactic predicate that
  already exists would create two names for one concept and invite drift.

## Risks & Mitigations

- **`IntTruth`'s `box _ => True` arm makes it an unsound semantics for box-containing formulas.**
  `Separation/Defs.lean:50` documents this as deliberate ("degenerate: modal not relevant for
  separation"). Consequence: `validZTime_of_boxFree_intTruth`'s `isBoxFree` hypothesis is
  **load-bearing, not cosmetic** — without it the statement is false, since `IntTruth W t (□⊥→⊥)`
  would hold on every word while `□⊥→⊥` is not `ZTime`-valid in general. Mitigation: the
  hypothesis must never be weakened, defaulted, or discharged by a `simp` lemma; the module
  docstring should say so in one sentence, and the plan's Challenge Statements section should pin
  the signature so a same-named weaker restatement is caught.
- **Import-closure weight.** `Metalogic.StrongCompleteness` is a heavy import (it reaches
  `BXCanonical.CompletenessDedekind`). Any later consumer of this bridge inherits it. Mitigation:
  keep the bridge module small and single-purpose so a future split into a light
  `derivable_of_validZTime`-based core and a `completeness_ztime`-named alias stays cheap.
- **New-module bookkeeping is easy to forget.** A new `FormalSystem/` module needs the
  regenerated `FormalSystem.lean` (C6), a copyright header (`check-copyright-headers.sh`),
  `docs/theorem-index.md` rows (C15), and C14 axiom pins. Mitigation: make these explicit plan
  steps rather than a wrap-up afterthought; the measured axiom value for the pins is already in
  hand.
- **Concurrency.** A sibling task is dispatched this same cycle on this working tree. Its declared
  scope is two `specs/**` files, disjoint from everything this task will touch, so the risk is
  low; but the implementation phase should re-read `FormalSystem.lean` immediately before
  regenerating it, and stage only this task's own files.
- **The Reynolds markdown extraction's formula OCR is unreliable.** Mitigation: every quantitative
  citation in this report was taken from the PDF (`pdftotext -layout`), and the load-bearing use
  of the source is structural rather than formula-level. Any future step that needs Claim 1's
  formula verbatim must read the PDF, not the markdown.

## Adversarial Self-Verification

- **Claim: "`Substitution.lean` is layer 0 and the gate rejects the import."** Checked against two
  independent sources: the layer table (`scripts/measure-refactor-partitions.py:194`, read
  directly) and the gate's measured verdict (two separate runs, exit 1 each, with distinct
  failure lines for the Metalogic and Semantics variants). Baseline exit 0 establishes the gate
  was not already failing. Confidence: High.
- **Claim: "both deliverables compile sorry-free."** Checked by four `lean_run_code` runs: step 1
  alone (2 theorems, 0 diagnostics); the truth lemma alone (0 diagnostics); the full chain with
  `Separation.SemanticBridge` (`#print axioms` = pcq); the full chain with `isBoxFree` relocated
  (both `#print axioms` = pcq). `success: true` and `timed_out: false` on all four. Confidence:
  High — repeated, with two distinct import sets.
- **Claim: "no `IntTruth` ↔ `TruthAt` bridge exists."** Searched by `grep -rl IntTruth` (7 files,
  each inspected by name/context) and `grep -rn IntTruth | grep -i "truthAt|taskmodel|valid"`
  (5 hits, all prose references to the unrelated `Bridge/IntTruth.lean` `branchTruthAt`). A
  `lean_local_search` call was also made, but it reported `index: warming`, so per this dispatch's
  readiness contract its result is **not** proof of absence and is not relied on; the grep sweep
  is the evidence of record. Confidence: Medium-to-High — two search methods agree, but the
  LSP-backed method degraded, so this is the one finding where the evidence tier is a grep sweep
  rather than an index consultation.
- **Contradiction found and resolved**: `Substitution.lean`'s own docstring asserts "Nothing under
  `FormalSystem/PlusLanguage/` imports anything from `FormalSystem/Semantics/`", which conflicts
  with the measured import lines of seven sibling modules. Resolved by the precedence ranking
  (directly-read Lean source over stale comments): the per-file layer table and the measured
  imports win; the docstring's directory-wide phrasing is stale, and the invariant that holds is
  the per-file one. Downstream effect: none on this task's recommendations — the stale sentence
  and the live gate happen to agree about `Substitution.lean` itself. Flagged here so a future
  reader does not infer the whole directory is semantics-free.
- **Searched for conflicting evidence on the siting recommendation** by running the gate against
  three import-set variants (StrongCompleteness + Defs; BXCanonical.Completeness + Defs;
  StrongCompleteness + SemanticBridge). All three exit 0, so the gate does not discriminate among
  them and the choice rests on the task description and import weight, as recorded under
  Decisions. No conflicting evidence found.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `TruthAt M τ t φ ↔ IntTruth (wordOf M τ) t φ`, `atom`/`bot` arms | `exact Iff.rfl` | success | definitional — `wordOf`'s `val` field unfolds to the model valuation |
| same, `imp` arm | `simp only [isBoxFree, Bool.and_eq_true]` then `exact imp_congr …` | success | `imp_congr` (Mathlib core) |
| same, `box` arm | `simp [isBoxFree]` at the hypothesis | success | discharges by contradiction on `isBoxFree (.box _) = false` |
| same, `untl`/`snce` arms | `constructor` + `rintro ⟨s, h, h, h⟩` + explicit anonymous-constructor terms | success | both directions by hand; the two `IH`s applied at `s` and at `r` |
| `ValidZTime φ` from word-truth | `rw [validZTime_iff_validInt]` then `intro F _ M τ t` | success | `Semantics.validZTime_iff_validInt` |
| the two bridge theorems | direct term application, no tactic block | success | `completeness_ztime`, `plusDerivable_substPlus_nil` |

The survey was run against the real goals via `lean_run_code` rather than
`lean_multi_attempt`, because the declarations do not yet exist in any file and so have no source
position to attempt at. No automation tactic (`aesop`, `omega`, `decide`, `norm_num`) was tried:
none is applicable to an `Iff` over an inductively defined truth predicate, and the explicit
structural proof is also what literature-fidelity requires here — Reynolds' Claim 1 is an
explicit induction on the run index, and the Lean proof mirrors it as an induction on the formula.

## Context Extension Recommendations

- **Topic**: The `LANGUAGE_FILE_LAYERS` per-file layering of the language directories, and the
  `check-metalogic-cycles.sh` assertions that police it.
  **Gap**: `context/project/lean4/patterns/plan-authoring-gate-collisions.md` is the natural home
  for this, but nothing in the loaded context names this particular collision — that a task
  description can name a `PlusLanguage/` file as the home of a result whose ingredients live at
  layer 1 or 3, and that the collision is only discoverable by reading a Python layer table. This
  dispatch spent a meaningful fraction of its budget rediscovering it.
  **Recommendation**: add a short subsection to
  `context/project/lean4/patterns/plan-authoring-gate-collisions.md` recording the three-assertion
  shape of `scripts/check-metalogic-cycles.sh`, the location of `LANGUAGE_FILE_LAYERS`, the
  copy-pasteable probe used here (write the import, run the gate, read the `SURPLUS` /
  `SYNTAX->SEMANTICS` lines, revert), and the rule of thumb that a result combining a *syntactic*
  language-directory module with a *semantic* or *metalogical* one always belongs in the higher
  layer's directory.
- **Topic**: The stale directory-wide invariant sentence in
  `FormalSystem/PlusLanguage/Substitution.lean`'s docstring.
  **Gap**: not a context gap but a source-comment defect; recorded here because a future agent
  reading only that docstring would draw the wrong conclusion about the directory.
  **Recommendation**: a one-line docstring correction (replace the directory-wide claim with the
  per-file one and point at `LANGUAGE_FILE_LAYERS`) is a reasonable opportunistic fix for whichever
  task next edits that file — but note it is *not* in this task's scope, since this task's own
  recommendation is to leave `Substitution.lean` untouched.

## Appendix

### Compiled probes run (all via `lean_run_code`)

1. Step 1 alone, at both `Semantics.ValidZTime` and `Semantics.ValidIn FrameClass.ZTime` — 0
   diagnostics.
2. `wordOf` + `truthAt_iff_intTruth_of_boxFree` alone — 0 diagnostics.
3. Full chain, importing `Separation.SemanticBridge` —
   `#print axioms plusDerivable_substPlus_of_boxFree_intTruth` = `[propext, Classical.choice, Quot.sound]`.
4. Full chain, importing `Separation.Defs` with `isBoxFree` re-declared (relocation simulation) —
   `#print axioms` on both headline theorems = `[propext, Classical.choice, Quot.sound]`.

### Gate runs (`bash scripts/check-metalogic-cycles.sh`)

| Tree state | A (cycles) | B (upward set) | C (syntax→semantics) | Exit |
|---|---|---|---|---|
| baseline (unmodified) | PASS | PASS | PASS | 0 |
| `Substitution.lean` + `import Metalogic.StrongCompleteness` | PASS | **FAIL** (1 surplus) | PASS | **1** |
| `Substitution.lean` + `import Semantics.Validity` | PASS | **FAIL** (1 surplus) | **FAIL** (1 line) | **1** |
| new `Metalogic/ZTimeSubstitutionBridge.lean`, imports {StrongCompleteness, Substitution, IntTransfer, Separation.SemanticBridge} | PASS | PASS | PASS | 0 |
| same, with `Separation.Defs` instead of `Separation.SemanticBridge` | PASS | PASS | PASS | 0 |
| same, with `BXCanonical.Completeness` instead of `StrongCompleteness` | PASS | PASS | PASS | 0 |

All probe mutations reverted; `git status --short FormalSystem/` empty at report time.

### Search queries and reads

- `grep -rn "ofTMSubst|completeness_ztime|substPlus"` across `*.lean` — located the two halves of
  step 1.
- `grep -rni "boxfree|box_free|modalFree"` — located `isBoxFree`.
- `grep -rni "zword|bi-infinite"` — established that no Z-word *validity* predicate exists under
  that name; the object is `IntStructure`.
- `grep "^import"` across all 17 `FormalSystem/PlusLanguage/*.lean` — established the stale
  docstring claim.
- `grep -rl "import FormalSystem.PlusLanguage.Substitution"` — 4 importers, none in
  `StrongCompleteness`'s closure, so no cycle risk from the reverse direction.
- `mcp__lean-lsp__lean_local_search "derivable_of_validZTime"` — hit in
  `Metalogic/BXCanonical/Completeness.lean`; `index: warming` (see Adversarial Self-Verification).
- `pdftotext -layout` on `Reynolds_2001_Axiomatization_Full_CTL_star.pdf` (49 PDF pages) to recover
  journal page numbers 1030 / 1043 / 1050 for Lemma 7 (with Claims 1-2), Lemma 17 and Lemma 23.

### References

- `scripts/check-metalogic-cycles.sh` — assertions A/B/C and their rationale (lines 55-110).
- `scripts/measure-refactor-partitions.py` — `LANGUAGE_FILE_LAYERS` (line 188ff).
- `scripts/check-module-invariants.sh` — C6 reachability (lines 1421-1459), the
  `lake exe mk_all --lib FormalSystem` convention (line 764), C15 theorem-index anchoring
  (line 3082ff).
- `docs/theorem-index.md` — row format, the `pcq` abbreviation, the fully-qualified-name rule.
- M. Reynolds, *An Axiomatization of Full Computation Tree Logic*, JSL 66(3), 2001, pp. 1030, 1043,
  1050 (BibKey `reynolds2001`).
