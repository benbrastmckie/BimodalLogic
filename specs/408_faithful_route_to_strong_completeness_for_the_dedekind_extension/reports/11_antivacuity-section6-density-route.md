# Blocker Research — Phase 29's Anti-Vacuity Checkbox and the §6 `DenselyOrdered` Obstruction

- **Task**: 408 (`faithful_route_to_strong_completeness_for_the_dedekind_extension`)
- **Type**: lean4 | **Effort**: `--hard` | **Focus**: blocker research (Stage 6 escalation 1 of 2)
- **Session**: `sess_1785362916_22a871_408`
- **Reference grounding tier**: Tier 1 (literature-backed — Reynolds 1992, read from
  `/home/benjamin/Projects/Literature/sources/reynolds_1992/`)

---

## Headline

**The measured obstruction is REFUTED.** `DenselyOrdered (surgeredStructure M ε Q t).carrier` is
**provable**, not false, under exactly the hypotheses `reynolds_lemma9` already carries. The
earlier dispatch's refutation rests on an inference from Lemma 4 (a statement about **classes**)
to a statement about **points** that does not go through, and it overlooks the fact — already
landed in this tree — that Lemma 6's first clause forces the surviving class to have neither a
first nor a last point.

Consequently:

- **Disposition (a): reachable via a section-6 repair.** Route given below, with declaration
  names, file/line anchors, and cost.
- **Phase 30 is blocked on the same thing** for 4 of its 6 substantive tasks — so the §6 repair
  is on the critical path to the task's own terminus, not optional scope-widening.
- Two of Phase 30's tasks are dispatchable immediately and are not gated on this.

---

## 1. Characterizing the obstruction exactly

### 1.1 Where the demand actually arises — one site

§6 takes `hε : IsContempEquivDense ε`, whose clauses (i) and (ii) are quantified over **every**
structure (`DenseModelSurgery/Defs.lean:234-245`). Doets' theorem takes the countable-dense
bundle `IsContempEquivDenseCD ε` (`Defs.lean:271-283`), whose clauses (i)/(ii) carry
`[Countable M.carrier] [DenselyOrdered M.carrier]` and whose clause (iii) is unrestricted.
`IsContempEquivDense.toCD` (`Defs.lean:288`) runs only the free direction. The weakening is
forced and settled: `IsContempEquivDense (epsDense sig k)` is **false**, with the `(0,1]`
counterexample in `EpsilonDense`'s module header.

I audited every projection of `hε`'s clauses at a structure other than the section variable `M`
across the whole of §6 (`DenseModelSurgery/*.lean`, 97 `hε : IsContempEquivDense` binders). The
complete list:

| Site | Structure | Clause used | Survives CD weakening? |
|---|---|---|---|
| `NoGaps.lean:467` (`surgeredContempEquiv_of_base`) | `surgeredStructure M ε Q t` | (iii) `contemporary` | **Yes** — clause (iii) is unrestricted in the CD bundle |
| `NoGaps.lean:608` (`reynolds_lemma9`) | `surgeredStructure M ε Q t` | (i)+(ii), via `endsInGapOnRight_congr` (`Lemma34.lean:242`) | **No** — needs the two instances at `N` |
| `Dual.lean:464-486`, `NoGaps.lean:715,920`, `BadIntervals.lean:1361,1481`, `Lemma5.lean:872`, `Singletons.lean:296`, `TruthTransfer.lean:730,752` | `dual M` | (i)+(ii) | **Yes** — `(dual M).carrier = M.carrierᵒᵈ` by `rfl` (`Dual.lean:118,122`); `OrderDual.denselyOrdered` (Mathlib, `Mathlib.Order.OrderDual`) and `inferInstanceAs (Countable M.carrier)` supply both |
| everything else in `TruthTransfer.lean` (Lemma 8), `BadIntervals.lean`, `Lemma34.lean`, `Lemma5.lean`, `Singletons.lean` | `M` itself | (i)+(ii)+(iii) | **Yes** — `M` is the chronicle structure, countable and dense |

