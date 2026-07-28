# Phase 5 Summary — Bridge Infrastructure (BranchOrder, Embed, Carrier)

- **Plan**: `specs/165_establish_semantic_finite_model_property/plans/01_tableau-decidability-two-track.md`
- **Phase**: 5 of 8 — `[COMPLETED]`
- **Status**: sorry-free; `lake build FormalSystem.Metalogic.Decidability` and
  `lake build BimodalTest` both green
- **Session**: `sess_1785244791_96fa7d`

## What landed

Three new files, all under the phase's declared territory `Verified/Bridge/`:

| File | Lines | Content |
|---|---|---|
| `Verified/Bridge/BranchOrder.lean` | ~437 | 5.1 — the gate, the index type, `LinearOrder (BranchTime b)`, 6 probe rows |
| `Verified/Bridge/Embed.lean` | ~118 | 5.2a — finite order into a dense carrier, and into `ℤ`; 1 probe row |
| `Verified/Bridge/Carrier.lean` | ~206 | 5.2b — `TemporalCarrier fc D`, four instances, the placement lemma |

`FormalSystem/Metalogic/Decidability.lean` gained the three imports so `lake build` covers them.

## 5.1 — the design refinement the plan text did not anticipate

The plan's premise was that a saturated branch **carrying `timeOrderTotal`** suffices to package
`BranchOrder b ord : LinearOrder (Fin n)`. It does not, and the shortfall is not cosmetic:

- **Transitivity of `strictBefore` is not a theorem.** `TimeOrdering.futureOf` is a *fuel-bounded*
  BFS (default `fuel := 100`). At any fixed fuel there is a constraint list on which it
  under-reports, so "`futureOf` is a transitive closure, hence transitive" is false as stated
  about the function the engine actually calls.
- **Antisymmetry fails on a cyclic constraint list.** `addFuture` never checks for cycles. The
  pinned probe shows `timeOrderTotal chainBranch ⟨[(0,1),(1,2),(2,0)]⟩ = true` — totality reports
  `true` for an order that is inconsistent, because a cycle makes every time reachable from every
  other.

Both conditions are decidable on the finitely many branch times, so the landed gate is still
**one `Bool`**, carried on a certificate exactly the way `timeOrderTotal` was designed to be:

```
branchOrderValid b ord := timeOrderTotal b ord && orderIrrefl b ord && orderTransOn b ord
```

The order-level branching rule's done-criterion is unchanged in kind — one more conjunct to flip,
measured the same way.

**Indexing**: `BranchTime b := Fin b.knownTimes.length`, the simple indexing, not the
`ord.constraints ∪ knownTimes` union the plan left open. 2.5's non-destructive expansion removed
the cause of the report 04 §Q2.2 symptom; union indexing would additionally force the bridge to
invent semantic content for times carrying no formulas, which the truth lemma has nothing to say
about.

**Construction route**: `linearOrderOfSTO` applied to a strict relation `branchLT`, not a
hand-rolled `LinearOrder` literal. Measured: a literal with an opaque `le` field cannot synthesise
the `rfl` defaults for `lt_iff_le_not_ge`, `min_def`, `max_def`,
`compare_eq_compareOfLessAndEq` — four errors. `branchLT` carries an index-level tiebreak
(`timeAt i = timeAt j ∧ i < j`) so trichotomy and irreflexivity hold with no
`List.Nodup b.knownTimes` side condition threaded through every downstream lemma; the tiebreak
never fires on a real branch, since `knownTimes` is `eraseDups`.

**Recorded in-code** (plan constraint 4): the SETTLED blocking semantics — identification/deletion,
never edge-addition — with the structural reason (`TimeOrdering` is a list of *strict* pairs and
cannot express `t_new = t_anc`), the reason `(t,t)` constraints are dropped, and the consequence
Phase 7.1's loop-unwinding argument relies on (identification shrinks `knownTimes`, giving a
strictly decreasing creation index in both directions after 2.6's bidirectional blocking).

**Recorded as an explicit non-goal**: no Mathlib linear extension of a partial branch order
(`extend_partialOrder` / `LinearExtension`), with the `¬(F(G p) ∧ F(¬p))` counterexample spelled
out — exactly one of the two extensions is a model and the branch does not record which.

## 5.2 — the carrier class

