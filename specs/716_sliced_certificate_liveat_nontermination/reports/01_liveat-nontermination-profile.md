# Research Report: Task #716

**Task**: 716 - Profile and fix the PlusSlicedCertificate liveT/liveAt non-termination that blocks Tier-2 sliced certificate witnesses.
**Started**: 2026-10-13T02:42:00Z
**Completed**: 2026-10-13T04:05:00Z
**Effort**: ~1.5 h research; 15 compiled probes, every figure below measured in this session
**Dependencies**: None
**Sources/Inputs**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixpoint.lean` (`Nu`, `EUFix`, `Fair`)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` (`untlLive`, `snceLive`, `fwdLiveStep`, `bwdLiveStep`, `fwdLiveT`, `bwdLiveT`, `liveT`)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Stable.lean` (`liveAt`, `L₀`, `R₀`)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Position.lean` (`Lab`, `Pos`, `posAt`, `succP`, `predP`, `card_Pos`)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean` (`TPos`, `verts`, `succT`, `predT`, `nextTime`, `prevTime`)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` and `Embed.lean` (the landed self-loop witness)
- `specs/archive/704_certificate_non_vacuity_and_shape_gates/probes/03_tier2_sliced_certificates.lean` (the preserved reproducer; it lives under `specs/archive/`, not the path the task description names)
- `scripts/certificate-witness-inventory.txt` (the C36 inventory and its sliced-class row)
- Probes written in this session: `specs/716_sliced_certificate_liveat_nontermination/probes/01`-`15`
**Artifacts**:
- `specs/716_sliced_certificate_liveat_nontermination/reports/01_liveat-nontermination-profile.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- `liveT` / `liveAt` neither diverge nor cost anything intrinsic to the total-edge case. The
  cause is **missing memoization**, the second of the three possibilities the task poses: the same
  leaf data is recomputed on the order of 10^4 times.
- The reproducer's failure is in large part a **measurement artifact of `#eval`**. Under kernel
  `decide`, which caches closed subterms during `whnf`, `certA.Certifies` is **provable today in
  91 s wall clock**, with no change to the library and only `maxHeartbeats` raised. The same
  statement does not finish under `#eval` in 560 s.
- Concretely proved at `certA` in this session: `certA.Certifies`,
  `certA.targetPos certA.targetTime ∈ certA.liveAt certA.targetTime`, and
  `(certA.liveAt 0).card = 4`. The decide harness was validated by two deliberately false
  controls, both correctly refuted.
- The defect in shipped code is nonetheless real and worth fixing: three compounding
  recomputation faults make the landed procedure roughly 10^4 times slower than its own proved
  bound allows. Even the pinned self-loop witness takes **20.7 s** for one `liveAt` under `#eval`,
  against the task description's "instantaneous".
- A hoisted mirror of the backward stack, hand-written with no library change, computes the full
  `bwdLiveT` fixpoint at `certA` in **7.17 s**, against an unfinished multi-hour run for the
  landed code. That is a measured confirmation of cause.
- Consequence for the deliverable: the Tier-2 inventory rows are reachable **now**, and the
  memoization fix is a performance and build-cost improvement rather than a precondition.

## Context & Scope

Evaluated: why `PlusSlicedCertificate.liveAt` fails to return at a width-2 total-edge Tier-2
certificate (`certA`, `certB` from the preserved reproducer), given that the decision procedure
is landed and gated. In scope: the computational behaviour of `liveT`, `liveAt`, and everything
they call, plus whether a `decide` proof is reachable. Out of scope: the soundness and
completeness theorems above them, the refuted sliced finite-model property, and the TailStable
junk-position work.

Method: fifteen compiled probes under
`specs/716_sliced_certificate_liveat_nontermination/probes/`, each timing one stage by wall
clock, plus `decide` runs under `lake env lean`.

One measurement hazard is recorded here because it invalidated the first five probe rounds. A
timing harness that binds the measured value to a pure `let` and reads the clock afterwards
measures nothing: Lean floats the pure computation past the second clock read, so every stage
reports 0 ms while the run never finishes. The corrected harness emits the value through an `IO`
write before reading the clock. Probes 01-09 carry the broken harness and their `[0 ms]` figures
must not be cited; probes 10-15 carry the corrected one.

