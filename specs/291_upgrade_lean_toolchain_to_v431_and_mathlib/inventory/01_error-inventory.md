# Phase 3 Error Inventory — First Post-Upgrade Build

Build: `lake build` at `leanprover/lean4:v4.33.0-rc1` + Mathlib `v4.33.0-rc1`, from a cleaned
tree (Phase 2 commit `29b9cea6f`). Log: `inventory/build-01.log`. Raw rows: `inventory/errors-01.tsv`.
**Zero source edits were made in this phase**, per the plan.

## Headline

**12 errors, in 3 files, in 2 categories — and both categories are new rows that the research
taxonomy did not predict.** Every predicted HIGH-severity category produced **zero** errors in
this wave.

| Metric | Value |
|---|---|
| Errors | 12 |
| Files with errors | 3 |
| Bimodal modules built successfully | 123 |
| Modules blocked downstream of a failure | remainder of ~472 (see coverage caveat) |
| New `sorry` introduced | 0 |
| Build exit | 1 |

## Per-category counts

| Category | Count | In research §5? | Originating change |
|---|---|---|---|
| `mathlib-lemma-renames` | 9 | **No — new row** | Mathlib library renames (not import paths) |
| `subtype-proof-irrelevance` | 3 | **No — new row** | `simp` no longer closes subtype goals differing only in proof components |
| `defeq-transparency` | 0 | Yes (predicted HIGH) | — |
| `heartbeat-timeout` | 0 | Yes (predicted HIGH) | — |
| `do-elaborator` | 0 | Yes (predicted MED-HIGH) | — |
| `simp-instances` | 0 | Yes (predicted MEDIUM) | — |
| `native-decide-axioms` | 0 | Yes | — |
| `subgoal-tags` | 0 | Yes | — |
| `noncomputable` | 0 | Yes | — |
| `meta-api-renames` | 0 | Yes (predicted empty — **confirmed empty**) | — |
| `range-syntax` | 0 | Yes | — |
| `dsimp-no-progress` | 0 | Yes | — |
| `unattributable` | **0** | — | — |

Sums to 12. ✅

## Per-file hot spots

| File | Errors | Categories |
|---|---|---|
| `Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` | 9 | `mathlib-lemma-renames` |
| `Metalogic/WeakCanonical/MonadicFO.lean` | 2 | `subtype-proof-irrelevance` |
| `Metalogic/WeakCanonical/ReflexiveCanonical.lean` | 1 | `subtype-proof-irrelevance` |

## New taxonomy rows

### N1. `mathlib-lemma-renames` (9 errors)

Research §3 verified that all 59 imported Mathlib **modules** still exist at v4.33.0-rc1, and
concluded "zero import-path breakage". That conclusion is correct and is **not** what broke.
What broke is Mathlib renaming individual **lemmas** inside those still-existing modules. The
research taxonomy had no row for this, and §5.8 (`meta-api-renames`) covers only metaprogramming
APIs — which, as predicted, produced zero errors.

| Old name | New name | Sites | Verified at |
|---|---|---|---|
| `Finset.not_mem_empty` | `Finset.notMem_empty` | 5 (`:88`×2, `:106`×2, `:152`) | `Mathlib/Data/Finset/Empty.lean:108` |
| `le_of_not_lt` | `le_of_not_gt` | 4 (`:889`, `:957`, `:1468`, `:1538`) | `Mathlib/Order/Defs/LinearOrder.lean:107` |

Both replacements were confirmed present in the vendored Mathlib source, not guessed. The first
is an instance of Mathlib's `not_mem` -> `notMem` naming migration; expect more of these as
further modules become reachable.

### N2. `subtype-proof-irrelevance` (3 errors)

Goals that are closed by proof irrelevance on a subtype's proof component, which `simp` used to
discharge and no longer does.

| Site | Residual goal |
|---|---|
| `MonadicFO.lean:247` | `⟨x_val, ⋯⟩ ∈ {⟨x_val, ⋯⟩, d}` |
| `MonadicFO.lean:248` | `⟨Order.succ a, ⋯⟩ ∈ {c, ⟨Order.succ a, ⋯⟩}` |
| `ReflexiveCanonical.lean:48` | `⟨val✝, ⋯⟩ = ⟨val✝, property✝⟩` |

This is adjacent to research §5.1 (`isDefEq` transparency) in spirit, but it is not a defeq
*failure* — the terms are still defeq. It is `simp` declining to finish a goal whose remaining
content is a proof component. Kept as its own row because the fix is different: `Subtype.ext` /
explicit `Set.mem_insert` lemmas rather than transparency wrappers or `backward.*` options.