`FrameConditionFor fc D` is **`Type`-valued, not `Prop`-valued**, and `.Discrete` forces it:
`ValidDiscrete`'s binder list contains `[SuccOrder D]` and `[PredOrder D]`, and those are *data*
(`SuccOrder : (α : Type u) → [Preorder α] → Type u`), not propositions. A `Prop` field could at
best carry `Nonempty (SuccOrder D)`, and every downstream use would then have to `Classical.choice`
its way back to an instance with no guarantee that two uses pick the same successor function.
`DiscreteStructure` is a structure rather than a product because `IsSuccArchimedean` is indexed by
the `SuccOrder` instance.

The two embedding routes are genuinely different and are not reused across each other, as the plan
required: `ℚ`/`ℝ` via `Order.embedding_from_countable_to_dense` (finiteness discharges its
`[Countable α]`), `ℤ` via a hand-rolled `Fin n ↪o ℤ` by `Nat`-cast composed with `monoEquivOfFin`.
`ℤ` is not densely ordered, so the dense lemma does not apply under any weakening.

Four instances elaborate: `.Base ℚ`, `.Dense ℚ`, `.Discrete ℤ`, `.Dedekind ℝ`.

## Mathlib-name verification (plan constraint 2)

One batch `#check` pass under the files' own import set, containing a deliberate control error. The
control reported `unknown identifier`, so the successful checks are evidence rather than an
assumption that the mechanism was live. **Two of the plan's names were refuted by this pass:**

| Plan's name | Verdict | Correction |
|---|---|---|
| `Real.isLUB_sSup` | does not exist | `isLUB_csSup` (general, at the conditionally complete lattice `ℝ`) |
| `OrderEmbedding.trans` | does not exist | `RelEmbedding.trans` (`↪o` unfolds to `RelEmbedding`) |

Confirmed: `Order.embedding_from_countable_to_dense` (α and β **explicit**), `monoEquivOfFin`,
`OrderEmbedding.ofStrictMono`, `OrderIso.toOrderEmbedding`, `Fintype.ofFinite`, and `ℤ`'s
`SuccOrder`/`PredOrder`/`IsSuccArchimedean`/`IsPredArchimedean` instances.

## Interface Phase 6 starts from

```
exists_monotone_placement (fc : FrameClass) (D : Type) [...] [TemporalCarrier fc D]
    {b ord} (h : branchOrderValid b ord = true) :
    ∃ f : BranchTime b → D, Function.Injective f ∧
      ∀ i j, (BranchOrder b ord h).le i j ↔ f i ≤ f j
```

Stated with an explicit `.le` rather than an instance-in-statement `letI`: measured, `Fin`'s own
`instLEFin` wins over a `letI`-introduced `LinearOrder` in a `↪o` statement position, so the
`letI` form silently produced the wrong statement.

## Verification

| Check | Result |
|---|---|
| `bash .claude/scripts/lean-sorry-census.sh FormalSystem/Metalogic/Decidability/Verified/` | `sorry_count: 0` |
| `grep sorry Verified/Bridge/` | 0 |
| Vacuous definitions in `Verified/Bridge/` | 0 |
| New `axiom` declarations | 0 |
| `#print axioms` on `BranchOrder`, `exists_monotone_placement`, `embed_finite_to_dense`, `embed_finite_to_int` | `[propext, Classical.choice, Quot.sound]` only |
| `lake build FormalSystem.Metalogic.Decidability` | green (1104 jobs) |
| `lake build BimodalTest` | green (1953 jobs) |
| Regression corpus | +7 `#guard_msgs` rows (6 `BranchOrder.lean`, 1 `Embed.lean`) → 30 total |

Engine untouched: no edit to `Saturation.lean`, `Tableau.lean`, or `SignedFormula.lean`
(wave-3 territory contract honoured). No regression in `Verified/Termination/`.

## Plan deviations

One, and it is an addition rather than a substitution: task 5.1's gate is
`branchOrderValid` (three conjuncts) rather than `timeOrderTotal` alone. The plan's own
done-criterion — "`BranchOrder` sorry-free with a totality proof consuming `timeOrderTotal`" — is
met verbatim (`total_of_valid` consumes `timeOrderTotal`); the two extra conjuncts supply the
`LinearOrder` obligations totality does not imply, and the refutation of the "totality suffices"
premise is pinned as a probe rather than asserted.
