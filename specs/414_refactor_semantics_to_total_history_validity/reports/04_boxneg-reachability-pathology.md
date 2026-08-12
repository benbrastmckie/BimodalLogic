# Report 04 — BoxNegReachability probe pathology and the `(G p) → □(G p)` question

- **Task**: 414 — refactor_semantics_to_total_history_validity (phase 22 terminus)
- **Started**: TBD
- **Completed**: TBD
- **Effort**: TBD
- **Dependencies**: TBD
- **Sources/Inputs**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Status**: [FINDINGS] — written 2026-08-11 while the phase-22 `lake build BimodalTest`
  verification gate was still running (killed by hand after this report; see §5)
- **Context**: `git log` HEAD is `03c67767f task 414 phase 22.2: retire the Omega architecture
  from the semantics prose`; the `lake build BimodalTest` invoked under
  `timeout 3000` by an agent dispatch is this phase's verification gate. The two long-running
  `lean` jobs are `BoxNegReachabilityProbe.lean` and `CrossWorldPropagationProbe.lean` under
  `Tests/BimodalTest/`, both edited 2026-08-11 07:05-07:06 as part of phase 22 verification.
- **Lean Intent**: false (this report changes no Lean files)

## 1. Question asked

Is `(G p) → □(G p)` valid in the post-refactor totality semantics, and is there a performance
improvement available given what the principle lets us show?

## 2. Answer: the principle is INVALID

From the live semantics (`FormalSystem/Semantics/Truth.lean`):

- `box_iff` (:223-230): `TruthAt M τ t φ.box ↔ ∀ σ : WorldHistory F, σ.IsTotal → TruthAt M σ t φ`
- `future_iff` (:272-285): `TruthAt M τ t φ.allFuture ↔ ∀ s : D, t < s → TruthAt M τ s φ`

So for `gp = G p = allFuture p`:

```
TruthAt M τ t ((G p) → □(G p))
  = (∀ s > t. p(τ,s)) → (∀ σ total. ∀ s > t. p(σ,s))
```

The antecedent quantifies over the **current** history `τ` only. The consequent quantifies over
**every** total history `σ`. Nothing in the box clause links the two. Countermodel (two total
histories over one frame, `D` nonempty with a successor):

- `w₀` with `p ∈ V(w₀)`, `w₁` with `p ∉ V(w₁)`; `TaskRel w₀ d w₀` and `TaskRel w₁ d w₁` for all
  `d` (serial, spherical, all axioms hold).
- `τ := const w₀`, `σ := const w₁`. Both total.
- At `(τ, t)`: `G p` holds (`p` at every future time on `τ`). `□(G p)` fails (at `σ`, `p` fails
  at every future time). Implication is `false`. **Invalid.**

The correct decision-procedure verdict is `.invalid` with a two-world countermodel. The engine's
current `(0,0)` (`fuelExhausted`) is honest *undetermined*, and a strict improvement over the
pre-repair `(1,1)` (`allClosed`, i.e. "valid") that `BoxNegReachabilityProbe` row 9 documents as
the defect. But note the target end state the probe itself names is `(2, _)` (`hasOpen`), not
`(0,0)` — the probe pins the search as **not yet reaching its own target**.

## 3. Why the tableau cannot find the (tiny) countermodel

The negated goal is `(G p) ∧ ◇ ¬(G p)`. Expansion:

- root world `w₀` carries `T (G p)` — p demanded at every future time of `w₀`;
- `boxNeg` (negating the box) mints a fresh world `w₁` carrying `F (¬p)` — a witness time `s > t`
  with `¬p` at `(w₁, s)`.

