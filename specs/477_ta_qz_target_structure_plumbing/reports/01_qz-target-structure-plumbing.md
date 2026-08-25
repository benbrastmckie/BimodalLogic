# T-A: Target-Structure Plumbing for the Groupable-Companion Route — Research

**Task type**: lean4 · **Classification**: SMALL, MECHANICAL · **Mode**: orchestrator, `--lit`

## 1. Headline

The whole of T-A's deliverable was **written and compiled end-to-end during research**, with
zero sorries, zero errors, and clean axioms on the first attempt. The verified artifact is:

```
specs/477_ta_qz_target_structure_plumbing/verification/qz_structure_probe.lean   (91 lines)
```

Every declaration in it — `QZStructure`, `QZStructure.toMonadic`, `QZStructure.toOrdered`,
`QZStructure.toOrdered_carrier`, `goodGroupable`, `goodGroupable_of_kEquiv`,
`goodGroupable_of_orderIso`, the `NoMaxOrder`/`NoMinOrder` instances at the carrier, and
`noMaxOrder_of_goodGroupable` / `noMinOrder_of_goodGroupable` — elaborates and kernel-checks.
`#print axioms` reports `[propext, Classical.choice, Quot.sound]` for all five checked
declarations. Implementation is therefore a **transcription-plus-documentation** job, not a
discovery job: lift the probe into a module, write the repo-standard header, wire the build
edge, and re-run the invariant gate.

`lake build` at HEAD is green (2487 jobs) — baseline confirmed this session.

## 2. Literature Proof Structure

**Source**: M. Reynolds, *An Axiomatization for Until and Since over the Reals without the IRR
Rule* (1992), §8 "Doets' Theorem", printed p.185 — the *"good"* / *"very good"* definitional
preliminaries. **Strategy**: definitional transcription, not proof.

The governing planning document for this task chain is
`specs/422_build_discrete_chronicle_over_non_archimedean_block_carrier_with_restricted_coherence/reports/02_o1-verdict-k-equivalence-transfer.md`,
§§3, 4, 6 (read in full this session). Its companion `reports/01_...` records the **final**
refutations (O1 isomorphism; `succ_cofinal`) that this task must not re-attempt.

### Step map

1. *"the flow of time of `N` is an interval of the reals"* → the **target-structure type**
   — Reynolds §8, p.185 → `RIntervalStructure` (`RealModel/GoodDense.lean:175`); ℤ analogue
   `ZIntervalStructure` (`IntegerModel/GoodStructures.lean:35`); **this task** →
   `QZStructure`.
2. *"Say that `M` is good iff there is some `N ≡_k M` such that …"* → the **∃-notion**
   — `good` (`GoodStructures.lean:78`), `goodDense` (`GoodDense.lean:237`); **this task** →
   `goodGroupable`.
3. Elementary transfer of the ∃-notion along `≡_k` and along order isomorphism —
   `goodDense_of_kEquiv` (`GoodDense.lean:259`), `goodDense_of_orderIso` (`:265`);
   **this task** → the two `goodGroupable_of_*` twins.
4. *"since `k ≥ 2`, if `M ≡_k N` then `M` and `N` either both have a right (resp. left) hand
   end point or both do not"* — Reynolds §8, p.185 → `noMaxOrder_of_kEquiv`
   (`GoodDense.lean:469`), `noMinOrder_of_kEquiv` (`:485`), both sorry-free; **this task**
   specializes them at the `ℚ ×ₗ ℤ` target (see §5, which is where they earn their place).

### Dependencies

Step 2 depends on step 1. Steps 3 and 4 depend on step 2. Nothing in T-A depends on anything
that is not already landed and sorry-free.

### Formalization challenges

There are none of substance; the two genuine *design* decisions are §4 and §5 below. No step of
this task translates a proof — the source contributes definitions only, and both translations
already exist in the tree at two other carriers.

**No new literature extraction was required.** Reynolds §8 p.185 is transcribed verbatim in
`GoodDense.lean`'s module header (lines 24–41), compared against the 200 dpi page images and
recorded there as clean. This task consumes that transcription; it does not re-derive it.

## 3. Recommended module location and build wiring

**Path**: `FormalSystem/Metalogic/WeakCanonical/GroupModel/GoodGroupable.lean`

`GroupModel/` is the natural third sibling of `IntegerModel/` and `RealModel/` — the existing
directories are named for the carrier class, and the file names track the ∃-notion they land
(`GoodStructures.lean` → `good`, `GoodDense.lean` → `goodDense`, `GoodGroupable.lean` →
`goodGroupable`).

