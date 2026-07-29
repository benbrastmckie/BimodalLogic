# Phase 7, fourteenth dispatch — the `ordResp` fork settled, and `boxNeg` refuted

**Status**: PARTIAL. Sub-phase 7.2 stands at **15 of 28 rules** sorry-free and is **not closed**.
Its assembly target has been measured **false**.

## What landed

Two green commits, each verified by `git show --stat` for content.

1. **`6fa0b5c` — the `ordResp` fork settled, and the four temporal universal rules** (+288).
   The ordering bridge (`mem_constraints_of_mem_directFutureOf` and its past dual,
   `lt_of_pathN_directFutureOf`/`lt_of_pathN_directPastOf`, `SatState.lt_of_mem_futureOf`/
   `gt_of_mem_pastOf`), then `allFuturePos`, `allPastPos`, `someFutureNeg`, `somePastNeg` as one
   shape family.
2. **`61673fc` — the `boxNeg` preservation measurement** (+159/−11).
   `Tests/BimodalTest/BoxNegPreservationProbe.lean`, five pinned rows, plus the rewrite of
   `Verified/Decidable.lean`'s standing note.

## The `ordResp` fork, settled by measurement

The previous dispatch stopped at this fork rather than guess. It resolves to **route (a)**:
`SatState.ordResp` stays on `ord.constraints`, and the transitive closure the four temporal
universal rules consume is bridged once on the **consumer** side.

The measurement is the producers' ledger, taken before adopting (b) as instructed. Every
fresh-time rule returns `timeOrd.addFuture l.time branch.nextTime` — a new edge consed onto the
list. Under the strengthened field each of **six** sites would owe the closure property for the
*extended* ordering, which needs a path-factorisation lemma over `(t, tNew) :: cs` that is not in
the tree. Under the field as it stands each owes only `∀ p ∈ (t, tNew) :: cs, tv p.1 < tv p.2` —
head from its own witness, tail from the state handed in. Six harder obligations against four
consumers sharing one lemma. The definition is unchanged.

The `Verified/Termination/Fuel.lean` import edge was weighed explicitly: intra-`Verified/`,
adding no cross-tree edge, unlike the `Metalogic.Soundness` edge the previous dispatch declined.

## A Lean fact that changed proof shape

`Formula.allFuture` and `Formula.allPast` are **definitions, not constructors** — `G A` unfolds to
an `imp`. So `cases φ` cannot separate `G A` from a general implication, and the two positive
rules cannot be driven the way `boxPos` is driven by the genuine `.box` constructor. They are
driven by `split` on `applyRule`'s own matcher. Four point-form truth lemmas keep the arms free of
any dependence on how `split` names what it binds.

## The principal finding: `RuleSound carrierBase .boxNeg` is false

Reading the `boxNeg` arm produced a **prediction about an existing pinned row**: on verdict-row B,
`(G p) → □(G p)`, the fresh world receives the witness `F(G p)` *and* the group-3 copy `T(G p)`,
so the successor should close and the row should read `true`. The pinned row reads `false`.

A prediction contradicting a pinned measurement is a fact to be measured, so it was.
`applyRule .boxNeg`, applied to the branch `T(G p) @ (w₀,t₀)`, `F(□(G p)) @ (w₀,t₀)`, emits
**exactly two formulas, both at the minted label, being the same formula with opposite signs**.

- The branch is **satisfiable**, precisely because `(G p) → □(G p)` is invalid — which is what
  row B's `false` records.
- Its successor is **unsatisfiable** for every `hist` and `tv`, since `SatAt` reads the pair as
  `TruthAt …` and `¬ TruthAt …` at one point.
- Therefore `RuleSound carrierBase .boxNeg` is **false** — not unproved but unprovable — and
  `diamondPos` carries an identical `tempGProps` block.
- Therefore the assembly `∀ r ∈ allRulesForFC fc, RuleSound _ r` **cannot be proved as stated**,
  both rules being members at every frame class. That assembly is 7.2's target.

**No engine defect is claimed**, and row 5 pins why: the verdict on the same formula is still
`false`. The engine never applies `boxNeg` to that branch — `T(G p)` is itself an `imp`, so the
propositional schedule reaches it first — which is also *why* the three verdict rows came back
clean: they do not exercise the copy in the engine's own run. The prior dispatch was not wrong
about what it measured; it was measuring the wrong thing for this obligation, and said so.

## The fork this opens, deliberately unguessed

`RuleSound` must be weakened for these two rules by a hypothesis excluding branches the engine
never builds — schedule reachability being the obvious candidate — and the assembly must thread it
through the tableau induction. Which invariant is strong enough for these two and cheap enough for
the other twenty-six is measurable, and was not chosen on spec.

## Newly found blocker

All four fresh-time existential rules emit `boxDiamondPersistence`, which is **private** to
`Tableau.lean`. The only lemma exposing it says the formula came from the branch and nothing about
label or sign — exactly what soundness needs. A label-level companion lemma is required before any
fresh-time rule can be proved.

## Verification

| Check | Result |
|---|---|
| `lake build …Verified.Decidable` | green, exit 0, zero errors |
| `lake env lean` on the module | green (2 unused-section-variable warnings) |
| `lake env lean` on the new probe | green, all 5 pinned rows matching |
| olean symbol check | all four new rules + bridge present in the compiled artifact |
| sorry census over `Verified/` | **0** |
| vacuous definitions / new axioms | 0 / 0 |

**Full `lake build` was not completed**: two attempts were destroyed mid-flight by a concurrent
session deleting `Tableau.olean` and `SubformulaProperty.olean`. Blast radius is one leaf module
plus one new test file; no engine file and nothing under `Verified/Bridge/` was touched. Expect
1942 jobs (1941 + the new probe) once re-established.

## Process notes

- **Probe before proving changed the answer for the eleventh consecutive dispatch**, this time
  overturning a conclusion that was itself the product of a probe.
- **Price both sides of an invariant before strengthening it** — the `ordResp` answer inverted the
  intuition that a stronger field is more convenient.
- **A measurement channel must itself be verified.** `mcp__lean-lsp__lean_run_code` reports
  `success` on code that does not compile in this project (control: `example : (1:Nat) = 2 := by
  rfl` returns clean). It was trusted for two probes before the control exposed it; those results
  were re-verified by `lake env lean` before being committed.