## Findings

### Codebase Patterns

**The leaf: the position space is enumerated on every call.**
`posAt t` is `Finset.univ.filter ...` over `Pos = Fin n x Lab`, and `card_Pos` records
`Fintype.card Pos = n * 2 ^ |plusClosureOf (Γ ++ Del)|` - 128 at `certA`, 8 at the landed
embedded witness. `posAt` is never cached and sits at the innermost level of a four-deep nest.

**`verts` recomputes `posAt` once per candidate.** It is
`(Finset.univ ×ˢ winTimes).filter (fun v => v.1 ∈ posAt v.2)`, so `posAt` runs for each of
`n * 2^|closure| * |winTimes|` candidates (512 at `certA`).

**`succT` / `predT` recompute `verts` on every call**, and recompute `succP` / `predP` - hence
`posAt` again - once per element of `verts`, because the call sits inside the filter lambda.

**`fwdLiveStep` / `bwdLiveStep` recompute the inner fixpoint per vertex.** `untlLiveAt X v ψ`
calls `untlLive X g e`, whose value depends only on `(X, g, e)` and not on `v`, yet it is
evaluated inside a filter over every `v ∈ X` and every closure member `ψ`. The
`decide (… ∈ v.1.2.1 → v ∈ untlLive X g e)` form does short-circuit on the label test, so only
eventuality-carrying vertices pay - 8 of 16 at `certA`.

**Both fixpoints run a fixed iteration count with no early exit.** `Nu.gfp V F` is
`iter V F (V.card + 1)` and `EUFix.lfp` likewise. Each module proves stabilization within
`V.card` steps (`Nu.exists_stab`, `EUFix.exists_stab`) but the computation never consults it. At
`certA` the backward contraction is already fixed at its first application, so 16 of 17
contractions are waste - measured as a 16.7x factor.

**`liveAt` recomputes `liveT` once per position.** `liveAt s` is
`(posAt s).filter (fun p => (p, s) ∈ liveT)`, evaluating both fixpoints inside the lambda. The
embedded-witness numbers confirm the factor exactly: `fwdLiveT` 7.64 s plus `bwdLiveT` 1.61 s is
9.25 s for one `liveT`, and `liveAt (-1)` with `|posAt (-1)| = 2` takes 20.7 s.

**Nothing pathological was found below this level.** Probe 07 prints the instance terms for
`DecidableEq certA.TPos` and `Decidable (w ∈ certA.verts)`: both are the ordinary
`Finset.decidableMem` / `instDecidableEqProd` / `Subtype.instDecidableEq` chain. The cost is
structural recomputation, not a bad instance.

### Measured timings, interpreter (`#eval`)

`certA`: `n = 2`, `|closure| = 6`, `Fintype.card Pos = 128`, `|verts| = 16`, `|winTimes| = 4`,
`|posAt t| = 4`.

| Stage | Landed library | Hoisted mirror (probe 11) |
|---|---|---|
| `posAt t` | 3 ms | table lookup |
| `verts` | 1101 ms | 3 ms |
| 16 x `predT` | 19119 ms | 3 ms |
| one `EUFix.step` | 18827 ms | not measured separately |
| one inner `snceLive` | not reached in 600 s | 52 ms |
| one `bwdLiveStep` | not reached | 430 ms |
| full `bwdLiveT` | not reached | 7170 ms |

Landed library at the pinned self-loop embedded witness: `n = 1`, `|closure| = 3`,
`Fintype.card Pos = 8`, `|verts| = 12`, `|winTimes| = 6`, `|posAt (-1)| = 2`.

| Stage | Time |
|---|---|
| `verts` | 9 ms |
| `fwdLiveT` | 7636 ms |
| `bwdLiveT` | 1614 ms |
| `liveAt (-1)` | 20668 ms |