Two build-graph facts were checked against `scripts/check-module-invariants.sh` this session:

- **C8 (aggregator convention) does not apply.** C8 scans only the immediate subdirectories of
  `FormalSystem/` and `FormalSystem/Metalogic/` (script lines 419–420). `WeakCanonical/` is one
  level deeper, which is why `IntegerModel/` and `RealModel/` have no sibling aggregators today.
  **A `GroupModel.lean` aggregator must NOT be created** — it would be gratuitous and
  inconsistent with both siblings.
- **C6 (unreachable-module rot guard) does apply.** The new module has no consumer until T-B, so
  without an explicit edge it falls out of the `lake build` closure and C6 fails. Add it to
  `FormalSystem/Metalogic/WeakCanonical.lean` with a **"CI edge only"** comment, exactly as the
  `DenseModelSurgery/` chain is handled there (`WeakCanonical.lean:35–48`). Do **not** register
  it in `scripts/module-invariants-manifest.txt` — that file is for modules deliberately left
  outside the graph, and this one should be inside it.

Note that `RealModel/` reaches the closure indirectly, via
`BXCanonical/CompletenessDedekind.lean`; `GroupModel/` has no such consumer yet, hence the
explicit edge.

**C9 (no task-number citations under `FormalSystem/`)**: the module header must cite Reynolds
§8 p.185 and the two sibling modules as its ADAPTED-FROM anchors. It must not contain the
strings `task 477`, `task-477`, or similar. Citing the `specs/422_…` report path does not trip
C9's regex, but the durable anchors are better and are what `GoodDense.lean` itself uses.

## 4. Design decision 1 — full carrier, not an interval (RECOMMENDED, with a machine-checked
reason not to mirror `ZIntervalStructure` literally)

The task brief says to mirror `ZIntervalStructure`. Mirror its **API shape**, not its
**representation**. `ZIntervalStructure` encodes its carrier as `lo hi : Option ℤ`, which works
because every interval of ℤ is determined by two `Option` endpoints. **That is false at
`ℚ ×ₗ ℤ`**, and this was machine-checked this session rather than argued:

> `S = {x : ℚ ×ₗ ℤ | (ofLex x).1 < 0}` is `Set.OrdConnected`, has **no greatest element**
> (bump the ℤ-coordinate), and its complement has **no least element** (drop the
> ℤ-coordinate). So `S` is an interval expressible as neither `{x < c}` nor `{x ≤ c}` for any
> `c` in the carrier, and no `Option`-endpoint pair denotes it.

All three facts compiled with clean axioms; the probe is retained at
`specs/477_ta_qz_target_structure_plumbing/verification/qz_interval_not_endpoint_determined.lean`. A literal `Option`-bounds mirror would therefore be an **unsound model of "interval
of `ℚ ×ₗ ℤ`"** — it could not name intervals the construction can produce. The `RIntervalStructure`
answer to the same problem is `carrierSet : Set ℝ` + `Set.OrdConnected`.

**Recommendation: sidestep the question entirely — give `QZStructure` the full carrier.**

```lean
structure QZStructure (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] where
  interp (p : sig.preds) : ℚ ×ₗ ℤ → Prop
```

Four reasons, in order of weight:

1. **It is what the companion lemma says.** Report 02 §4 states the obligation as *"there is an
   `OrderedMonadicStructure sig` `N` with carrier `ℚ ×ₗ ℤ`"* — the whole group, unqualified.
   A full-carrier `QZStructure` makes `goodGroupable` a verbatim transcription of it.
2. **It is what T-C needs.** T-C builds `multiFamTaskFrameGen (ℚ ×ₗ ℤ)`, whose carrier must
   satisfy the four `valid`/`SemanticConsequence` binders (`AddCommGroup`, `LinearOrder`,
   `IsOrderedAddMonoid`, `Nontrivial`). **An interval of `ℚ ×ₗ ℤ` is not a group.** With the
   interval formulation, T-C would have to re-run the `Z.lo = none ∧ Z.hi = none` unboundedness
   argument that `ReynoldsBridge.lean:566–640` needed for the ℤ route. Full carrier deletes that
   step before it is written.
3. **Nothing needs the interval type.** Report 02 §4's proof strategy for T-B is region
   condensation + replacement + EF-composition over ordered sums — its intermediate objects are
   ordered sums of arbitrary `OrderedMonadicStructure`s (`OrderedSum.lean`, already landed), and
   segments of the target are expressible with the **existing generic**
   `OrderedMonadicStructure.subinterval` (`MonadicFO.lean:215`) and `.openSubinterval`
   (`GoodDense.lean:222`) applied to `Q.toOrdered sig`. No new interval type is required to say
   anything T-B wants to say.
