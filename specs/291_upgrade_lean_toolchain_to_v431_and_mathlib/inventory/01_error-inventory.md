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

## Additional taxonomy rows discovered in Phase 5 (third dispatch)

### N7. Projection elaborated at the unfolded type — `Decidable`/`rw` synthesis aborts

The most productive single finding of this dispatch. A projection out of a semireducible *type*
synonym (`NormalForm sig (k+1) n`, which unfolds to a `Prod`) is elaborated as

```
@Prod.fst (AtomKind sig n → Bool) (NormalForm sig k (n+1) → Bool) qnf
```

i.e. at the *unfolded* component type. When such a term appears inside a `Decidable` goal, or as
the argument that a `rw` lemma has to match, the enclosing expression is no longer type-correct
at the `instances`/`reducible` transparency levels at which instance synthesis and `rw` motive
construction operate. Instance search therefore aborts *before* `normalForm_decEq` is tried, and
`rw` reports "did not find an occurrence of the pattern" for a pattern that is visibly present.

Two distinct repairs, both used:

1. **`show T from e`, not `(e : T)`.** Only the `show … from` form propagates the expected type
   into the projection's implicit argument, re-elaborating it as
   `@Prod.fst (NormalForm sig 0 n) _ qnf`. A parenthesised ascription elaborates the projection
   first and then checks defeq, leaving the bad implicit argument in place. Verified both ways.
   Used throughout `ExteriorFiberDeepAnchorK.lean`.
2. **Term-level lemma application.** `rw [foo_correct] at h` -> `have h' := (foo_correct …).mp h`;
   `rw [foo_correct]` on a goal -> `refine (foo_correct …).mpr ?_`. Used at
   `NfMultiAnchorBridge/Base.lean:257,504,513`. Same underlying mechanism as N5.

Corollary for `of_decide_eq_true` / `decide_eq_true`: these take `p` implicitly from the
*expected type*, so `exact of_decide_eq_true h` re-introduces the bad goal. Binding through
`have hrow := of_decide_eq_true h; exact hrow` takes `p` from `h` instead and works.

### N8. `orderedSumPt`-style helpers are needed for `split_ifs`/`rw`, not just for elaboration

`split_ifs` and `rw` now *silently half-apply* when the rewrite motive is not type-correct at
`implicit` transparency: `split_ifs` still performs the case split and introduces the named
hypotheses, but does not substitute the `dite`. The symptom is a confusing cascade — "unknown
identifier `hyb`", a hypothesis with the negated type in the wrong branch, "No goals to be
solved" — that looks like `split_ifs` name drift but is not.

Observed in `IntegerModel/GoodStructures.lean` where an `Equiv` into `(orderedSum sig Bool
pieces).carrier` was built from bare sigma literals `⟨false, ⟨x, _⟩⟩`. Replacing every such
literal (in `toFun` *and* in the `have he : e ⟨x,_⟩ = …` restatement) with `orderedSumPt` — the
helper introduced in `NEquivalence.lean` for the elaboration problem — fixed all ten errors in
that file: `left_inv`, `right_inv`, the `Monotone` proof, and the predicate-preservation proof.

**Rule of thumb**: wherever a sigma/subtype literal is written at a semireducible carrier type,
route it through a named helper whose *declared* result type is that carrier. The elaboration
failure and the silent-`split_ifs` failure are the same defect seen from two directions.

### N9. `Finset.card_filter_le` with an ascribed `univ`

`Finset.card_filter_le (Finset.univ : Finset (Fin (K + 1))) p` produced a `card` term that
printed identically to the goal's but failed to unify: the goal's index was
`Fin ((liftMergedFormulaFin ξ σ m).n + 1)`, only *definitionally* `Fin (K + 1)`, so the two
`Fintype` instances differed. Repair: bound through `Finset.card_le_card (Finset.filter_subset _ _)`,
which inherits the goal's own index, then discharge the residual `n + 1 ≤ K + 1` by `rfl`.
Three sites in `Kamp/LiftPair.lean`.

### N10. `simp` leaves syntactically-identical `X = X` goals

`simp only`/`simp` now report success while leaving a goal whose two sides print identically;
a following `rfl` (which runs at default transparency) closes it. Distinct from N6 in that no
arithmetic residue is involved — the sides differ only in hidden instance or index arguments.
Sites: `NfMultiAnchorBridge/Base.lean:123`, `VVecEA2Collapse.lean` (`hpt0`),
`EFGames/CustomGame.lean:534,606,613`. One-line repair each: append `rfl`.