The cost model fitting both columns is the product of the nesting factors,
`|posAt| * (|V|+1) * |V| * |closure| * (|V|+1) * |V| * |V| * n * 2^|closure|`, whose ratio
between `certA` and the embedded witness is about 260. Against the measured 20.7 s that predicts
roughly 1.5 h for `liveAt 0` at `certA` under `#eval`, consistent with the reproducer's "no
output in 560 s".

### Measured `decide` reachability, elaborator and kernel

Each row is one file under `lake env lean` with `maxRecDepth 1000000` and `maxHeartbeats 0`; the
wall clock includes roughly 20 s of Mathlib import and certificate elaboration. Under the default
200000-heartbeat cap every fixpoint-layer goal fails after about 15 s in `whnf` or `isDefEq`, so
raising the cap is required and sufficient.

| Goal | Verdict | Wall clock |
|---|---|---|
| `(certA.posAt 0).card = 4` and `certA.verts.card = 16` | proved | 22 s (both, one file) |
| `certA.verts.card = 17` | correctly refuted (control) | 41 s |
| `certA.fwdLiveT.card ≤ 16` | proved | 50 s |
| `(certA.liveAt 0).card = 2` | correctly refuted (control) | 60 s |
| `certA.bwdLiveT.card ≤ 16` | proved | 63 s |
| `(certA.liveAt 0).card ≤ 4` | proved | 68 s |
| `(certA.liveAt 0).card = 4` | proved | 90 s |
| `certA.targetPos certA.targetTime ∈ certA.liveAt certA.targetTime` | proved | 90 s |
| `certA.Certifies` | proved | 91 s |

The direction of this result is the opposite of the usual expectation that `#eval` beats kernel
reduction. It holds here because the dominant cost is repeated evaluation of **closed**
subterms - `certA.verts`, `certA.posAt t` - which the elaborator's and kernel's `whnf` caches
collapse and which the interpreter re-runs every time. The reproducer measured the one path that
cannot share.

`certB` carries a larger closure - its target adds an implication, a negation and the inner
conditional, so `2^|closure|` grows by roughly an order of magnitude - and its `Certifies` run had
not returned after 13 minutes when this report was written. That is the one figure left open here,
and it bears only on whether the second inventory row needs the memoization fix first; it is
reproducible from probe `15_kernel_certB.lean`.

### External Resources

No Mathlib lemma search was required: the blowup is in project-local definitions and the fix is a
restructuring of project-local code, not a missing upstream result. The Mathlib-side facts in
play (`Finset.filter`, `Finset.univ` over a powerset subtype, `Fintype.card_coe`) are already
cited in the source at `card_Pos`.

## Decisions

- Classified as **missing memoization**. Not an algorithmic defect: every layer terminates and
  the proved bounds are polynomial. Not intrinsic cost: a hoisted mirror of the same algorithm is
  measurably 10^3 times faster on identical input.
- The task description's two factual premises are recorded as **corrected**. The fixpoint is not
  instantaneous at the self-loop witnesses (20.7 s measured), and `liveAt` at `certA` is not
  unreachable (91 s for the full `Certifies` under `decide`). The Tier-2 case differs from the
  pinned witness by the `n * 2^|closure|` factor, not in kind.
- The gating question is resolved in favour of landing: `certA` is admissible as a Tier-2
  inventory witness now, so the memoization work is **not** a precondition for the C36 rows.
- No `sorry` and no new axiom is needed or proposed anywhere in this plan. All three performance
  fixes are equality-preserving refactors, each admitting an `_eq` lemma against the existing
  definition, so the landed soundness and completeness theorems continue to apply unchanged.
- The `exists_stab` theorems already supply the termination argument an early-exit iteration
  needs, so the early-exit form requires a congruence induction and no new termination proof.
- The width-2 total-edge constructions are kept as written. Nothing measured implicates them.

## Recommendations

