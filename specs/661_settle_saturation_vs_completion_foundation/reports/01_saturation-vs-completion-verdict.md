# Research Report: Settle Saturation vs Completion, and judge the foundation criterion

- **Task**: 661 - Settle the Saturation vs Completion question by probe, and judge the outcome against a primitives-level foundation criterion
- **Started**: 2026-09-23T16:00:00Z
- **Completed**: 2026-09-23T16:35:00Z
- **Effort**: ~2.5 hours (two compiled probes, sorry-free)
- **Dependencies**: 657 (frame-constraint audit, R1/R4 origin), 660 (completed)
- **Sources/Inputs**:
  - Library: `FormalSystem/Semantics/Extension/Completion.lean`, `FormalSystem/Semantics/Extension/Step.lean`, `FormalSystem/Semantics/TaskFrame.lean`, `FormalSystem/Semantics/PartialHistory.lean`, `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`
  - Evidence probe: `specs/evidence/frame-constraints-audit/mixed-sign-composition-obstruction.lean`
  - Pinned manuscript text: `docs/reference/paper-definitions-of-record.md` (`def:frame`, `def:frame#Saturation`, `def:world-history`)
  - Prior audit: `specs/657_audit_frame_constraints_history_restriction/reports/01_audit-frame-constraints-restriction.md` (R1, R4, R7)
  - New probes written and compiled for this report (below)
- **Artifacts**:
  - `specs/661_settle_saturation_vs_completion_foundation/reports/01_saturation-vs-completion-verdict.md`
  - `specs/661_settle_saturation_vs_completion_foundation/probes/CompletionRationalTwoOrigins.lean`
  - `specs/661_settle_saturation_vs_completion_foundation/probes/SeparatingFrame.lean`
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Primary probe, answered: the rational two-origin relation FAILS *Completion*.** A coherent
  family of rational ray states at the times `-(1/2)^n`, accumulating at `z = 0`, has empty fibre
  intersection at `z`. So the rational carrier is **not** the separator; it fails *Saturation* and
  *Completion* alike. Machine-checked, sorry-free: `not_rel_coherentCompletion`.
- **But the converse is settled anyway, negatively — a separating frame exists and is verified.**
  `W = ℚ`, `D = ℤ`, `w ⇒_x v` iff `|v − w| ≤ |x|` satisfies *Seriality*, *Compositionality*,
  *Limit* and *Completion*, and **fails *Saturation***. Machine-checked, sorry-free:
  `srel_serial`, `srel_compositional`, `srel_limit`, `srel_coherentCompletion`,
  `not_srel_saturation`. **`Completion → Saturation` is false, unconditionally.**
- **Therefore *Completion* is a strict weakening of *Saturation*** — which removes R4's third and
  strongest recorded objection ("not known to be a strict weakening"). R4 is now defensible on the
  merits; the two objections that survive are the ball-space footnote and the churn cost.
- **Why the two conditions must come apart, in one sentence**: *Completion*'s quantifier is indexed
  by **times**, and collapses to a two-point condition whenever the temporal order has nearest
  times (`completion_of_hasNearest`); *Saturation*'s is indexed by **balls**, which are not indexed
  by times and never collapse. Discrete time with an incomplete carrier is exactly where the gap
  opens, and the witness above lives there.
- **Foundation criterion**: `CoherentCompletion` matches R4's drafted LaTeX clause for clause, with
  **one vocabulary mismatch** — the LaTeX states the conclusion as `⋂_{t∈X} Fib(w_t, z−t) ≠ ∅`
  while the Lean states it as a bare `∃ u, ∀ t, w_t ⇒_{z−t} u`. Restating the LaTeX Fib-free makes
  the clause mention nothing but `W`, `D` and `⇒`. `completion_iff_coherentCompletion` is a pure
  recognition lemma (two constructor applications, zero frame constraints), so the
  `PartialHistory`-shaped form carries no definitional dependency.
- **Verdict**: on the primitives criterion plus the now-settled strictness, **R4 with a Fib-free
  clause, and *Saturation* demoted to a named remark that keeps the ball-space anchor**. This is an
  editorial call with paper-wide churn, so it is raised as a non-blocking `user_decision`; R1
  remains a fully defensible fallback and costs nothing.