4. **`toOrdered` stays computable.** `RIntervalStructure.toOrdered` is `noncomputable` (ℝ's
   `LinearOrder` is). The `ℚ ×ₗ ℤ` version is not — verified.

If T-B planning later discovers it genuinely wants an interval-typed target, add
`QZSegmentStructure` with `carrierSet : Set (ℚ ×ₗ ℤ)` + `ordConnected`, on the
`RIntervalStructure` pattern, **at that time**. Building it speculatively in T-A would be
unused surface area.

## 5. Design decision 2 — do NOT land a `veryGoodGroupable`

Both pattern sources pair their ∃-notion with a `VeryGood`/`veryGoodDense` companion. **The
analogue must not be landed here, because at this target it is unsatisfiable.**

`ℚ ×ₗ ℤ` is `NoMaxOrder` and `NoMinOrder` (both instances proved this session). By
`noMaxOrder_of_kEquiv` / `noMinOrder_of_kEquiv` (`GoodDense.lean:469`, `:485`, sorry-free,
hypothesis `2 ≤ k`), any `M` with `goodGroupable sig k M` at `k ≥ 2` inherits both. Hence for
`k ≥ 2` and any `a ≤ b`, the **closed** subinterval `M.subinterval sig a b` — which has both
endpoints — is **never** `goodGroupable`. A `VeryGood`-shaped definition quantifying over closed
subintervals would be identically false at every `M`, and any theorem proved from it would be
vacuous.

This forecloses a tempting mimicry of the ℤ development and is the single most useful thing this
report hands the planner. The two corollaries that establish it —
`noMaxOrder_of_goodGroupable` and `noMinOrder_of_goodGroupable` — **should** be landed (they are
in the probe, ~16 lines): they are the guardrail, they are consumed by T-B when it discharges
the companion lemma's unboundedness side conditions, and they cost one import.

Note the relevant `k` is not hypothetical: T-C instantiates at `k = operatorDepth φ + 2 ≥ 2`.

## 6. Verified technical facts

| Fact | How checked | Result |
|---|---|---|
| `lake build` baseline green | `lake build` | exit 0, 2487 jobs |
| Sole structural sorry | `grep` for bare `sorry` outside `Boneyard/` | exactly one, `Transfer.lean:1102`, inside `countermodel_discrete` (`:1069`) |
| `×ₗ` notation available | probe compile | yes, via the `GoodStructures.lean` import chain |
| `LinearOrder (ℚ ×ₗ ℤ)` by `inferInstance` | probe compile | yes |
| `IsOrderedAddMonoid (ℚ ×ₗ ℤ)` | probe compile, with and without the import | **requires** `import Mathlib.Algebra.Order.Monoid.Prod`; fails with a `synthInstanceFailed` without it. Confirms report 02's note. |
| `AddCommGroup` / `Nontrivial (ℚ ×ₗ ℤ)` | probe compile | resolve without the extra import |
| `QZStructure.toOrdered` computable | probe compile | yes — no `noncomputable` needed (contrast `RIntervalStructure.toOrdered`) |
| `(Q.toOrdered sig).carrier = ℚ ×ₗ ℤ` | `rfl` | definitional |
| `KEquiv` is `Eq`, so `.trans`/`.symm` apply | probe compile | yes — `KEquiv` is `@[reducible] def … := kTypeOf … = kTypeOf …` (`NEquivalence.lean:81`) |
| `k_equiv_of_iso` applies at this carrier | probe compile | yes (`GoodStructures.lean:97`) |
| Intervals of `ℚ ×ₗ ℤ` not endpoint-determined | 3-lemma probe, clean axioms | confirmed (see §4) |
| `NoMaxOrder` / `NoMinOrder (ℚ ×ₗ ℤ)` | probe compile | proved, ~5 lines each |
| C8 does not reach `WeakCanonical/` subdirs | read `check-module-invariants.sh:419–420` | confirmed — no aggregator to create |
| Frame side elaborates at the carrier | pre-existing `specs/422_…/verification/qlex_frame_probe.lean` | re-read; `multiFamTaskFrameGen` + `multiFamHistoryGen` compile, axioms clean |

**Import set for the new module** (exactly three):