1. **Land the Tier-2 witness first, since it no longer waits on anything.** Add `certA` and the
   named theorem `certA.Certifies := by decide` to the library beside
   `liveFamily_sliced_certifies` in `PlusSlicedCertificate/Examples.lean`, with the heartbeat cap
   raised at the declaration, and add the matching `witness` row to
   `scripts/certificate-witness-inventory.txt`. The inventory needs a named closed-term theorem,
   not an `example`, and the C36b interest expression for a sliced row already exists
   (`c36Sliced`), so no new checker machinery is required.
2. **Budget the build cost explicitly.** A 91 s `decide` is a real addition to build time, and it
   is the reason the performance work still matters after the row lands. Decide deliberately
   whether the row goes in a module the default build elaborates.
3. **Settle `certB` before claiming a second row.** Either let the pending run finish, or apply
   recommendation 4 first and re-measure; the larger closure is exactly the regime where the
   recomputation factor bites hardest.
4. **Cache the leaf data - the 370x to 6400x win.** Introduce a derived cache as a plain
   definition over the certificate: the window times extended one step each way, `posAt`
   tabulated over them, and `verts`. Give it an unconditional `posAtC_eq : G.posAtC t = G.posAt t`
   by falling back to `posAt` off-range, so no side condition is needed, then re-express `succT`,
   `predT` and the two contractions as functions of the cache. Add **no field** to
   `PlusSlicedCertificate`: a new field would change every certificate author's obligations and
   reopen the demanded-field question that `not_exists_plusCertifies_pumpTarget` settled. Probe 11
   is a working hand-rolled instance of exactly this change.
5. **Hoist the vertex-independent inner fixpoint - up to a factor of |X|, so up to 16x at
   `certA`.** Compute `untlLive X g e` / `snceLive X g e` once per `X` for the eventuality-shaped
   closure members, then filter against the precomputed values. The equality proof is a
   `Finset.filter_congr` on a pointwise-equal predicate.
6. **Add an early-exit iteration to `Fixpoint.lean` - 16.7x measured at `certA`.** Add primed
   `iterTo` / `gfp'` / `lfp'` that stop when `F X = X`, and prove `gfp' = gfp` and `lfp' = lfp` by
   induction from `iter_stab`. This needs `DecidableEq α` at the `Nu` level, which that module's
   header deliberately avoids; take it as an instance argument on the new definitions only and
   leave `iter` / `gfp` untouched, so the header's claim stays true of the existing development.
7. **Change only the `decide`-facing entry points.** The surface that must route through the
   cache is the gated predicates - `Certifies`, `TailStable`, `StabFaithful`, `BoxLiveFaithful`,
   `Target`, `L₀`, `R₀` - not the whole module graph.
8. **Treat the embedded witness's 20.7 s as a regression target.** The same fix should bring its
   `liveAt` under a second; asserting that as a guard stops the blowup returning unnoticed.

## Risks & Mitigations

- **Blast radius.** `succT`, `predT`, `fwdLiveStep` and `bwdLiveStep` are cited across
  `Bridge.lean`, `Stable.lean`, `Sound.lean`, `Complete.lean`, `EmbedComplete.lean`, `Tail.lean`
  and `Check.lean`. Mitigation: additive primed definitions plus `_eq` lemmas, originals left in
  place, only the `decide`-facing entry points switched over.
- **Interpreter gains need not transfer to the kernel.** The hoisting figures are `#eval`
  measurements; the gated proofs run `decide`, where whnf caching already recovers part of the
  same win. Mitigation: re-measure `decide` on the cached form before claiming any build-time
  improvement, and do not justify the refactor on the `#eval` numbers alone.
- **A cache disagreeing with its definition would be unsound.** Mitigation: the `_eq` lemmas are
  unconditional, so no use site can observe a difference and nothing is accepted on the cache's
  authority.
- **A raised heartbeat cap hides future regressions.** `maxHeartbeats 0` on a 91 s declaration
  means a later slowdown shows up only as build time. Mitigation: prefer an explicit large finite
  cap over `0`, so a regression fails rather than crawls.
- **Concurrency.** Every file involved lies outside the declared `file_scope` of all concurrent
  siblings (Presheaf `Duration`, `Reflection`, `Worlds`, and `RaySummary/LadderModel`), so no
  territory collision is anticipated for the implementation phase.

