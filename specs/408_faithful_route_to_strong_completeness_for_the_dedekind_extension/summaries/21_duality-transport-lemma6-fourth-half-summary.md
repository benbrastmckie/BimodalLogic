# Phase 20.4 — The §6 duality-transport layer and Lemma 6's fourth half

**Status**: `[COMPLETED]`. Phase 20 also moved `[PARTIAL]` → `[COMPLETED]` in the same postflight,
as its `Done when` requires.

**Route taken**: (a), the chartered route. Route (b) — the ~540-590 line hand mirror sized as
Phases 20.6/20.7 — was never opened.

---

## The R15 hard gate: NOT tripped

Group 1 was written into `Dual.lean` in one pass and compiled after a **single repair of six
explicit-implicit-argument annotations**. The failure mode was uniform and trivial: Lean unifies an
implicit `{M}` against a `dual M`-shaped expected type by choosing `M := dual M`, so every
`.mp`/`.mpr` application of a transport lemma needs `(M := M)`.

`reports/08` pre-authorised three residual fixes of exactly this species. Of those three:

| `reports/08` fix | Outcome |
|---|---|
| (1) drop `generalizing env` on `eval_dualize` | Pre-empted — written as an equation-style recursion instead |
| (2) `congr 1` closes `contempEquivDense_dual` early | Pre-empted — proved via an explicit `funext`/`fin_cases` environment lemma instead |
| (3) swapped conjunct order in `endsInGapOnRight_dual`'s third conjunct | **Real**, and repaired as recorded |

No design change was made, no iteration on the transport layer occurred, and the two routes were
never attempted together.

## Clause (iii): Escape 1 landed

R14 was the one bounded attack that landed against the cheap route. The plan chartered two escapes
in preference order. **Escape 1 — the first choice — went through.**

`StructIso`, `cons_comp_equiv` and `eval_iso` prove `eval` invariant along any order- and
interpretation-preserving equivalence of carriers. This is precisely the
eval-along-a-carrier-isomorphism lemma R14 identified as absent from the tree (`Kamp.eval_rename`
transports variable renamings, not points). `subintervalDualEquiv` / `subintervalDualIso`
instantiate it at the conjunct exchange, and `isContempEquivDense_dualize` carries **all three**
clauses across.

Consequences worth recording:

- **Escape 2 (`ContempFacts`) was not needed.** No `_of_facts` variants were added, no Lemma 5
  entry point was re-signed, and `IsContempEquivDense` is left **unweakened and unrenamed**.
- `eval_iso` is reusable indefinitely for any later carrier transport, not only this one.

## R14 refined by measurement — narrower than the risk row states

The risk row says the dual's subinterval predicate is *"the same two conjuncts in the opposite
order"* and that this is not definitionally equal. Measured here, the obstruction is **strictly
smaller than that**:

- The **endpoint exchange is definitional**: `dual_min` and `dual_max` are both `rfl`. `min` in the
  dual really is `max` in the original, by unfolding alone.
- Only the **order of the two conjuncts** in the `Subtype` predicate fails to be definitional.

R14's diagnosis stands; its scope does not extend as far as written. This is recorded in
`Dual.lean`'s header as **this tree's formalization artifact, not Reynolds'** — his `M|[a,b]` is an
unordered interval and the conjunct ordering is an artifact of the Lean rendering. Honesty-charter
Rule 7 is observed: it is not recorded as a defect in the source.

---

## What landed

### `DenseModelSurgery/Dual.lean` (new, 492 lines)

The order-duality transport layer. `dual M` over `OrderDual`, with `def d (x : M.carrier) :
(dual M).carrier := x` and `dual` **not** `@[reducible]` — both discipline constraints observed,
both for the `.carrier`-unfolding hazard documented at `NEquivalence.lean:134`.

27 declarations: `dual`, `d`, `dual_carrier`, `d_lt`, `dualize`, `dualize_involutive`,
`eval_dualize`, `eval_dualize'`, `swapUS`, `swapUS_involutive`, `temporalTruth_dual`,
`temporalTruth_dual'`, `semanticPriorU_dual`, `semanticPriorS_dual`, `contempEquivDense_dual`,
`contempEquivDense_dualize`, `endsInGapOnRight_dual`, `endsInGapOnLeft_dual`, `StructIso`,
`cons_comp_equiv`, `eval_iso`, `contempEquivDense_iso`, `dual_min`, `dual_max`,
`subintervalDualEquiv`, `subintervalDualIso`, `isContempEquivDense_dualize`.

As predicted: the `lt` case of `eval_dualize` is `Iff.rfl`, `d_lt` is `Iff.rfl`, and the binder
cases collapse to one-liners because `d` is the identity.

### `DenseModelSurgery/Lemma5.lean` (+58)

`reynolds_lemma5_first_left` — Lemma 5's first statement over maximal intervals of `λ`, obtained by
instantiating `reynolds_lemma5_first` at `(dual M, dualize ε)` and at `swapUS A`.

Its docstring states that it is **unstated by Reynolds**, and names what licenses it: the p.178
duality convention (*"Dually we can define `λ(x)` about left ends."*) and the appeal to *"previous
results"* at p.180. It is **not** attributed to the source as a printed statement.

One import line added. Otherwise append-only: no existing declaration restated, renamed or
weakened.

### `DenseModelSurgery/BadIntervals.lean` (+68)