```lean
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructures   -- k_equiv_of_iso, KEquiv, OrderedMonadicStructure
import FormalSystem.Metalogic.WeakCanonical.RealModel.GoodDense           -- noMaxOrder_of_kEquiv, noMinOrder_of_kEquiv
import Mathlib.Algebra.Order.Monoid.Prod                                  -- lex IsOrderedAddMonoid
```

The `GoodDense` edge is what buys §5's guardrail. If the planner prefers to drop it, §5's two
corollaries and the `NoMaxOrder`/`NoMinOrder` instances must be dropped with it — and then §5's
warning survives only as prose in the header, which is the weaker outcome. **Recommend keeping
it.**

The third import is not strictly needed by any *definition* in the module — it is needed only
by the `IsOrderedAddMonoid` carrier-gate line. Keep it and keep the gate: the entire point of
this carrier is that it **is** an admissible duration group, and four one-line
`example … := inferInstance` assertions turn that into a compile-time invariant that T-C
inherits for free.

## 7. Tactic survey results

The obligations here are definitional; only three carry proof content, and all three closed on
first attempt.

| Goal | Tactic | Result | Notes |
|---|---|---|---|
| `goodGroupable_of_kEquiv` | `obtain` + `h.trans hQ` | success | term-mode after destructuring; `KEquiv` is `Eq` |
| `goodGroupable_of_orderIso` | term mode via `k_equiv_of_iso` | success | one line, no tactics |
| `noMaxOrder_of_goodGroupable` | `obtain` + `haveI` + `noMaxOrder_of_kEquiv … hQ.symm` | success | note the `.symm`: `hQ : KEquiv k M (Q.toOrdered)`, and the lemma transports *from* the `NoMaxOrder` side |
| `NoMaxOrder (ℚ ×ₗ ℤ)` | `Prod.Lex.right _ (by simp)` | success | `by omega` **fails** — it cannot see through `ofLex (toLex …)`; `simp` discharges the reduction. Same for `NoMinOrder`. |
| `S.OrdConnected` (§4 probe) | `Prod.Lex.le_iff.mp` + `rcases` | success | the `Icc` membership needed is `hc.2` (upper bound), not `hc.1` |

The `omega`-vs-`simp` point is the one non-obvious tactic fact and cost two iterations; it is
recorded so the implementer does not repeat them.

## 8. Zero-debt compliance

No step of this task can require a `sorry`: the complete content has already been compiled
sorry-free. No new axiom is introduced — every declaration checks at
`[propext, Classical.choice, Quot.sound]`, which is the repository's clean baseline.
`countermodel_discrete` is not touched, and the sorry count does not change.

## 9. Acceptance criteria — how to verify

1. `lake build` → exit 0 (baseline 2487 jobs; expect a small increase for the new module).
2. `bash scripts/check-module-invariants.sh` → all of C1–C11 pass. C3 (sole structural sorry,
   asserted by content) and C2 (flagship axiom baselines) must be **unchanged**; C6 is the one
   that catches a missing build edge, and C9 the one that catches a task-number citation.
3. `#print axioms FormalSystem.Metalogic.WeakCanonical.QZStructure.toOrdered` and the same for
   `goodGroupable_of_kEquiv`, `goodGroupable_of_orderIso`, `noMaxOrder_of_goodGroupable`,
   `noMinOrder_of_goodGroupable` → `[propext, Classical.choice, Quot.sound]` for each.
4. `grep -rn 'sorry' FormalSystem/Metalogic/WeakCanonical/GroupModel/` → no bare `sorry`.

## 10. Suggested phase decomposition

One phase suffices; two is cleaner for commit hygiene.

- **Phase 1 — land the module.** Create `GroupModel/GoodGroupable.lean` from the probe, with the
  repo-standard header (ADAPTED-FROM section naming `GoodStructures.lean` and `GoodDense.lean`,
  the Reynolds §8 p.185 anchor, the §4 non-endpoint-determinacy note as the *reason* the
  `Option`-bounds shape was not mirrored, and the §5 warning against a `veryGoodGroupable`).
  Add the "CI edge only" import to `WeakCanonical.lean`. `lake build`.
- **Phase 2 — gate.** Run `check-module-invariants.sh` and the four `#print axioms` checks;
  record results.

Expected size: ~90 lines of code plus ~120–200 lines of header, i.e. **within the 150–300 line
estimate**.

## 11. Non-goals, restated

Not attempted and not to be attempted here: the companion lemma itself (T-B); any edit to
`countermodel_discrete` or its `sorry`; the O1 isomorphism; `succ_cofinal`; the S1
carrier-generic refactor of the dense cantor machinery. Report 01 of the `422_…` directory
records the first two as permanently refuted.