## Context & Scope

Task 657's audit established `Saturation → Completion` (via `lem:step`) and left the converse open,
recommending R1 (record *Completion* as a lemma, keep `def:frame` unchanged) over R4 (replace
*Saturation* by *Completion* in `def:frame`), explicitly because the replacement was "not known to
be a strict weakening". Task 661 asks for (i) a decisive probe at the rational two-origin frame,
(ii) a judgement on the primitives criterion, and (iii) the next candidate if the rational carrier
is not the separator. No manuscript edits are in scope.

Two new probes were written and compiled against the built library with
`lake env lean`, and re-run under the package's own linter set
(`-D weak.linter.mathlibStandardSet=true -D autoImplicit=false`) with **zero warnings**. Both are
sorry-free: `#print axioms` reports only `propext`, `Classical.choice`, `Quot.sound` for every
headline theorem.

Both probes transcribe `PartialHistory.CoherentCompletion` as a bare-relation predicate
(`CoherentCompletionRel`), because neither relation carries a `FrameOver` wrapper — the same
packaging caveat `ConstraintWitnesses.lean` already records for the *Saturation* row of the
independence matrix.

## Findings

### 1. Primary probe: *Completion* fails at the rational two-origin frame

`specs/661_settle_saturation_vs_completion_foundation/probes/CompletionRationalTwoOrigins.lean`,
theorem `not_rel_coherentCompletion`.

- **The witness.** Times `tm n = −(1/2)^n`, accumulating at `z = 0` from below. States
  `p (phi n)` on the ray, at positions `phi n = nt n − (1/2)^n`, where `nt` is the Newton iteration
  for `√2` started at `3/2` (`nt (n+1) = (nt n² + 2)/(2 · nt n)`).
- **Coherence** is exactly "position nondecreasing and 1-Lipschitz in time", which holds because
  the iteration's step is bounded by the time gap: `nt_step : nt n − nt (n+1) ≤ (1/2)^(n+1)`,
  itself from the invariant `nt_err : nt n² − 2 ≤ (1/2)^(n+2)`.
- **The pinch.** At `z = 0` an origin is excluded outright (it would need `phi 0 ≤ −1`), and any
  ray witness `p v` needs `nt n − (1/2)^n ≤ v ≤ nt n` for **every** `n`. The lower bounds rise to
  the cut and the upper bounds fall to it, forcing `v² = 2` — refuted by
  `RationalTwoOrigins.sq_ne_two`.
- **Consequence.** The rational carrier is not a separator: it now fails *both* constraints. The
  general shape of the obstruction is worth recording, because it rules out a whole family of
  candidates: over a **dense** temporal order, any coherent family whose times accumulate at `z`
  forces the witness position to the *single* real number `lim φ(t)`, since `φ` nondecreasing and
  `φ − id` nonincreasing pinch the admissible interval shut. **No dense-time frame with a
  continuous-drift relation can separate the two conditions**, and searching for one is wasted
  effort.

### 2. The separating frame: `Completion → Saturation` is FALSE

`specs/661_settle_saturation_vs_completion_foundation/probes/SeparatingFrame.lean`.

`W = ℚ`, `D = ℤ`, `srel w x v := |v − w| ≤ |x|` — unit-speed drift on a rationally incomplete
carrier over **discrete** time.

| Property | Theorem | Result |
|---|---|---|
| *Seriality* | `srel_serial` | holds |
| *Compositionality* (biconditional) | `srel_compositional` | holds |
| *Limit* | `srel_limit` | holds (`|y| < 1` over `ℤ` forces `y = 0`) |
| *Completion* (`CoherentCompletionRel`) | `srel_coherentCompletion` | **holds** |
| *Saturation* | `not_srel_saturation` | **fails** |
| mixed-sign composition (`TotalComp`) | `not_srel_totalComp` | fails, as required |

- ***Completion* holds** by the nearest-times argument, run at the bare relation using the
  library's own `PartialHistory.hasNearest_int`. The constraint imposed by the nearest domain time
  on each side of `z` is the `⊆`-least one; the two survivors overlap because
  `|w_tp − w_tm| ≤ tp − tm`, and `max (w_tm − r₁) (w_tp − r₂)` is an explicit witness. This is
  `completion_of_hasNearest`'s argument, and needs no completeness of the carrier at all.