## Tactic Survey Results

The survey here was of `decide` reachability rather than of a tactic portfolio against an open
goal: the task's question is computational, and no goal in it is closed by a search tactic. The
full table of `decide` verdicts and their wall clocks is in Findings under "Measured `decide`
reachability"; `simp`, `omega`, `aesop` and the rest were not applicable, since every statement
probed is a decidable closed proposition whose only plausible route is evaluation.

## Context Extension Recommendations

- **Topic**: measuring compiled Lean evaluation inside `#eval`.
- **Gap**: no project context records that a pure `let` bound between two `IO.monoMsNow` reads is
  floated past the second read, so a naive harness reports 0 ms for every stage. This cost five
  probe rounds in this dispatch and would cost the same again.
- **Recommendation**: add a note to `context/project/lean4/operations/` giving the correct harness
  shape - force the value through an `IO` write before the second clock read - and the symptom to
  recognise, which is every stage at 0 ms while the run never finishes.

- **Topic**: `#eval` against `decide` as evidence about a decision procedure.
- **Gap**: the Lean context treats `#eval` as the fast path and kernel reduction as the slow one.
  This dispatch measured the reverse by two orders of magnitude, because the cost was repeated
  evaluation of closed subterms that `whnf` caches and the interpreter does not.
- **Recommendation**: record that a decision procedure which stalls under `#eval` must be
  re-probed under `decide` before being called unreachable, with these figures as the worked case.

- **Topic**: recomputation cost in `decide`-facing `Finset` code.
- **Gap**: nothing records the pattern where a `Finset`-valued definition called inside a
  `filter` lambda is re-evaluated per element. That pattern is the whole content of this
  diagnosis and recurs wherever a decision procedure is built from nested `Finset.filter`s.
- **Recommendation**: record the pattern, the four-deep nest it produced here, and the
  hoist-into-a-table remedy, with the before and after figures.

## Appendix

Probe inventory, all under `specs/716_sliced_certificate_liveat_nontermination/probes/`:

- `01_structure_sizes.lean` - structural sizes for `certA` and the embedded witness. Broken harness.
- `02_fixpoint_timing.lean` - first stage-by-stage attempt; localized the stall inside the inner fixpoint.
- `03_eufix_growth.lean` - `EUFix.iter` at successive indices.
- `04_step_bisect.lean`, `05_mem_control.lean`, `06_filter_bisect.lean`, `08_minimal_mem.lean`, `09_predt_filter.lean` - membership and filter controls. These chased an artifact of the broken harness and are retained only as a record of the false trail.
- `07_instances.lean` - prints the `DecidableEq certA.TPos` and `Decidable (w ∈ verts)` instance terms.
- `10_corrected_timing.lean` - corrected harness; the first trustworthy figures.
- `11_memoized_mirror.lean` - the hoisted mirror, and the embedded-witness comparison.
- `12_kernel_decide.lean` - `decide` at the leaf layers.
- `13_kernel_fwd.lean`, `13_kernel_bwd.lean`, `13_kernel_liveat.lean` - `decide` at the fixpoint layers.
- `14_kernel_control.lean`, `14_kernel_card2.lean`, `14_kernel_card4.lean`, `14_kernel_certifies.lean`, `14_kernel_tgtlive.lean` - the two false controls and the three positive Tier-2 results.
- `15_kernel_certB.lean` - `certB.Certifies` by `decide`; the pending run.

Source anchors: `Nu.gfp` and `EUFix.lfp` at `Fixpoint.lean:180` and `Fixpoint.lean:427`;
`fwdLiveStep` / `bwdLiveStep` at `LiveFix.lean:149` and `LiveFix.lean:154`; `liveAt` at
`Stable.lean:492`; `verts`, `succT`, `predT` at `Timed.lean:148`, `Timed.lean:401`,
`Timed.lean:405`; `posAt`, `succP`, `predP`, `card_Pos` at `Position.lean:182`,
`Position.lean:220`, `Position.lean:224`, `Position.lean:132`.