So the obstruction is **exactly one line**: `NoGaps.lean:608`

```lean
· exact (endsInGapOnRight_congr hε (surgeredStructure M ε Q t) hc).mp hgapN
```

This is Reynolds' *"Clearly `q` is not in the class of `I` in `N`"* (printed p.182), proved
contrapositively: `hc : ContempEquivDense N ε base q` is transported along the class in `N`, which
needs `∼_N` to be transitive and its classes convex — i.e. clauses (i)/(ii) **at `N`**. The
confirmation of the earlier dispatch's localization is exact: `reynolds_lemma9` is the single
failing site.

### 1.2 The refutation of "necessarily not densely ordered"

The recorded argument (`DoetsTheorem.lean:350-353`, `plans/10_…-v10.md:4762-4764`) is:

> That structure collapses a bad interval to a single `∼`-class, and Lemma 4 (*"no first class in
> any maximal interval"*) guarantees the points below the surviving class are removed — so it has
> adjacent points and is **not** densely ordered.

The premise is right and the conclusion does not follow. "The points below the surviving class are
removed" produces **adjacency** only if the surviving class `I` has a **least element** (and,
dually on the right, a greatest). Lemma 4 is a statement about classes, not about the points
inside one class, and it says nothing about whether `I` has endpoints.

What the tree already proves is that it does **not**:

- `IsBadIntervalSurgery.interior` (`TruthTransfer.lean:218`) supplies, for every point of `Q₀`, a
  `ClassInteriorToBadInterval M ε a p b` (`BadIntervals.lean:1023`).
- That structure carries **both** halves of Lemma 6's first clause (*"in any bad interval both `R`
  and `L` hold throughout"*, printed p.180): `toR : ClassInteriorToRInterval …` with
  `rThroughout` (`BadIntervals.lean:433`), and `lThroughout : ∀ q, a ≤ q → q ≤ b →
  EndsInGapOnLeft M ε q` (`BadIntervals.lean:1028`).
- Hence **every** point of `Q₀` — in particular every point of `I` — is both an `R`-point and an
  `L`-point. The `R` half is already landed as `endsInGapOnRight_of_mem` (`NoGaps.lean:505-508`);
  the `L` half is the same three lines through `lThroughout` and is not yet named.
- `exists_contemp_gt` (`Lemma34.lean:265`, *"The class has no last point"*) and
  `exists_contemp_lt` (`BadIntervals.lean:1011`, *"The class has no first point"*) then give: for
  every `i ∈ I` there are class-mates of `i` strictly above and strictly below it.

So `I` has **no first point and no last point**. Removing the classes of `Q₀` below `I` therefore
creates no adjacency: `I` itself supplies survivors arbitrarily close to its own lower edge.

### 1.3 `DenselyOrdered (surgeredStructure M ε Q t).carrier` is provable

`N.carrier = {v : M.carrier // ¬ Q v ∨ ContempEquivDense M ε t v}` (`TruthTransfer.lean:188-195`).
Given `[DenselyOrdered M.carrier]`, `hε` (clauses at `M` only) and `hS : IsBadIntervalSurgery M ε
Q t`, take `x < y` in `N` and case on `x.property`, `y.property`:

| Case | Witness | Landed machinery |
|---|---|---|
| both in `I` | `M`-dense `w ∈ (x,y)`; `w ∈ I` by convexity | `contemp_of_mem_class_interval` (`NoGaps.lean:439`) |
| `x ∈ I`, `¬Q y` | `t < y` by `isBad.convex`; `I` has no last point ⇒ class-mate `w > x`; `w < y` | `exists_contemp_gt`, `endsInGapOnRight_of_mem`, `mem_of_contemp_base` (`TruthTransfer.lean:246`), `lt_of_after` (`:260`) |
| `¬Q x`, `y ∈ I` | `x < t` by `isBad.convex`; `I` has no first point ⇒ class-mate `w < y`; `x < w` | `exists_contemp_lt`, **new** `endsInGapOnLeft_of_mem`, `mem_of_contemp_base`, `lt_of_before` (`:253`) |
| `¬Q x`, `¬Q y`, straddling | `t` itself, via `contemp_refl` | `lt_or_gt_of_not_mem` (`:267`) |
| `¬Q x`, `¬Q y`, same side | `M`-dense `w ∈ (x,y)`; `¬Q w` by `lt_of_after`/`lt_of_before` | as above |