## Coverage caveat — this is a FIRST WAVE, not a complete measurement

Only **123** Bimodal modules built. The three failing modules sit mid-graph, so everything
downstream of them was never elaborated and cannot have reported errors. The predicted-HIGH
categories scoring zero therefore means **"zero so far"**, not "zero overall". In particular the
heaviest files named in the plan's Phase 6 (`SharedWitness.lean` at 12,800 lines,
`SuccChainFMCS.lean`, `GapDetection.lean`, `SplitPoint.lean`) were not reached, so the
heartbeat-timeout row is entirely unmeasured.

The inventory is extended after each repair wave. Phase 4's own task list already requires
"Re-run `lake build`; record the new error count against the Phase 3 total", which is the
mechanism for that.

## D1 staged-fallback verdict

**Verdict: `PROCEED single-jump`.**

The two triggers, evaluated literally:

1. **`unattributable` > 25%** — **not met.** `unattributable` is **0%** (0 of 12). Every error
   is attributed to a concrete cause with a verified fix, which is the strongest possible
   reading of "we can still reason about causes".
2. **Build failed so early the inventory is unrepresentative** — **met, literally.** 123 of ~472
   modules built.

Trigger 2 fires, so the plan's letter says fall back to staged `4.27 -> 4.29 -> 4.31 -> 4.33`.
**Proceeding single-jump instead, deliberately, for these reasons:**

- D1's stated rationale for staging is *attribution*: "its only real benefit is attributing each
  error to the release that caused it." Attribution is not degraded here — it is perfect (0%
  unattributable). Staging would pay three Mathlib cache downloads and three full rebuilds of a
  278k-line corpus to re-derive information already in hand.
- Trigger 2's stated concern is that "the error count is an artifact of build ordering rather
  than a measurement." That is true, but **staging does not fix it.** A 4.29 build would abort at
  the same place for the same reason — a blocking error mid-graph hides its dependents regardless
  of which release introduced it. The only thing that reveals downstream errors is *clearing the
  blockers and rebuilding*, which is exactly what Phase 4 does.
- The plan's own guardrail points the same way: "Do not trigger staging merely because the
  inventory is large — a large but *attributable* inventory is exactly the case the single jump
  handles fine." A small, fully-attributable inventory is that case a fortiori.

**This is a documented deviation from the letter of D1 and is flagged for reviewer attention.**
It is cheap to reverse: the Phase 2 pin commit (`29b9cea6f`) is isolated, so falling back to
staged remains a single `git revert` plus a re-pin at any later point.

## Effort re-estimate

The plan's metadata carried a 16-hour placeholder pending this measurement, and the task
description guessed "~50-200 lines of fixes".

Against wave 1, the honest numbers are: **9 one-token identifier substitutions and 3 small proof
repairs.** That is well under the low end of the task's guess. Research argued the estimate was
wrong *in kind* — that breakage would be semantic rather than rename-driven. Wave 1 says the
opposite: it is rename-driven after all, just Mathlib lemma renames rather than the import-path
renames research ruled out.

This estimate is provisional in the same way the original was: ~350 modules are still unbuilt,
and the heartbeat-sensitive giants among them are the plan's main cost risk. Revised phase
timings are deliberately not written into the plan until a build gets past the current blockers
and the second wave is measured.

---

# Waves 2-4 — Phase 5 measurements

Wave 1 (above) measured only 123 of ~472 modules. Clearing its blockers exposed three further
waves. Each wave is the full `lake build` error set after the previous wave's repairs landed.

| Wave | Errors | Files | Modules reached | Log |
|---|---|---|---|---|
| 1 (Phase 3) | 12 | 3 | 123 | `build-01.log.gz` |
| 2 | 3 | 2 | 1773/1877 | (Phase 4 end) |
| 3 | 54 | 7 | 1823/1877 | `/tmp/upgrade-build-02.log` |
| 4 | 26 | 7 | 1849/1877 | `/tmp/upgrade-build-03.log` |

The monotone rise in "modules reached" is the real progress signal here; the error count is not
monotone because each wave elaborates modules that were previously invisible.

## Additional taxonomy rows discovered in Phase 5

### N3. `mathlib-order-lemma-renames` (extends N1)