Related: `simp`/`simpa` no longer bridges `a + (b + 1)` and `a + b + 1` in a `Fin.mk` index even
though they are definitionally equal (`Prop42NegationGeneral.lean:524`); `exact` does.

### N11. `simp` congruence refuses binders whose index type is only definitionally right

In `VVecEA2Collapse.lean`, `simp only [hpti, hsj]` reported both lemmas *unused* against a goal
containing `fun i ↦ … (pointType ⟨↑i + 1, _⟩)` where the bound `i : Fin ((collapseEFFin …).n - 1)`
and the lemmas are stated for `i : Fin m`. Repair: `congr 2` down to the field, `funext`, then
`exact congrArg _ (hpti i)` — the pointwise application unifies at default transparency.

### N12. `@[reducible]` on `extendedStructure` / `extendedStructureWithMu` — accepted

The counterpart to the rejected `@[reducible]` on `orderedSum`, and the single highest-yield
change of the third dispatch: **48 errors in `EFGames/StaviCompleteness.lean` cleared with a
two-line attribute change, and no previously-green module regressed.**

The failure mode was N7/N8 at scale. `(extendedStructureWithMu M atomMap r).carrier` is a
projection out of a semireducible structure-instance def, so an environment such as
`Fin.cons s (fun _ => t)` built from a `t : ExtendedCarrier M atomMap r` had the syntactic type
`Fin 2 → ExtendedCarrier M atomMap r` where the surrounding `eval` wanted
`Fin 2 → (extendedStructureWithMu …).carrier`. Twenty-four `have h1 : Fin.cons … = insertEnv …`
/ `rw [h1]` idioms all failed for this one reason.

**Why this is safe where `orderedSum` was not.** The `orderedSum` hazard was that unfolding
`.carrier` exposed a raw `Sigma`, at which point Mathlib's non-lexicographic `Sigma.preorder`
outranked the locally registered `carrier_order` — a silently different order with no error.
Here `.carrier` unfolds only as far as `ExtendedCarrier M atomMap r`, which remains
semireducible, so typeclass search cannot see the underlying `⊕`. The only registered order
instance on `ExtendedCarrier` is `extendedLinearOrder` (`EFGames/Defs.lean:362`), which is
*exactly* the term `carrier_order` is set to. There is no competing instance to select.

The rationale is recorded in a docstring on both definitions so the distinction from the
`orderedSum` case is not lost.

**The generalisable rule**: `@[reducible]` on a structure-instance def is safe iff, for every
class whose instance the structure carries as a field, the unfolded carrier admits no instance
other than the one the field supplies. Check that before reaching for the attribute; the
`orderedSum` failure is what it looks like when the check is skipped.

### N13. `List.Chain'` -> `List.IsChain` (extends N1/N3)

Batteries replaced the `List.Chain`/`List.Chain'` predicates with a single inductive
`List.IsChain` (deprecation date 2025-09-19). The *predicates* carry `@[deprecated]` aliases, so
statements mentioning `List.Chain'` still elaborate (with a warning); the **lemmas do not** —
they were deleted outright and produce `Unknown constant`.

Note the non-obvious index shift in the mapping: the primed old name goes to the *unprimed* new
name.

| Old | New | Statement |
|---|---|---|
| `List.chain'_cons'` | `List.isChain_cons` | `… (x :: l) ↔ (∀ y ∈ head? l, R x y) ∧ … l` |
| `List.chain'_cons` | `List.isChain_cons_cons` | `… (a :: b :: l) ↔ R a b ∧ … (b :: l)` |
| `List.chain'_nil` | `List.isChain_nil` | `… []` |
| `List.chain'_singleton` | `List.isChain_singleton` | `… [a]` |
| `List.Chain'` | `List.IsChain` | the predicate itself |

Sites: `NfMultiAnchorBridge/SubBracket2V.lean` (17), `NfMultiAnchorBridge/SharedWitness.lean`
(16). Sweep the predicate rename too, not just the lemmas: leaving `List.Chain'` in statements
means the new lemmas have to see through a deprecated semireducible `def` to match, which is
exactly the N5/N7 failure mode.

Local declaration names that merely *contain* `chain'` (e.g. `kvE2_sepGapRegions_chain'`) are
unaffected — restrict the sweep to the `List.` prefix.

### N14. `simpa only [Fin.cons, …] using h` -> `exact h` (mass conversion)