`Countable N.carrier` is `Subtype.countable` from `[Countable M.carrier]`.

`Nonempty` is free (`t ∈ I`). The degenerate configuration `Q = ⊤` (so `N = I`) falls under the
first row.

**No circularity**: the proof of `DenselyOrdered N` projects `hε`'s clauses only at `M`, never at
`N`. The instances it produces are then what license the projection at `N` on line 608.

**Not a disguised vacuous hypothesis**: `IsBadIntervalSurgery.interior` — the sole source of the
`R`-and-`L`-throughout content — is **not** an open assumption. `StepD.hasBadIntervalSurgery`
(`NoGaps.lean:829`) discharges `HasBadIntervalSurgery M ε` at every structure with no extra
hypothesis, which is what makes `no_gaps_dense_prior` (`NoGaps.lean:901`) the unconditional-in-
that-respect form.

### 1.4 A measurement discrepancy, stated rather than smoothed over

The plan records (`v10:4759-4766`) that the CD weakening was attempted by "restricting the clauses
in place and propagating the instances through Lemma34/Lemma5/BadIntervals/TruthTransfer/NoGaps".
The reverted commit `3be9b82d8` touched **three** files — `Defs.lean`, `Dual.lean`,
`Lemma34.lean` (113 insertions) — and its own message says only *"Defs, Lemma34 and Dual
scoped-build green"*. The propagation through `BadIntervals` (27 binders), `TruthTransfer` (11),
`NoGaps` (14), `Lemma5` (9) and `Singletons` (8) was **not** landed; the `reynolds_lemma9` failure
was predicted from reading, not observed from a build. That does not make the localization wrong —
my independent audit in §1.1 confirms it is the only site — but the remaining propagation is real
work still to do, and the plan's phrasing overstates what was measured.

The reverted commit's **design** is worth recovering: it split clause (i) into `refl`/`symm`/
`trans` with the instances riding on `trans` alone, keeping `IsContempEquivDense.equiv` as a
reassembling accessor so call sites read unchanged. That keeps `refl` and `symm` instance-free and
is materially cheaper than restricting the whole of clause (i).

---

## 2. Recommended disposition: **(a) reachable via a section-6 repair**

### 2.1 The route

**New declarations** (all in `DenseModelSurgery/`, all short):

1. `endsInGapOnLeft_of_mem` — `NoGaps.lean`, immediately after
   `endsInGapOnRight_of_mem` (`:505`). Mirror of those three lines through
   `ClassInteriorToBadInterval.lThroughout` instead of `.toR.rThroughout`. ~4 lines.
2. `exists_contemp_gt_of_mem` / `exists_contemp_lt_of_mem` — for `i` with `Q i`, a class-mate of
   `t` strictly above / below `i`. Compositions of (1), `endsInGapOnRight_of_mem`,
   `exists_contemp_gt`/`exists_contemp_lt`, and `mem_of_contemp_base`. ~10 lines each.
3. `countable_surgeredStructure` — `Subtype.countable`. ~2 lines.
4. `denselyOrdered_surgeredStructure` — the five-case argument of §1.3. ~45-60 lines.
5. `isContempEquivDenseCD_dualize` + `Countable`/`DenselyOrdered` transfer at `dual M` — mirrors
   `isContempEquivDense_dualize` (`Dual.lean:461`) with `OrderDual.denselyOrdered` and
   `inferInstanceAs`. ~25 lines.