- `ClassInteriorToLInterval` — new, the exact mirror of `ClassInteriorToRInterval`.
- `endsInGapOnRight_of_endsInGapOnLeft` — Reynolds' *"using mirror images of the above and previous
  results we get our proof"* (printed p.180), discharged as an instantiation of
  `endsInGapOnLeft_of_endsInGapOnRight` at `(dual M, dualize ε)` with the endpoints exchanged.
- **`reynolds_lemma6` extended to its fourth conjunct** — the one permitted in-place edit. The
  three landed conjuncts are byte-identical; the edit adds a conjunct and the matching component of
  the assembling `exact`.
- The `WHAT LEMMA 6 STILL OWES` header section and the proof-step map's *"not discharged"* row are
  retired and replaced with the completed four-half account.

The fourth conjunct takes the `λ`-side interval as its **own** hypothesis, because nothing about a
maximal interval of `R` supplies one. Phase 21's dependency check should expect that shape.

### `WeakCanonical.lean` (+1)

One import line for `Dual.lean`. The four earlier `DenseModelSurgery` import lines are **kept**
rather than dropped as now-transitive, per the phase's explicit instruction.

---

## Verification (V1–V8)

| Task | Result |
|---|---|
| **V1** declaration census | `Lemma5.lean` 38 → 39, `BadIntervals.lean` 48 → 50. **Zero removals, zero renames** (sorted name-set diff against baseline `5c5906ef4`). `reynolds_lemma6` is the only conclusion that changed, and only by strengthening |
| **V2** sorry census | **Delta zero.** See the concurrency note below |
| **V3** `#print axioms` | Every new declaration within `[propext, Classical.choice, Quot.sound]`. Several strictly smaller: `dualize`, `swapUS`, `dualize_involutive`, `swapUS_involutive` depend on **no axioms at all**; `ClassInteriorToLInterval` on `[propext]` only. Group 1 axiom-free by construction, as predicted |
| **V4** R14 recorded honestly | Done, and refined by measurement — see above. Rule 7 observed |
| **V5** retrospective subsumption | `Dual.lean`'s header names `BadIntervals.lean:968-1225` (258 lines) and `Kamp/Lemma53FaithfulPast.lean` (364 lines); states explicitly that **neither is deleted, refactored or deprecated** |
| **V6** conditionality caveat | Carried in `Dual.lean`'s header, `reynolds_lemma6`'s docstring, and `reynolds_lemma5_first_left`'s section header |
| **V7** regression canaries | `completeness_dense`, `completeness_discrete`, `countermodel_discrete_reynolds_v2` all unchanged. No `Decidability/` or `Automation/` file read for edit or staged |
| **V8** docstring pages | Lemma 5 → p.179, Lemma 6 → p.180, duality convention → p.178. Only inline prose quoted; **no displayed formula transcribed**, so the recorded §6 display-corruption defect could not bite |
| task-number citations | None in any `.lean` file |

**Build**: full `lake build` green at **1937 jobs** with the complete change set in place. A later
full build failed on `Decidability/Verified/Bridge/TemporalGate.lean` while the concurrent task-165
session was live-editing it (its error line moved from 255 to 177 between two consecutive builds);
scoped `lake build FormalSystem.Metalogic.WeakCanonical` (1842 jobs) green.

**Sorry concurrency note**: the three live non-`Boneyard` sorries are all foreign to this task.
`WeakCanonical/Transfer.lean:1242` is pre-existing and unrelated. The two in
`Decidability/Verified/Bridge/IntTruth.lean` belong to the concurrent decidability session and
their line numbers drifted three times during this dispatch (`:434/:444` in the brief, `:514/:524`
at the baseline commit, `:665/:680` at census time) — re-located by name each time, never trusted
by line number. **This phase's own delta is zero.**

---

## Scope hypothesis: FALSIFIED, reported not absorbed

| | Estimated | Actual |
|---|---:|---:|
| `Dual.lean` (Groups 1+2) | ~295 | 492 (≈98 header docstring) |
| Group 3 | ~55 | ~126 |
| **Total** | **~350** | **618** (1.77×) |

The overrun sits in documentation density and in Group 3's uncounted items
(`ClassInteriorToLInterval`, the retired gap notes), **not** in unplanned proof work. Every group
still landed inside the single dispatch, so the H8 one-run bound held even though the line estimate
did not.

---

## Not done, deliberately

**Phase 20.5 (D16)** was not batched into this dispatch. It remains `[NOT STARTED]` with its own
owner, as chartered.

## Incident disclosed

A `git stash` + `git checkout` sequence used to compare the sorry census against the baseline left
the working tree detached, and a concurrent `git-snapshot` run by the task-165 session shifted the
stash indices, so the stash popped was task-165's rather than this agent's.

- **No work was lost.** All four Phase 20.4 commits were already on `main`; the uncommitted
  G3.2/G3.3 edits were recovered intact by content extraction and re-verified green before commit.
- **task-165's WIP is preserved** and labelled in a stash entry (`task165 TemporalGate WIP:
  re-stashed by t408-p20.4 after accidental pop of git-snapshot-1785279640`). The state its own
  snapshot deliberately created was restored. That session has since resumed live-editing the file.
- **Correction adopted**: baseline comparisons afterwards used `git show <rev>:<path>` only, never
  a checkout. This is carried forward in the handoff.