The single most common failure in the final wave, and entirely mechanical. A hypothesis whose
type is the *reduced* form (`zs ⟨0, _⟩ = p0`) no longer matches a goal whose type is the
*unreduced* form (`zs ⟨0, _⟩ = Fin.cases p0 (Fin.cons p1 …) ⟨0, _⟩`), because `simp only
[Fin.cons]` no longer performs that reduction. The two are still definitionally equal, so
dropping the `simpa` wrapper and using `exact` closes the goal at default transparency.

Error signature: `Type mismatch: After simplification, term h has type X but is expected to have
type Y`, where `Y` is `X` with `Fin.cases`/`Fin.cons` applications left unreduced.

Converted at 26 sites in `SharedWitness.lean` plus 14 in `SubBracket2`/`SubBracket2V`/`CarrierK1V`.
The rewrite is safe to automate: strip `simpa only [ … ] using ` down to `exact `, keeping any
`| ⟨k, _⟩ => ` pattern prefix. A driver script that reads the failing line numbers straight out of
the build log is in the task scratch history; the transformation is a one-liner per site.

**Do not** apply this blindly to every `simpa` in a file — only to the sites the build actually
reports, since a `simpa` whose simp set is doing real work will silently become an `exact` that
fails.

### N15. `Decidable` bridges written as `decidable_of_iff (∀ i, a i = b i) funext_iff.symm`

`SharedWitness.lean:61` defined `DecidableEq (ZoneSpec n)` this way. It now fails with
`failed to synthesize Decidable (∀ (i : Fin n), a i = b i)`: synthesising that requires reading
`a i` as a function application, which requires unfolding the semireducible `ZoneSpec`, which
instance search does not do.

Repair: name the unfolded type directly — `inferInstanceAs (DecidableEq (Fin n → Bool × Bool))`.
This is strictly better than the original (it is the canonical instance rather than a transported
one) and it removes the downstream cascade: while this instance was failing, every
`decide (zs₁ = zs₂)` in the file reported *`decide` failed … reduction got stuck at the
`Decidable` instance `sorry`*, which reads like an unrelated `decide` problem. **Check for a
failed instance above before investigating a stuck `decide`.**

## Additional taxonomy rows discovered in Phase 5 (fourth dispatch)

### N16. List literals of `Fin.cons p (zs : ZoneSpec k)` — the whole literal is untraversable

The generalisation of N4/N7 to a *container*. `kvE2_futPossibleZones` /
`kvE2_pastPossibleZones` are `List (ZoneSpec 4)` literals whose nine entries are
`Fin.cons p zs3` with `zs3 : ZoneSpec 3`. `Fin.cons`'s implicit motive is solved as
`fun _ => Bool × Bool`, so the tail's *expected* type is `Fin 3 → Bool × Bool` while its
*actual* type is the semireducible `ZoneSpec 3`. The literal is therefore not type-correct
at `implicit` transparency, and **every** tactic that has to look inside it stalls:

| Tactic | Symptom |
|---|---|
| `simp [kvE2_futPossibleZones, List.mem_cons]` | `simp` made no progress + `Note: The target expression is not type-correct under the `implicit` transparency level` |
| `simp only [… ] at hzp` then `rcases` | simp silently unfolds one `List.mem_cons` level; `rcases` then reports the *remaining list* "is not a free variable" |
| `decide (zs = z)` inside `List.any` | works (the `Decidable` instance is found), so the definition still elaborates — only the *proofs about it* fail |

The `rcases` message is the confusing one: it names a list, not a hypothesis, and reads
like a `rcases` pattern-arity bug. It is not — it is the half-applied `simp` above it.

**Repair — package every membership fact as a term-level lemma.** `exact`/`apply` check at
`default` transparency, where `ZoneSpec` unfolds and the literal is perfectly well-typed:

- introduction: `List.Mem.head _` / nested `List.Mem.tail _ (…)` (one `tail` per index)
- elimination: `List.mem_cons.mp h` applied as a *term*, chained, with
  `List.mem_singleton.mp` at the last entry

Five lemmas per side (`_mem_below`/`_mem_above`, `_mem_gap`, `_mem_self`, `_mem_ray`,
`_cases`) replaced four `simp` calls and one `simp only … at` + `rcases` in each of
`Kamp/ExteriorNegation.lean` and `Kamp/ExteriorNegationPast.lean`. The call sites keep their
original `rcases … with rfl | rfl | …` shape, so the nine downstream bullet bodies are
untouched.