**Then** restate the §6 chain on the CD bundle, supplying the instances at `N` from (3)+(4) at
`NoGaps.lean:608` and at `dual M` from (5). Files and binder counts:
`Defs.lean` (2), `Dual.lean` (1), `Lemma34.lean` (20), `Lemma5.lean` (9),
`BadIntervals.lean` (27), `TruthTransfer.lean` (11), `NoGaps.lean` (14),
`Singletons.lean` (8) — 92 binders, plus `ChronicleInstance.lean` (3).

Most of these live on section `variable` lines, so the mechanical edit is ~15-25 `variable`
lines plus the ~12 explicit-binder declarations, not 92 separate edits. Recovering
`3be9b82d8` covers `Defs`/`Dual`/`Lemma34` (three of the eight files) as a starting point.

**Consumption at the chronicle structure**: `IsDensePriorSepStructure`
(`ChronicleMonadicBridge.lean:1027`) already carries `countable` and `denselyOrdered` as fields,
and `chronicleIsDensePriorSepStructure` (`:1053`) is its instance. So the new binders are
satisfied at the exact structure Phase 29's checkbox instantiates at. `DoetsD1`/`DoetsD2`
(`DoetsTheorem.lean:361,368`) then take `no_gaps_dense_prior`/`no_gaps_dense_prior_left`/
`dense_singletons_of_sep` in their CD forms with no adapter, exactly as the Phase 29 checkbox at
`v10:4798` was written to expect.

**Estimated cost**: ~100-140 new lines plus ~90 binder-site edits across 8 files; no proof body
in §6 changes except the two supplied-instance sites. No new sorry. Territory: `DenseModelSurgery/`
— outside Phase 29's `Owns` (`RealModel/DoetsTheorem.lean`), so it needs its own phase.

### 2.2 The one real trade-off — and it is a plan-gate question, not a technical one

Restating §6 on the CD bundle **narrows** `no_gaps_dense_prior` and `dense_singletons_of_sep` from
"any Prior structure" to "any countable densely-ordered Prior structure". The plan's Block D gate
(`v10:4944-4946`) requires every pre-existing declaration to survive "with its conclusion
unweakened", and the Block F gate (`:4980`) says `git diff` must show "additions and
strengthenings only". A straight in-place restatement violates both.

Three resolutions, in my order of preference:

1. **Parameterize over a structure class.** Add
   `IsContempEquivDenseOn ε (C : OrderedMonadicStructure sig → Prop)` and state §6 against it plus
   closure hypotheses (`C M → C (dual M)`; `C M → IsBadIntervalSurgery M ε Q t → C (surgeredStructure M ε Q t)`).
   `C := fun _ => True` recovers today's unrestricted results verbatim; `C := countable ∧ dense`
   gives the CD results with closure discharged by (4)+(5). One refactor, no duplication, no
   weakening. Highest design cost, cleanest gate story.
2. **Explicit user waiver of the no-weakening gate for §6.** This is well supported by the source:
   Reynolds himself writes, printed p.176 (§6, `sec03…md:38`), *"Although we will only need to
   consider densely ordered `M` for the real numbers proof, it will be seen that we prove the
   result for any Prior structure."* The narrowing is therefore exactly the generality Reynolds
   says the real-numbers proof needs, and no downstream consumer in this tree uses §6 at a
   non-dense structure. Cheapest, but it is the user's call, not mine.
3. Duplicate the chain along a CD path. Largest, and I do not recommend it.

### 2.3 Why not (b), a different anti-vacuity witness

Adversarially: I looked for a witness that meets the checkbox's *purpose* without running §6 at
`IsContempEquivDenseCD`, and I did not find one that survives the same scrutiny that sank
`exists_realFlow_shuffleReal_point`.

The checkbox demands `doets_theorem_dense` **instantiated at
`chronicleIsDensePriorSepStructure`**. `doets_theorem_dense`'s hypotheses are `DoetsD1 sig M` and
`DoetsD2 sig M`, both universally quantified over `ε` with `IsContempEquivDenseCD ε`. There is no
way to feed that structure the theorem without producing those two terms at that `M`, and there is
no source for them other than §6. Any candidate witness is therefore one of:

- an instantiation at `epsTop` — vacuous twice over, by
  `not_endsInGapOnRight_epsTop` and `quotientDenselyOrdered_epsTop_vacuous`
  (`ChronicleInstance.lean:51-52`, `Singletons.lean:574-580`). Excluded by the plan's own caveat.
- a witness at some *other* structure — which is `exists_realFlow_shuffleReal_point` again,
  better dressed. It exercises Layer 3's conclusion shape, not D1/D2 at the chronicle. Already
  judged insufficient, correctly.
- `DoetsD1`/`DoetsD2` assumed as hypotheses of the named definition — that is the vacuous-
  hypothesis failure mode the escalation explicitly asked me to hunt for, and it is worse than
  leaving the checkbox open, because it would *look* discharged.

So (b) is not available. The checkbox is genuinely gated on §6.

### 2.4 On (c)

Not recommended, and note it is also not needed: because Phase 30's terminus depends on the same
D1/D2 discharge (§3), the §6 repair belongs **inside this task and this plan** as a new phase, not
rehomed to a separate task. That sidesteps the `[COMPLETED WITH EXCLUSIONS]` admission problem
entirely — nothing is rehomed, so condition 5 of
`.claude/context/standards/status-markers.md` is not in play. Phase 29 stays `[PARTIAL]` for one
more cycle and closes `[COMPLETED]` once the new phase lands.

**Concrete plan edit recommended**: insert a phase (numbering suggestion: **22.2, "§6 on the
countable-dense bundle"**, since it belongs with Block F's §6 work and Phase 22.1 already owns
`ChronicleInstance.lean`) that **Owns** `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/`
{`Defs`, `Dual`, `Lemma34`, `Lemma5`, `BadIntervals`, `TruthTransfer`, `NoGaps`, `Singletons`}`.lean`,
with the deliverables of §2.1 and an explicit decision recorded for §2.2. Phase 29's checkbox then
gains `Depends on: 22.2`.

---

## 3. Is Phase 30 blocked? — Partly, and the blocked part is its terminus

Phase 30's six substantive tasks (`v10:4855-4881`):

| Task | Blocked by the anti-vacuity item? |
|---|---|
| Define/locate the table `α(t)` and quantifier depth; set `k` (`:4855`) | **No.** Self-contained in the `tableMu`/`staviFoDepth` layer (`EFGames/StaviCompleteness.lean:237,462`). |
| Prove the `≡ₖ` transfer `R ⊨ ∃t α(t)` from `M ⊨ ∃t α(t)` (`:4858`) | **No.** Takes the `KEquiv` as a hypothesis; does not need a witness for it. |
| `countermodel_dedekind_dense` — convert the ℝ-flowed structure back to `TaskFrame ℝ` (`:4860`) | **YES.** Needs the ℝ-flowed structure *at the chronicle*, i.e. `doets_theorem_dense` applied there, i.e. `DoetsD1`/`DoetsD2` discharged — the identical obstruction. |
| `completeness_dedekind_engine` (`:4868`) | **YES**, transitively. |
| Instantiate `consequence_completeness_dedekind_of_engine` (`:4873`) | **YES**, transitively. |
| `completeness_dedekind` as the corollary (`:4876`) | **YES**, transitively. |

**Plain answer**: Phase 30 can be dispatched **now** for its first two tasks, and that is genuine
forward progress the task can make next cycle. Its engine and its unconditional terminus cannot
land until the §6 repair does. The anti-vacuity checkbox and Phase 30's terminus are not two
problems — they are one, which is the strongest argument for taking route (a) rather than
rehoming it.

---

## 4. Reynolds citations used (read from the printed text, not reconstructed)