- ***Saturation* fails** because fibres and segments are **not indexed by times**. Every rational
  interval `[a, b]` with `b − a ≤ 2` is a segment of this relation — `[a, b] = [b−1, a+1]_1^1`
  (`mem_sseg`) — so the `⊇`-directed family `{[a,b] : 1 ≤ a, a² < 2 < b², 1 ≤ b ≤ 2}` consists of
  nonempty segments, is directed (take `max a`, `min b`), and has empty intersection by the same
  Newton-step argument `not_rel_saturation` uses.
- **Consistency check passes.** `saturation_of_completion` (evidence probe) proves
  `Completion → Saturation` under `TotalComp` + *Limit*; a separating frame must therefore fail
  `TotalComp`, and `not_srel_totalComp` confirms this one does (`0 ⇒₁ 1` and `1 ⇒₋₁ 2` but not
  `0 ⇒₀ 2`).
- **Where the gap lives.** The separation is realised over ℤ-time — precisely the region where
  `extension_of_isZTime` already shows *Saturation* is redundant for `thm:extension`. So the
  strictness is not exotic: *Saturation* excludes ordinary discrete-time frames with a dense state
  space (a "ℚ-valued register drifting at unit speed over integer time"), and `thm:extension`
  has no need of that exclusion.

### 3. The primitives criterion, applied

The pinned `def:frame` (`docs/reference/paper-definitions-of-record.md`) states *Saturation* as:

> `\item[\it Saturation:] $\bigcap \mathcal{S} \neq \emptyset$ for any $\supseteq$-directed family
> $\mathcal{S}$ of nonempty fibers and segments.`

and needs its own **opening clause** to define `⊇`-directed first.

| Axis | *Saturation* (R1) | `CoherentCompletion` (R4) |
|---|---|---|
| Objects quantified over | families `𝒮` of **subsets of `W`** (second order over the powerset) | a subset `X ⊆ D` and a family `{w_t} ⊆ W` indexed by it |
| Auxiliary apparatus in `def:frame` | the `⊇`-directed clause, which exists only to state this axiom | none |
| Derived classes needed | the fiber/segment **classification** (`def:task-relation`) to pick out eligible members | none (see the Fib note below) |
| Reference to `⇒` in the side condition | none — directedness is bare `⊆` | the coherence clause *is* `w_s ⇒_{t−s} w_t` |
| Mentions histories | no | no |