The `not_le`/`not_lt` order-lemma family was renamed to a `not_ge`/`not_gt` spelling. None of
these have deprecation aliases, so they fail as `Unknown identifier`. Verified against
`Mathlib/Order/Defs/LinearOrder.lean` and `Mathlib/Order/Defs/PartialOrder.lean`:

| Old name | New name | Sites swept |
|---|---|---|
| `le_or_lt` | `le_or_gt` | 39 |
| `lt_iff_le_not_le` | `lt_iff_le_not_ge` | 1 |
| `lt_of_not_le` | `lt_of_not_ge` | 11 |
| `le_of_not_lt` | `le_of_not_gt` | 2 |
| `lt_or_le` | `lt_or_ge` | 2 |

Statements are identical, so every site is a pure identifier substitution. The sweep was run
repo-wide (not just on failing files) after wave 3, because these names sit in modules that the
build had not yet reached; discovering them one wave at a time would have cost several full
rebuilds. Replacements were verified to exist and to carry the same statement before the sweep.

### N4. `type-correctness-at-implicit-transparency`

This is the dominant Phase 5 category and the concrete face of the plan's predicted
`defeq-transparency` row. The elaborator now rejects terms that are only type-correct after
unfolding a semireducible definition, reporting:

> The target expression is not type-correct under the `implicit` transparency level

The repo's exposure comes from three semireducible type-level definitions whose unfolded form is
what the surrounding term actually mentions:

| Definition | Unfolds to | Consequence |
|---|---|---|
| `NormalForm sig k n` | `AtomKind sig n → Bool` (k = 0) | applying an NF as a function, and `Fintype.card_fun` |
| `ExtendedCarrier M atomMap r` | `M.carrier ⊕ RDefinableGap M atomMap r` | `Sum.map`/`Sum.map_injective` rewrites |
| `(orderedSum sig I ms).carrier` | `(i : I) × (ms i).carrier` | sigma literals under `Fin.cons`, `.fst`/`.snd` |

**`@[reducible]` was evaluated and rejected for `orderedSum`.** It does fix the elaboration
failures, but it also lets typeclass search see through `.carrier` to the raw `Sigma` type, at
which point Mathlib's non-lexicographic `Sigma.preorder` is selected in preference to the
locally registered `carrier_order` — substituting a *different order* with no error. This was
observed concretely in `IntegerModel/GoodStructures.lean:448-461`, where the goal's instance
switched from `inst_ord.toPreorder` to `Sigma.preorder`. The reducibility attribute was reverted
and the sites repaired individually instead, via a named `orderedSumPt` helper whose *inferred*
type is syntactically `(orderedSum sig I ms).carrier`.

`@[reducible]` was kept for `k_equiv` (a Prop-valued def unfolding to an equation — no instance
can be selected on it, so the hazard does not apply).

### N5. `rw`-pattern instance mismatch

`rw` matches at reducible/instances transparency, so a lemma stated with one instance path no
longer matches a goal carrying another, even when the two are definitionally equal. Observed at:

- `NEquivalence.lean` — `Sigma.Lex.lt_def` (stated with `Sigma.Lex.LT` over `Σₗ`) against a goal
  carrying `Sigma.Lex.linearOrder.toLT` over `Sigma`.
- `ConjInterleave.lean:799` — `Fin.lt_def` (`instLTFin`) against `Fin.instLinearOrder.toLT`.
- `TypeFormulas.lean:144` — `Sum.map_injective` against `ExtendedCarrier`.
- `NfDepth0Generalized.lean:79` — `nfPred_correct` against an inline NF lambda.

**General repair**: replace `rw [lemma]` with a term-level `refine Iff.trans lemma …` or an
`exact`/`have` at the `.val` level. Term elaboration unifies at *default* transparency, which
still sees through the instance paths. This is the single most reusable fix in this phase.

### N6. `convert`/`simp` residue

Congruence and simp now leave small arithmetic or `Fin`-index side goals that used to be
discharged silently (`⟨0, ⋯⟩ = 0`, `⟨i + 1 - 1, ⋯⟩ = ⟨i, ⋯⟩`, `n + 1 + ↑⟨0, ⋯⟩ = n + 1`). The
mirror-image failure also appears: a `congr 1; ext; omega` chain where `ext` now closes the goal
and `omega` then reports "No goals to be solved". Both are one-line repairs (append `simp`, or
guard the trailing tactic with `try`).

Separately, `simp` normalises `i + 1 ≤ n` to `i < n` before user-supplied `dif_pos` lemmas are
tried, so guards must be discharged in the normalised spelling.