**Rejected alternative**: the `zoneCons` helper (a `Fin.cons` at the declared `ZoneSpec`
type, mirroring `orderedSumPt`). It fixes the *literal*, but the paired
`@[simp] zoneCons_eq : zoneCons p zs = Fin.cons p zs` bridge — needed because the goal side
produces bare `Fin.cons` via `Fin.cons_self_tail` — rewrites straight back to the
untraversable form, so `simp` stalls again one step later. It also forces a rebuild of every
module importing `NfEFold.lean`. The certificate lemmas are local, cost nothing downstream,
and the goal side needs no normalisation at all.

### N17. `Set.ne_univ_iff_exists_not_mem` -> `Set.ne_univ_iff_exists_notMem` (extends N1/N3)

Part of Mathlib's `not_mem` -> `notMem` naming sweep. Deleted outright, so it surfaces as
`Unknown constant`, not a deprecation warning. Sites: `Expressiveness/SplitPoint.lean` (2).
Expect siblings in the same family (`Finset.ne_univ_iff_exists_notMem`, `notMem_of_…`) if
more of this file group is touched.

### N18. `push_neg` / `rw [not_le]` no longer fire at a semireducible carrier type

`push_neg at h` on `h : ¬ Sum.inr g ≤ extendPoint p`, where the `≤` lives at
`ExtendedCarrier N atomMap r`, now reports **``push Not` made no progress at `h``**, and the
explicit `rw [not_le] at h` reports `Did not find an occurrence of the pattern Not (?a ≤ ?b)`.
The rewrite is matched at reducible transparency, where the order instance on the
still-semireducible carrier cannot be seen through.

Repair is pattern 2 from the third dispatch — bind through an **ascribed** `have`, which
elaborates at `default`:

```lean
have hp_lt : (extendPoint p : ExtendedCarrier N atomMap r) < Sum.inr g := not_le.mp h_not_le
have hp_le : (extendPoint p : ExtendedCarrier N atomMap r) ≤ Sum.inr g := le_of_lt hp_lt
have hp_in : p ∈ g.val.cut := hp_le           -- defeq at `default`, not at `implicit`
```

Note the third line: the *consumer* of the fact needs the same treatment, because
`p ∈ g.val.cut` and `extendPoint p ≤ Sum.inr g` are likewise only definitionally equal.
Writing `le_of_lt h` directly into a `p ∈ g.val.cut`-typed `have` fails.

`lt_of_not_le` is gone in this toolchain; use `not_le.mp` (or `lt_of_not_ge`).

**Separately**: `push_neg` is now deprecated in favour of `push Not`. That is a warning, not
an error, and this dispatch left the ~30 surviving `push_neg` sites alone — they are Phase 10
debt, not Phase 5 breakage.

### N19. `simp [f]` no longer discharges `Sum.inl _ ≠ Sum.inr _` after unfolding `f`

`simp [extendPoint]` unfolds `extendPoint q` to `Sum.inl q` and then stops, leaving
`⊢ Sum.inl q ≠ Sum.inr g_d`. Same family as N10 (`simp` leaves a goal it used to close).
Repair: `exact Sum.inl_ne_inr` — and prefer dropping the `by` entirely, making the `have` a
term. One site in `SplitPoint.lean:2528`; three sibling `simp [extendPoint]` calls in the same
file were unaffected, so fix only what the build reports.

Related in the same file: `simp [IsGap]` on `IsGap (Sum.inr g) ↔ IsGap (Sum.inr g')` also
stops short, leaving the two unfolded existentials. Both sides are inhabited by the gap
itself: `exact ⟨fun _ => ⟨g', rfl⟩, fun _ => ⟨g, rfl⟩⟩`.

**Read the witness type off the `def`, not off the `simp`-unfolded goal.** `IsGap e` is
`∃ g : RDefinableGap M atomMap r, e = Sum.inr g` — ONE existential over a subtype. The goal
`simp` prints is `∃ a, ∃ (b : r_definable_gap M atomMap a r), e = Sum.inr ⟨a, b⟩`, i.e. the
subtype already split into two binders. Writing the term against the printed form
(`⟨g.1, g.2, rfl⟩`) fails with the misleading pair
`Application type mismatch` + ``Constructor `Eq.refl` does not have explicit fields, but 2
were provided`` — the anonymous constructor consumed `g.1` as the whole subtype witness and
then had two fields left over for the residual `Eq`.