- **On the criterion as literally stated** ("conditions on partial histories, world histories or
  their extension order belong in lemmas … never as frame constraints"), *both* candidates pass:
  *Saturation* mentions no history either. The criterion discriminates the two **Lean forms** —
  `Completion` (PartialHistory-shaped) vs `CoherentCompletion` (bare) — and rules R4's drafted
  clause admissible. What discriminates R1 from R4 is the row-by-row apparatus comparison above,
  not the history clause.
- **R4's LaTeX vs `CoherentCompletion`, clause for clause** — they match, with one vocabulary
  mismatch:

  | R4 clause | Lean | Match |
  |---|---|---|
  | "any nonempty `X ⊆ D`" | `(X : F.Duration → Prop)` + `(∃ t, X t)` | exact |
  | "any family `{w_t}_{t∈X} ⊆ W`" | `w : (t : F.Duration) → X t → F.WorldState` | exact |
  | "with `w_s ⇒_{t−s} w_t` for all `s, t ∈ X`" | the coherence hypothesis, unguarded in sign | exact |
  | "any `z ∈ D`" | `∀ z : F.Duration` | exact |
  | "`⋂_{t∈X} Fib(w_t, z−t) ≠ ∅`" | `∃ u, ∀ t ht, F.TaskRel (w t ht) (z − t) u` | equivalent, **different vocabulary** |

  The last row is the one actionable finding: the Lean conclusion is `Fib`-free, the LaTeX is not.
  Since `Fib` is pure abbreviation here (`mem_Fib` is `Iff.rfl`), restating the clause as
  "*there is a `u ∈ W` with `w_t ⇒_{z−t} u` for every `t ∈ X`*" costs nothing and makes the fourth
  constraint mention **only** `W`, `D` and `⇒`. Recommended if R4 is taken. (Note `def:frame`'s
  *Limit* clause likewise uses the derived cone notation `(w)_x`; the tree already treats that as
  abbreviation and unfolds it in `TaskFrame.Limit`, so the precedent for Fib-as-abbreviation
  exists — but the unfolded form is strictly better on the criterion.)
- **`completion_iff_coherentCompletion` is a recognition lemma, not a dependency.** Its proof is
  two constructor applications in each direction and consumes **no** frame constraint. The reason
  is structural: `PartialHistory`'s four fields (`domain`, `nonempty_domain`, `states`,
  `respects_task`) are literally `CoherentCompletion`'s four arguments, and `def:world-history`'s
  verbatim text ("a function `τ : X → W` on a nonempty set `X ⊆ D` where `τ(x) ⇒_{y−x} τ(y)` for
  all times `x, y ∈ X`") is literally R4's family clause. So R4's constraint is *extensionally* a
  condition about partial histories stated without naming them — which is exactly what the
  criterion asks for, since `def:frame` precedes `def:world-history` and the bare form creates no
  forward reference.

### 4. Is the infinitary quantifier essential to *Completion*?

**Yes — and the two machine-checked endpoints are already in hand.**

- The **finitary** form of *Completion* (every coherent family on a *finite* index set completes)
  is a consequence of *Compositionality* + *Seriality*: a finite domain has a nearest time on each
  side of `z`, and `completion_of_hasNearest`'s argument then applies verbatim. Its two-point case
  *is* `TaskFrame.Interpolates` (for `s ≤ z ≤ t`) together with *Seriality* plus forward
  composition (for `z` outside `[s, t]`).
- The rational two-origin relation satisfies *Compositionality* (`rel_compositional`, library) and
  **fails** *Completion* (`not_rel_coherentCompletion`, this task). Hence **no condition implied by
  *Compositionality* can be equivalent to *Completion***, and in particular no finitary or
  two-point form can be. The infinitary quantifier carries all of the completeness content.
- **Status of the middle step.** "A finite domain has nearest times, hence finite *Completion*
  follows from *Compositionality* + *Seriality*" is ARGUED, not CHECKED. It is a pure
  hypothesis-weakening of an existing proof: `completion_of_hasNearest` uses its `hN` hypothesis at
  exactly one place (`obtain ⟨hlow, hhigh⟩ := hN τ.domain z`), so a `completion_of_nearest_at`
  variant taking only that instance, plus a `Set.Finite → nearest` lemma, discharges it. Sized for
  one short plan phase; see Recommendations.

### 5. What R4 would cost the Lean tree

`Extension/Step.lean`'s docstring already records the measurement this depends on: `step` is the
**sole** site where *Saturation* is eliminated into a non-*Saturation* conclusion. The other five
applications take *Saturation* in and give it back out. If `def:frame`'s fourth constraint became
*Completion*, the mechanical cost is therefore bounded and enumerable:

- `FrameOver.IsRegular`'s `saturation` field becomes a `completion` field (and `step` becomes an
  immediate consequence of `lem:admissible`).
- Five transport sites need *Completion* analogues: `FrameOver.rev_isRegular`
  (`OpenLanguage/OpenReversal.lean` — transports through the reflection law, so it costs *Limit*),
  `FrameOver.map` (`Semantics/IntTransfer.lean`), `FrameOver.translationProduct`
  (`Semantics/Frames/TranslationProduct.lean`), `regionFrame_saturation`
  (`Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`), `zTaskFrameV2_saturation`
  (`Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`). The last two already prove
  *Saturation* outright and can keep those proofs, composing with `completion_of_isRegular`.
- **Soundness and completeness are safe.** Soundness does not read `F.saturation` (it appears
  nowhere in `Metalogic/Soundness.lean`); it consumes *Saturation* only transitively through
  `step → thm:extension → cor:occurrence`, and `extension_of_completion` reproves that chain.
  Completeness is unaffected because the canonical frame satisfies *Saturation*, which implies
  *Completion*, so it stays in the (now larger) class. Non-validity results are preserved under
  class enlargement, so the independence witnesses and `cor:no-characterization` survive.

## Decisions