| Claim | Printed location | Local file |
|---|---|---|
| *"Although we will only need to consider densely ordered `M` for the real numbers proof, it will be seen that we prove the result for any Prior structure."* | §6, p.176 | `sec03_6-no-gaps-between-equivalence-classes.md:38` |
| Reynolds explicitly handles *"the case of `M` not being dense"* in Lemma 3 | §6, p.178 | `sec03…:46` |
| *"We look at `N`, the substructure of `M` whose domain is just `Q⁻ ∪ I ∪ Q⁺`."* — and no argument that `N` is dense, because `∼` is assumed contemporaneous at every structure | §6, p.181 | `sec03…:112` |
| Lemma 6 first clause, *"in any bad interval both `R` and `L` hold throughout"* | §6, p.180 | rendered as `ClassInteriorToBadInterval` (`BadIntervals.lean:1023`) |
| Lemma 4, *"no last class and no first class in any maximal interval of `R`"* — about **classes** | §6, p.180 | `BadIntervals.lean:411-412` |
| Consequence relation for `FrameClass.Dedekind` is not compact ⇒ weak completeness is the terminus | §2, p.169 | not reopened; recorded at `StrongCompleteness.lean:287` |

---

## 5. Adversarial Self-Verification

| Claim | Source / Counterexample | Verification method | Confidence |
|---|---|---|---|
| `NoGaps.lean:608` is the **only** site projecting clauses (i)/(ii) at `surgeredStructure` | `NoGaps.lean:467` is clause (iii), unrestricted in CD | Exhaustive grep of all `hε.{equiv,convex,contemporary}` / `contemp_{refl,symm,trans,of_between} hε` / `endsInGap*_congr hε` occurrences across `DenseModelSurgery/*.lean`, filtered for non-`M` structure arguments | High |
| Every `hε` projection in Lemma 8 (`TruthTransfer.lean`) is at `M` or `dual M`, never at `N` | The two `isContempEquivDense_dualize hε` uses at `:730,752` go through `isBadIntervalSurgery_dual` at `dual M` | Read `TruthTransfer.lean:427-600, 700-760`; `lean_local_search` confirms `isBadIntervalSurgery_dual` exists | High |
| `I` has no first and no last point in the surgery set-up | `ClassInteriorToBadInterval.lThroughout` (`BadIntervals.lean:1028`) + `.toR.rThroughout` (`:433`), both supplied by `IsBadIntervalSurgery.interior` (`TruthTransfer.lean:218`); consumed by `exists_contemp_lt` (`:1011`, docstring *"The class has no first point"*) and `exists_contemp_gt` (`Lemma34.lean:265`) | Read the four declarations and the existing `endsInGapOnRight_of_mem` (`NoGaps.lean:505-508`) that already performs the `R` half | High |
| The recorded refutation of `DenselyOrdered N` is invalid | It infers point-adjacency from Lemma 4, which quantifies over **classes**; adjacency additionally requires `I` to have a least/greatest element, refuted by the row above | Read `DoetsTheorem.lean:347-356` and `v10:4759-4766` against `BadIntervals.lean:411-433, 1018-1028` | High |
| `DenselyOrdered N.carrier` is provable | Five-case analysis of §1.3; every step cites a landed declaration (`isBad.convex` `BadIntervals.lean:270`, `lt_of_before/after` `TruthTransfer.lean:253,260`, `lt_or_gt_of_not_mem` `:267`, `mem_of_contemp_base` `:246`, `contemp_of_mem_class_interval` `NoGaps.lean:439`) | Hand-verified case analysis against read signatures. **Not machine-checked** — I did not edit files, and `lean_multi_attempt` needs an in-project position. This is the one load-bearing claim carrying implementation risk. | Medium-High |
| The route does **not** reintroduce a vacuous hypothesis | The `DenselyOrdered`/`Countable` instances at `N` are **derived**, not assumed; `IsBadIntervalSurgery.interior` is discharged unconditionally by `StepD.hasBadIntervalSurgery` (`NoGaps.lean:829,901-907`); the new binders on `M` are satisfied at the chronicle by `IsDensePriorSepStructure.{countable,denselyOrdered}` (`ChronicleMonadicBridge.lean:1027-1030`) instantiated at `chronicleIsDensePriorSepStructure` (`:1053`) | Read all four; this is the check the escalation asked for explicitly | High |
| `DenselyOrdered`/`Countable` transfer to `dual M` | `(dual M).carrier = M.carrierᵒᵈ` by `rfl` (`Dual.lean:118,122`); `OrderDual.denselyOrdered` exists in Mathlib | `lean_loogle "DenselyOrdered (OrderDual _)"` → `OrderDual.denselyOrdered`, `denselyOrdered_orderDual`. `Countable αᵒᵈ` has **no** named instance (loogle: empty) — it needs `inferInstanceAs (Countable M.carrier)`, which works because `OrderDual` is a plain `def`. The tree already uses this idiom at `ChronicleMonadicBridge.lean:375`. | High |
| Option (a) weakens landed §6 conclusions, engaging the plan's census gates | `v10:4944-4946` ("conclusion unweakened") and `:4980` ("additions and strengthenings only") | Read both gates. **This is a genuine cost of my recommendation and I am not minimizing it** — §2.2 gives three resolutions rather than asserting the gate is satisfied. | High |
| Phase 30's `countermodel_dedekind_dense` is blocked by the same obstruction | `v10:4860-4867` requires the ℝ-flowed structure at the chronicle, which is `doets_theorem_dense` applied there, which needs `DoetsD1`/`DoetsD2` (`DoetsTheorem.lean:361-371`) | Read the task text and the D1/D2 definitions | High |
| Phase 30 tasks 1-2 are **not** blocked | `:4855` is a table/depth definition in the `tableMu`/`staviFoDepth` layer; `:4858` takes `≡ₖ` as a hypothesis | Read the task text. **Weaker than the rest of this table**: I did not open `EFGames/StaviCompleteness.lean` to confirm the table layer suffices — the task itself says "or verify", so the verification is part of the work either way. | Medium |
| The plan overstates the extent of the reverted attempt | `3be9b82d8` diffstat: 3 files, 113 insertions, `Defs`/`Dual`/`Lemma34` only; its own message claims green only for those three. `v10:4759-4761` names five files as propagated. | `git show --stat 3be9b82d8`, `git log -1 --format=%b 3be9b82d8` | High |