The repair recorded in this probe (the six group-3 `tempGProps` blocks deleted) means `T(G p)` is
**no longer copied** from the root world into the minted world. Semantically that is correct — a
different history `σ` need not inherit the root history's temporal obligations — and it removes
the spurious clash that previously closed the branch. But it leaves the root branch carrying
`T(G p)`, which keeps demanding p at *every newly minted future time*. Those obligations are on
`w₀`, the witness `¬p` is on `w₁`, so no contradiction arises; instead the branch never saturates
(`findUnexpanded` never returns `none`) and burns fuel 30/60/400/1000 alike, returning `(0,0)`.
The probe itself records this at `BoxNegReachabilityProbe.lean:217`: *"Fuel 30, 60, 400 and 1000
all return `(0, 0)`, so the ceiling is not bracketed from above and this is a termination/bound
question rather than a budget one."*

Structural reason for the blow-up: the root temporal universal `G p` generates a fresh time
obligation on `w₀` for every future time considered, and temporal blocking (subsumption by a
saturated ancestor) cannot fire because no time type on `w₀` ever saturates — every type adds p
and spawns more times. The countermodel only needs **two worlds and one witness time**, but the
search cannot see that the root's universal is irrelevant to the witness world.

## 4. Containment / performance directions (for follow-up)

All are about teaching the search to find the two-world countermodel without expanding the root
temporal universal exhaustively:

1. **Witness-first strategy for `boxNeg` + `F`**: when `◇ ¬(G p)` (a `boxNeg`-minted world
   carrying a future-eventuality `F ψ`) must be witnessed, prefer minting one witness time and
   asserting `ψ` there, then check cross-world clash — rather than interleaving the root
   universal's infinite time generation. The countermodel needs exactly this witness; nothing else
   on the minted world is load-bearing.
2. **Recognise the cross-world-propagation shape**: formulas of the shape `φ → □ φ` (root
   obligation `T φ`, box-negated world obligation `F ¬φ`, distinct worlds, no copied obligations)
   admit a bounded two-world saturating check. This is the class this probe and
   `CrossWorldPropagationProbe` are measuring; a structural rule would return `.invalid` in
   constant time.
3. **Fuel-insensitive rejection**: the probe shows fuel 30/60/400/1000 all agree on `(0,0)`. When
   a branch is a "root universal + minted-world eventuality" pair with no cross-world copy, the
   result is known to be non-saturating *a priori*; an early-exit (`hasOpen`-bounded) signal is
   defensible and does not compromise coverage, because it returns the *same* verdict the fuel
   sweep converges to.
4. **Do not re-baseline the probe expectations as part of this refactor.** The plan's carried
   caveat (plan :83-89) and six dispatches' decline stand: the probe expectations were baselined
   2026-07-29, `Saturation.lean` last changed 2026-08-05 under separate work, and nothing in this
   refactor touches a `#eval`-reachable computable definition. If any follow-up changes the search
   strategy above, the probe rows *will* legitimately move and must be re-baselined *then*, with
   the change recorded against `Decidability/Saturation.lean`, not silently.

## 5. Process facts and action taken

- The two `lean` processes (`BoxNegReachabilityProbe`, `CrossWorldPropagationProbe`) each pinned a
  full core at ~99.7% for >45 min. `CrossWorldPropagationProbe` completed at 2418s under the first
  (timeout-bounded) build; `BoxNegReachabilityProbe` did not and was killed by `timeout 3000`
  (`EXIT=124`), leaving no `.olean`.
- A second build was relaunched without a timeout (`lake build BimodalTest`), replayed the 2377
  cached targets, and re-entered the same `BoxNegReachabilityProbe` `#eval` grind.
- **The second build was killed on 2026-08-11 at the user's request** after this report was
  written, because a more optimal build path is wanted that draws on §4 before re-running the
  probe file. No Lean source was changed.
- Pre-existing, unrelated to the runtime: `lake build BimodalTest` reports ten
  `#guard_msgs` docstring mismatches (`TableauConformance` 7, `RegionGateProbe` 2,
  `BoxSpreadProbe` 1) that do not stop the build; they are the carried caveat of the plan.