- **The probe was run at the bare-relation level**, transcribing `CoherentCompletion` as
  `CoherentCompletionRel`, rather than building `FrameOver` wrappers. Wrapping either relation
  would require a reflection law the witnesses do not carry, and the constraints are stated over
  bare relations anyway. This matches the packaging asymmetry `ConstraintWitnesses.lean` already
  records — and it is recorded here for the same reason: neither probe should be read as claiming
  a `FrameOver` witness it does not have.
- **`3/2` rather than `2` as the Newton seed** in the failing family. With seed `2` the first
  Newton step exactly equals the first time gap, leaving no slack in the monotonicity of `phi`;
  seeding at `3/2` gives the invariant `nt n² − 2 ≤ (1/2)^(n+2)` with room to spare and makes the
  induction routine.
- **`1 ≤ b` was added to the separating frame's straddle family.** Without it `2 < b²` admits
  `b ≤ −2`, and the member is empty rather than a nonempty segment. Recorded because the analogous
  family in `not_rel_saturation` is protected by its subtype `{t : ℚ // 0 < t}` instead, so the
  guard is easy to lose when porting the argument to a bare-ℚ carrier.
- **The verdict is stated as a recommendation with a non-blocking `user_decision`**, not as a
  research fiat. Research settles the mathematics (R4 is a genuine weakening, and it is the
  primitives-level form); which of minimality and the ball-space literature anchor the manuscript
  should prefer is a preference the artifacts cannot infer.

## Recommendations