### Contradiction log

**Resolved.** `DoetsTheorem.lean:350-353` + `v10:4762-4764` assert `DenselyOrdered
(surgeredStructure …)` is *false*; §1.3 asserts it is *provable*. Precedence: both are claims
about this tree's own Lean content, so the resolving authority is the source, not either prose
record. The source (`BadIntervals.lean:1023-1028`, `:433`, `:1011`; `NoGaps.lean:505-508`) shows
the class has no endpoints, which is the exact missing premise of the recorded argument. The
recorded claim was reasoning about classes where points were needed. Resolved **against** the
recorded claim, with the residual caveat that my replacement is hand-verified rather than
machine-checked (see the Medium-High row above).

**Recommendations modified after verification.** My first pass planned to recommend a straight
in-place CD restatement of §6. Re-reading the plan's Block D/F census gates showed that weakens
landed conclusions and trips two gates; §2.2 was rewritten to lead with the class-parameterized
design and to surface the waiver as an explicit user decision rather than assuming it.

---

## 6. Not reopened

The weak-completeness terminus (`completeness_dedekind` +
`consequence_completeness_dedekind`); the provable unavailability of infinite-premise strong
completeness for `FrameClass.Dedekind`; the Doets route; Layers 5-14 as landed; and the four
pinned `StrongCompleteness.lean` signatures (`consequence_completeness_dedekind_of_engine`,
`completeness_dedekind_of_engine`, `soundness_dedekind_consequence`,
`SemanticConsequenceDedekindDense`). Nothing in this report restates, reorders or re-binds any of
them; the §6 repair is upstream of all four and does not touch `StrongCompleteness.lean`.
