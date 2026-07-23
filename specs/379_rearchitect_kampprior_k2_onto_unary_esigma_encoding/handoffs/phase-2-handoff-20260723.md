# Phase 2 Continuation Handoff — Foundational `Fintype`/`DecidableEq` field removal

- **Task**: 379 — rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Plan**: `plans/21_infinite-esigma-alphabet-optionA-v2.md`, Phase 2
- **Status**: `[PARTIAL]` — foundational core landed GREEN; downstream instance-threading cascade in progress
- **Session**: sess_1784829998_2462de
- **Date**: 2026-07-23

## What landed (proven GREEN, preserved as a patch)

The intellectually load-bearing part of Phase 2 is DONE and compiles green **scoped**. It is
preserved (working tree was reverted to keep HEAD green) in:

- **Patch**: `specs/379_.../handoffs/phase2-foundational-fintype-removal.patch`
- **Reapply**: `cd <repo-root> && git apply specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/handoffs/phase2-foundational-fintype-removal.patch`

The patch edits 6 files (all individually `lake build`-green when applied):

1. **`MonadicFO.lean`** — removed `[fintypePreds : Fintype preds]` / `[decEqPreds : DecidableEq
   preds]` instance fields (and their `attribute [instance]` lines) from `MonadicSignature`.
   Replaced the type's `deriving DecidableEq` (which silently needed `DecidableEq sig.preds`)
   with an explicit **conditional** instance `instDecidableEqMonadicFormula` guarded by
   `[DecidableEq sig.preds]` (full 36-case hand-rolled `DecidableEq (MonadicFormula sig n)`).
   Added `[Fintype sig.preds]` to `NormalFormIdx`.
   - **KEY INSIGHT for the whole refactor**: decidability is PRESERVED along the infinite E[Σ]
     path (Def 4.1's fresh summand `Formula` has `DecidableEq`), only `Fintype`-finiteness is
     genuinely lost. So `[DecidableEq sig.preds]` threading survives into Phase 3+; only
     `[Fintype sig.preds]` disappears when `sigE` goes infinite.
2. **`NormalForm.lean`** — threaded `[Fintype sig.preds] [DecidableEq sig.preds]` (or just
   `[DecidableEq sig.preds]` for `atomKind_decEq`) into: `atomKind_decEq`, `atomKind_fintype`,
   `normalForm_fintype_and_decEq`, `normalForm_fintype`, `normalForm_decEq`, `atomKind_card`,
   `normalForm_card`, `normalForm_equiv_fin`, `nf_to_formula`, `nf_to_formula_correct`,
   `nf_to_sentence`, `nf_to_sentence_correct`.
3. **`Kamp/ESigmaExpansion.lean`** — removed the `fintypePreds := inferInstance` /
   `decEqPreds := inferInstance` field assignments from `def sigE`; re-derived `sigE_fintypePreds`
   / `sigE_decEqPreds` / `finite_F_suffices_per_stage` as ordinary instances guarded by
   `[Fintype sig.preds] [DecidableEq sig.preds]` (via `inferInstanceAs (Fintype (sig.preds ⊕ …))`).
4. **`Separation/KampTranslation.lean`** — `[Fintype sig.preds]` into `nf_depth0_char_formula`,
   `nf_depth0_char_formula_correct`.
5. **`EFGames/Defs.lean`** — `[Fintype sig.preds] [DecidableEq sig.preds]` into `game_depth`,
   `game_depth_succ_ge_two`, `game_depth_strict_mono`, `game_depth_mono`, `stavi_n_equiv`,
   `stavi_n_equiv_symm`, `stavi_n_equiv_mono`. (`normalForm_nonempty` needs NO hyps — it only
   constructs elements.)
6. **`NEquivalence.lean`** — `[Fintype sig.preds] [DecidableEq sig.preds]` into the anonymous
   `instance … : KEquivalenceFramework sig`.

**Verification of landed core**: `lake build` for `Bimodal.Metalogic.WeakCanonical.MonadicFO`,
`.NormalForm`, `.Kamp.ESigmaExpansion`, `.Separation.KampTranslation`, `.EFGames.Defs`,
`.NEquivalence` all returned "Build completed successfully". `#print axioms` NOT yet re-checked
(full tree not green yet — see below).

## Why Phase 2 is PARTIAL, not COMPLETED

Phase 2's DoD requires **full `lake build` EXIT 0**. Removing the two structure fields is a
transitive instance-threading cascade across the entire abstract-`sig` `NormalForm`-`Fintype`
surface — far larger than the plan's "scoped to two files" rollback note (§Rollback/Contingency)
implied. The plan's Risk table DID anticipate the cascade ("foundational, expected consequence,
report 19 A2"); only the rollback estimate was optimistic.

**Cascade map (measured by successive full builds):**

- **Wave 1 (FIXED, green in patch)**: `ESigmaExpansion`, `KampTranslation`, `EFGames/Defs`,
  `NEquivalence` (+ foundational `MonadicFO`, `NormalForm`).
- **Wave 2 (surfaced, NOT yet fixed)** — 4 files, 56 error lines:
  - `EFGames/StaviCompleteness.lean` (41 errors; 60 declarations — the big one; consumes
    `game_depth`/`stavi_n_equiv` throughout)
  - `Kamp/IntervalType.lean` (5 errors; NOTE line ~109 is an "unsolved goals" **proof-repair**
    site, not just a missing-instance binder — needs actual attention, not pure mechanical
    threading; missing instances include `Fintype/DecidableEq (UnaryType sig F)`)
  - `Kamp/NfToVecEA.lean` (3)
  - `OrderedSum.lean` (2)
- **Wave 3+ (predicted from imports, NOT yet surfaced)**:
  - The IntervalType/UnaryType Kamp tree (~18 dependents): `ConjInterleave`, `EFSatNegation`,
    `EFSatNegationGeneral`, `ESigmaCapture`, `ExistsForallFormula`, `ExistsForallLemmas`,
    `LiftPair`, `Prop35Assembly`, `Prop35ExistsForall`, `Prop42ExistsForall`,
    `Prop42NegationGeneral`, `Prop43Translate`, `VeeSatNegation`, `VVecEA2Collapse`,
    `ZetaAtomMapReconcile`, `ZetaEngineClosure`, `ZetaUniformExtract`, `InfAlphabetProbe`,
    `OptionBLocalityProbe` (last two off-path but still need threading to build).
  - EFGames/Stavi dependents: `PriorExpressiveness`, `EFGames/CharacteristicFormula`,
    `WeakCanonical`, `Expressiveness/Claim1`.
  - Boneyard (may be excluded from the default build target; verify): `KampBypassArchive/*`,
    `StaviDiscretePath/*`.

Estimated total: ~30-40 files, ~200-400 declaration-binder edits, plus a handful of genuine
proof-repair sites (confirmed at least `IntervalType.lean:~109`). This is a multi-agent-run
mechanical cascade; it could not reach full green within one run, and Phase 2 cannot be committed
green until the WHOLE build passes (incremental-with-fallback constraint).

## Continuation recipe (for the next run)

1. `git apply` the patch above (restores the 6 green foundational files).
2. Grind the cascade wave-by-wave: `lake build`, collect `error:` files, for each failing
   declaration add `[Fintype sig.preds] [DecidableEq sig.preds]` (or just `[DecidableEq
   sig.preds]` where only decidability is needed) immediately after its `(sig : MonadicSignature)`
   / `{sig : MonadicSignature}` binder. Rebuild; repeat until green.
   - Mechanical rule of thumb: a decl needs the hyps iff it (transitively) touches
     `Fintype`/`Finset.univ`/`Fintype.card` over `AtomKind`/`NormalForm`/`KType`/`UnaryType`/
     `IntervalType`, or calls `game_depth`/`stavi_n_equiv`/`nf_to_formula`/the char-formula
     machinery, at an abstract `sig`. Concrete-signature call sites (`{preds := Fin 3}`,
     `{preds := Unit}`) need NOTHING (instances auto-derive).
   - Consider converting hot files that use per-decl `{sig : MonadicSignature}` binders to a
     `variable (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]` section
     header to cut edit volume — but only where the file consistently uses a single `sig`.
3. **Watch for genuine proof breaks** (not just missing instances) — e.g. `IntervalType.lean:~109`
   "unsolved goals", `KampTranslation.lean:160` "simp made no progress" (the latter likely
   auto-resolves once `Fintype` is in scope; the former may not). These are the only non-mechanical
   spots and must be repaired, not binder-threaded.
4. When full `lake build` is EXIT 0: verify `#print axioms completeness_discrete` is
   byte-identical to baseline (`[propext, sorryAx, Classical.choice, Lean.ofReduceBool,
   Lean.trustCompiler, Quot.sound]` — the `nf_nvar_exist_all_depths | _k+2` residual still
   present through Phase 4), confirm an infinite-alphabet signature is constructible
   (`#check` a `Formula`-indexed fresh summand), then mark Phase 2 `[COMPLETED]` and commit.

## Do NOT

- Do NOT re-introduce a global `Fintype preds` / `DecidableEq preds` field on `MonadicSignature`
  (plan-prohibited; would make Phase 3's infinite E[Σ] non-constructible).
- Do NOT touch `EANegation.lean:1090` / `:1249` or the `nf_nvar_exist_all_depths | _k+2` residual.
- Do NOT add task-number references in `Theories/**` (durable anchors only).