1. **Record the separating frame in the library** (highest value). `SeparatingFrame`'s six results
   settle a question `Extension/Completion.lean`'s module docstring currently records as open
   ("Whether the replacement would be a *strict* weakening is the converse `Completion →
   Saturation`, which is left open"). Proposed siting:
   `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`, beside `RationalTwoOrigins`,
   as a `SeparatingFrame` namespace. Requires updating that docstring paragraph and
   `Extension/Completion.lean`'s "This module does not propose changing `def:frame`" section, both
   of which assert the converse is open.
2. **Record the rational-carrier *Completion* failure** (`not_rel_coherentCompletion`) in the same
   module, immediately after `not_rel_saturation`. It is the statement that stops the next reader
   re-running this probe, and its docstring should carry the dense-time pinching argument from
   Finding 1 as the reason no dense-carrier frame can separate the two.
3. **Discharge the finitary claim** (Finding 4's ARGUED step): add
   `PartialHistory.completion_of_nearest_at` (hypothesis-weakened `completion_of_hasNearest`) and
   `completion_of_finite_domain`. One short phase; no new mathematics.
4. **If R4 is taken**, restate the clause `Fib`-free (Finding 3) and attach the ball-space footnote
   to a *Saturation* remark rather than to `def:frame`'s fourth item, so the literature anchor is
   preserved rather than dropped. The manuscript sites R4 already enumerates are unchanged, plus
   one new one: the remark should cite the separating frame as the reason *Saturation* is strictly
   stronger, which is now assertable where it was not in 657.
5. **If R1 is kept**, R1's proposed `lem:completion` should be stated in the **bare** form (R4's
   clause), not the partial-history form, and followed by the remark that *Saturation* is strictly
   stronger than it, with the witness. R1 and R4 then differ only in which of the two the
   `\item` in `def:frame` names — which is the honest shape of the remaining choice.
6. **Do not search for a dense-time separator.** Finding 1's pinching argument shows the whole
   family is dead; the separation is a discreteness phenomenon.

## Risks & Mitigations

- **Risk**: the separating frame is a bare relation with no `FrameOver` wrapper, so a reader could
  over-read it as a `def:frame`-level witness. **Mitigation**: the probe's docstring says so; if
  promoted, it lands in the module that already carries the packaging-asymmetry note, and the same
  caveat should be repeated in its docstring.
- **Risk**: `srel`'s *Completion* proof reuses `PartialHistory.hasNearest_int`, so the probe
  imports `Extension/Completion.lean`. If it is promoted into `ConstraintWitnesses.lean` (a leaf
  that currently imports only `Semantics/StateTopology`), that adds an import edge. **Mitigation**:
  either inline `Int.exists_greatest_of_bdd`/`exists_least_of_bdd` (a dozen lines, no new import),
  or site the witness in `Extension/Completion.lean` itself, where the import already exists and
  where the open-converse docstring that must change also lives. The planner should pick; the
  second is cleaner because the docstring correction and the witness then land together.
- **Risk**: promoting either witness touches docstrings holding pinned paper quotations.
  **Mitigation**: the corrections named in Recommendations 1 and 2 are to *prose about the Lean
  proof* (the "left open" sentences), not to any `verbatim:` block or `sha256:` line; run
  `bash scripts/check-paper-definitions.sh` in the same phase to confirm no anchor moved.
- **Risk**: R4 changes `def:frame`, which is a pinned anchor with a recorded checksum; adopting it
  makes every `def:frame`-citing docstring stale at once. **Mitigation**: this is precisely why the
  decision is raised to the user rather than taken here, and why R1 remains a zero-cost fallback
  that captures most of the value (the sharpening is recorded either way).

## Context Extension Recommendations

- **Topic**: Which frame constraints are *time-indexed* and which are *ball-indexed*, and why that
  distinction predicts where conditions separate.
- **Gap**: `.claude/context/project/logic/domain/` has no note on the frame-constraint landscape;
  the reasoning in Finding 2 ("time-indexed quantifiers collapse over orders with nearest times,
  ball-indexed ones do not") is the load-bearing intuition behind three separate results
  (`completion_of_hasNearest`, `extension_of_isZTime`, and this task's separation) and is currently
  recorded only inside Lean docstrings.
- **Recommendation**: add `.claude/context/project/logic/domain/frame-constraint-landscape.md`
  recording the distinction, the four constraints' independence matrix, and the two separations
  (Saturation/Completion, dense/discrete).

## Appendix

### Probes written for this task

| File | Headline results | Axioms |
|---|---|---|
| `specs/661_settle_saturation_vs_completion_foundation/probes/CompletionRationalTwoOrigins.lean` | `not_rel_coherentCompletion` | `propext`, `Classical.choice`, `Quot.sound` |
| `specs/661_settle_saturation_vs_completion_foundation/probes/SeparatingFrame.lean` | `srel_serial`, `srel_compositional`, `srel_limit`, `srel_coherentCompletion`, `not_srel_saturation`, `not_srel_totalComp` | same, each |

Reproduce with:

```
lake env lean specs/661_settle_saturation_vs_completion_foundation/probes/CompletionRationalTwoOrigins.lean
lake env lean specs/661_settle_saturation_vs_completion_foundation/probes/SeparatingFrame.lean
```

Both also compile warning-free under the package's linter set
(`-D weak.linter.mathlibStandardSet=true -D autoImplicit=false`), which `lake env lean` does not
apply by default — the hazard recorded in task 659's summary.

### Library declarations relied on

- `FormalSystem.Semantics.PartialHistory.Completion`, `.CoherentCompletion`,
  `.completion_iff_coherentCompletion`, `.HasNearest`, `.hasNearest_int`,
  `.completion_of_hasNearest`, `.extension_of_completion`, `.extension_of_isZTime`,
  `.completion_of_isRegular`
- `FormalSystem.Semantics.TaskFrame.Saturation`, `.Serial`, `.Compositional`, `.Interpolates`,
  `.Limit`, `.DirectedFamily`, `.IsFiber`, `.IsSegment`, `.Fib`, `.Seg`
- `FormalSystem.Semantics.StateTopology.RationalTwoOrigins.rel`, `.rel_serial`,
  `.rel_compositional`, `.rel_limit`, `.not_rel_saturation`, `.sq_ne_two`
- `FormalSystem.Semantics.PartialHistory.saturation_of_completion`,
  `FormalSystem.Metalogic.Independence.not_totalComp_F0` (evidence probe, outside the build graph)

### References

- `specs/657_audit_frame_constraints_history_restriction/reports/01_audit-frame-constraints-restriction.md` — R1 (§Recommendations), R4 (§Recommendations), R7 rank 1 and rank 6
- `docs/reference/paper-definitions-of-record.md` — `def:frame` (whole block, sha256 pinned),
  `def:frame#Saturation`, `def:world-history`
- `FormalSystem/Semantics/Extension/Step.lean` — the "sole elimination site" measurement and its
  enumeration of the five transport sites
