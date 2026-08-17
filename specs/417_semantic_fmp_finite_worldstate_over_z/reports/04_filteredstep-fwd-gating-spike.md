# Research Report: `filteredStep_fwd` gating spike

- **Task**: 417 - semantic_fmp_finite_worldstate_over_z
- **Started**: 2026-08-17T00:00:00Z
- **Completed**: 2026-08-17T00:00:00Z
- **Effort**: ~1 dispatch (go/no-go spike, handoff §6)
- **Dependencies**: `handoffs/01_phase-7-12-revision-handoff.md`, `specs/decisions/untl-snce-argument-order.md`
- **Sources/Inputs**:
  - Governing documents: `specs/417_semantic_fmp_finite_worldstate_over_z/handoffs/01_phase-7-12-revision-handoff.md` (§3.1, §3.3, §4.1, §4.4, §6, §7); `specs/decisions/untl-snce-argument-order.md`
  - Proof system: `FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/ProofSystem/Derivation.lean`, `FormalSystem/ProofSystem/Derivable.lean`
  - MCS/filtration layer: `FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean`, `FormalSystem/Metalogic/Decidability/FMP/ClosureMCS.lean`, `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean`
  - Semantics and soundness: `FormalSystem/Semantics/Truth.lean`, `FormalSystem/Semantics/TaskFrame.lean`, `FormalSystem/Metalogic/Soundness.lean`
  - Prior evidence: `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase7-filtered-frame-is-universal.lean`
- **Artifacts**:
  - `specs/417_semantic_fmp_finite_worldstate_over_z/reports/04_filteredstep-fwd-gating-spike.md` (this report)
  - `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean` (568 lines, sorry-free, 9 audited declarations)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

**Verdict: (b), in a sharper and cheaper form than anticipated — but with a machine-checked
(c)-shaped refutation attached to the layer as it currently stands.**

- The ℤ-exact fixpoint unfolding of handoff §4.1 **is derivable as a theorem schema**, and
  **no new axiom is needed**. It is derivable at `FrameClass.Discrete` from axioms already in
  the tree. Both the `X(g ∧ U(e,g))` shape and handoff §4.4's table shape
  `X g ∧ X U(e,g)` are machine-checked, in both directions.
- **`filteredStep_fwd` is nevertheless FALSE for the repository's existing `FilteredWorld φ`,
  and this is machine-checked, not conjectured.** `ClosureMCS` hard-wires consistency and
  deductive closure to `FrameClass.Base` (`RestrictedMCS/Basic.lean:72` and `:80`), and the
  schema is unavailable at `Base`. A concrete filtered world with **no successor at all**
  exists at `φ = U(⊤,⊥)`.
- The change of task character is therefore **not** "construction → axiom-extension". It is
  **"construction → frame-class re-parameterisation of the MCS layer, then construction"**.
  That is a smaller and much better-understood change than adding an axiom, but it is a real
  precondition that the handoff's Task B does not currently contain.
- The `filteredStep` relation defined here is verified **not universal**, so the Phase 7
  defect (`evidence/phase7-filtered-frame-is-universal.lean`) is not repeated.
- Handoff §3.3's claim that no canonical relation exists to filter is **confirmed**:
  `filteredStep` had to be defined outright.
- Partial credit, stated honestly: the **positive** half of `fwd` (constructing the successor)
  is **not** proved, at any frame class. It is moot for the layer as it stands, since `fwd` is
  refuted there. The residual open question is stated precisely in Findings 7.

## Context & Scope

Handoff §3.1 reduces the entire `def:frame` obligation for the successor Task B to two
seriality lemmas, because `TaskFrame.ofStep` (`FormalSystem/Semantics/IntNormalForm.lean:411`)
discharges all four axioms for an arbitrary one-step relation over ℤ. This spike answers the
single gating question that reduction exposes: **is `filteredStep_fwd` provable in this
repository's proof system?**

The spike is go/no-go. It does not implement Task B, does not touch the paper, and adds no
declaration to the built library — all Lean lives in a standalone evidence file compiled with
`lake env lean`. Argument order is event-first / guard-second throughout, per
`specs/decisions/untl-snce-argument-order.md`.

Baseline verification state at dispatch (`scripts/check-module-invariants.sh`): `lake build`
exits 0; C3 confirms the sole structural sorry is `countermodel_discrete` in
`FormalSystem/Metalogic/WeakCanonical/Transfer.lean`. Pre-existing, unrelated `#guard_msgs`
mismatches in `Tests/BimodalTest/{BoxSpreadProbe,RegionGateProbe,TableauConformance}.lean` make
the `lake build BimodalTest` sub-check red; this spike neither caused nor touched them.

## Findings

### 1. The unfolding is derivable at `FrameClass.Discrete` — schema named, no new axiom

Writing `X ψ := U(ψ, ⊥)` (the guard `⊥` forces the open interval strictly between to be empty,
so the witness is the immediate successor), the machine-checked schema is:

```
U(e, g)  <->  X e  \/  X (g /\ U(e, g))            -- unfoldForward / unfoldBackward
U(e, g)  <->  X e  \/  ( X g /\ X U(e, g) )        -- unfoldTableForward / unfoldTableBackward
```

The second is exactly handoff §4.4's `untl` table row, transposed from MCS membership to
derivability. `→` needs `Discrete`; `←` is already derivable at `Base`.

The declarations that carry it, all in `FormalSystem/ProofSystem/Axioms.lean`:

| Step | Declaration | Line | Role |
|---|---|---|---|
| `⊢ F⊤` | `Axiom.serial_future` | `:113` | future seriality |
| `⊢ U(⊤, ¬⊤)` | `Axiom.prior_UZ` at `φ := ⊤` | `:315` | the only `Discrete`-class step |
| `⊢ U(⊤, ⊥)` | `Axiom.left_mono_until_G` | `:123` | guard strengthening `¬⊤ → ⊥` |
| eventuality self-enrichment | `Axiom.self_accum_until` | `:174` | `U(e,g) → U(e, g ∧ U(e,g))` |
| witness comparison | `Axiom.linear_until` | `:196` | compares `U(e, g∧U(e,g))` against `U(⊤,⊥)` |
| dead disjunct removal | `Axiom.until_F` | `:226` | via `¬U(⊥, X)` |
| `←` direction | `Axiom.absorb_until` | `:186` | collapses the deferred witness |
| event weakening | `Axiom.right_mono_until` | `:134` | `X`-distribution over `∧` |

The load-bearing observation is `succIndicator` (evidence file `:172`): **`U(⊤,⊥)` — the
discreteness indicator, "the present has an immediate successor" — is a theorem at
`FrameClass.Discrete`**, even though no axiom asserts it. It falls out of `prior_UZ` at `⊤`,
whose consequent `U(⊤, ¬⊤)` has a guard that strengthens to `⊥` because `¬⊤ → ⊥` is a
tautology. Once `U(⊤,⊥)` is in hand, `linear_until` against `U(e, g ∧ U(e,g))` yields
`X e ∨ X⊥ ∨ X(g ∧ U(e,g))`, and the middle disjunct dies because its event is refutable.

This is a **derivability** result (`⊢`), not merely semantic validity over ℤ — it is a
`DerivationTree FrameClass.Discrete [] _`, which is what a Lindenbaum-style MCS extension
consumes. The two directions are reported separately above because they have different frame
classes and different consequences.

### 2. `X` distributes over conjunction at `Base`

`nextConj` (`:284`): `⊢[fc] (X A ∧ X B) → X(A ∧ B)`, for every frame class. This is the
functionality of the successor, and it is what closes the gap between the schema's
`X(g ∧ U(e,g))` shape and the table's `X g ∧ X U(e,g)` shape. Route: `linear_until` applied to
`U(A,⊥)` and `U(B,⊥)`, with the two off-diagonal disjuncts killed by refutable events. The
converse direction is plain event monotonicity. Both are `Base`.

### 3. The closure-MCS layer is hard-wired to `FrameClass.Base`

`FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean`:

- `:72` — `RestrictedConsistent phi S := ClosureRestricted phi S ∧ SetConsistent (fc := FrameClass.Base) S`
- `:80` — maximality is also stated against `SetConsistent (fc := FrameClass.Base)`

and `closure_mcs_deductively_closed` (`FMP/ClosureMCS.lean:171`) takes a
`DerivationTree FrameClass.Base`. `ClosureMCS` is a bare `abbrev` for `RestrictedMCS`
(`FMP/ClosureMCS.lean:69`), so `FilteredWorld φ` inherits the `Base` fixing wholesale. Nothing
in the filtration layer is polymorphic in the frame class.

### 4. `filteredStep_fwd` is refuted for the layer as it stands — machine-checked

Take `Φ := U(⊤, ⊥)` as the target formula of the filtration. Its subformula closure is
`{U(⊤,⊥), ⊤, ⊥}`. The table's `untl` row at `χ := ⊤`, `ψ := ⊥` reads

```
U(⊤,⊥) ∈ w   <->   ⊤ ∈ u  ∨  ( ⊥ ∈ u  ∧  U(⊤,⊥) ∈ u )
```

and `⊤ ∈ u` holds in **every** closure MCS by deductive closure (`top_mem`, `:469`). The
right-hand side is therefore unconditionally true, so any `w` omitting `U(⊤,⊥)` has **no
successor whatsoever** (`no_successor`, `:482`) — not a bad successor, none at all.

Such a `w` exists, and the argument is entirely syntactic:

1. `dense_consistent` (`:526`) — the dense system is consistent, by `soundness_dense_valid` at
   `D = ℚ` on `TaskFrame.trivialFrame`.
2. `denseCollapse` (`:520`) — a `Base` derivation of `U(⊤,⊥)` lifts to `Dense` (`Base ≤ Dense`)
   and contradicts `Axiom.dense_indicator` (`Axioms.lean:354`), which **is** `¬U(⊤,⊥)`.
3. `phi_not_base_derivable` (`:535`) — hence `⊬[Base] U(⊤,⊥)`.
4. `setConsistent_negPhi` (`:490`) and `exists_bad_world` (`:505`) — so `{¬U(⊤,⊥)}` is
   `Base`-consistent and Lindenbaum-extends to a closure MCS omitting `U(⊤,⊥)`.
5. `filteredStep_fwd_fails` (`:543`) — `¬ (∀ w : FilteredWorld Φ, ∃ u, filteredStep Φ w u)`.

The obstruction is exactly the frame-class mismatch of Finding 3: `U(⊤,⊥)` is a theorem at
`Discrete` (Finding 1) and consistently deniable at `Base`. A `Base`-consistent closure MCS is
entitled to believe time is dense; the table asks it to behave as if time were discrete.

This is not an artefact of a pathological `Φ`. The same argument runs for any `φ` whose closure
contains `U(χ, ψ)` with `χ` a `Base`-theorem and `U(χ, ψ)` itself not a `Base`-theorem —
`U(⊤, q)` for an atom `q` is another instance. `Φ = U(⊤,⊥)` was chosen because its refutation
needs no atom-consistency countermodel.

### 5. The relation is not universal, and `snce`/`box` rows are carried

`StepBundle` (`:406`) transcribes all three rows of handoff §4.4's table on
`ClosureMCSBundle φ`; `stepBundle_respects` (`:418`) proves it respects `ClosureMCSEquiv` in
both arguments, using `closure_untl_left/right`, `closure_snce_left/right` and `closure_box`
(`FormalSystem/Syntax/SubformulaClosure/Closure.lean:261,291,301,311,321`) to see that every
formula the table mentions is itself in the closure; `filteredStep` (`:443`) is the
`Quotient.lift₂`. Well-definedness was indeed immediate, as §4.4 predicted.

`filteredStep_not_universal` (`:561`) is machine-checked: at `Φ` the relation pins exactly to
membership of the indicator in the source world, and Finding 4 supplies a source world that
omits it. The Phase 7 failure mode is not repeated. No vacuous definition is used.

### 6. The pattern that would otherwise block the successor construction is derivably ruled out at `Discrete`

Independently of the `U(⊤,⊥)` obstruction, the natural way for a Lindenbaum-style
`filteredStep_fwd` to fail is an *over-determined successor*: a world `w` holding `U(p,q)`
while omitting both `U(p,r)` and `U(q,s)`. The first row then demands that the successor carry
`p`, or carry `q` together with `U(p,q)`; the other two forbid exactly those. No `u` can exist,
whatever its consistency.

`noBlockingTriple` (`:379`) machine-checks that at `FrameClass.Discrete` this pattern is
derivably inconsistent: `⊢[Discrete] U(p,q) → (U(p,r) ∨ U(q,s))`, straight off
`unfoldForward`. At `FrameClass.Base` the derivation is unavailable, because `unfoldForward`
is. This is a second, independent demonstration that the frame class is the whole issue.

### 7. What is *not* established

Stated plainly, because it is the residue that governs Task B's risk:

- **The positive half of `fwd` is unproved at any frame class.** Nothing here constructs a
  successor MCS. The single-eventuality case (`φ = U(p,q)`, closure `{U(p,q), p, q}`) is
  combinatorially trivial *given* that closure MCSs of the required types exist — put `p` into
  `u` when `U(p,q) ∈ w`, and keep all three out otherwise — but exhibiting those MCSs needs
  `SetConsistent {p}` for an atom `p`, which is a non-derivability fact requiring a
  countermodel. That work is wasted effort against the `Base`-fixed layer, since Finding 4
  refutes `fwd` there regardless.
- **Whether `fwd` holds after re-parameterisation to `Discrete` is open.** The evidence is
  favourable — Findings 1, 2 and 6 remove the two known obstructions — but the general
  construction (extend `w` to a full MCS, define `u := {χ : X χ ∈ ŵ}`, restrict to the closure)
  needs a "next is a normal modality" package: `X⊤` (= `succIndicator`, done), `X` closed under
  MP, and `X` conjunctive (= `nextConj`, done). Two of the three ingredients are already
  machine-checked here; the assembly is not.
- **`filteredStep_bwd` was not examined.** Handoff §4.4's plan to obtain it from
  `temporal_duality` is untested. Note that the dual of `succIndicator` needs `prior_SZ`
  (`Axioms.lean:320`), also `Discrete`, so the same re-parameterisation covers it.

## Decisions

- **Verdict (b)**, with the axiom-extension reading corrected: the schema needs **no new
  axiom**, but the closure-MCS layer needs a **frame-class change**. Surfaced here rather than
  absorbed, per the handoff's instruction.
- The `X ψ := U(ψ, ⊥)` encoding is adopted as the object-language "next": it is the existing
  discreteness indicator `U(⊤,⊥)` generalised, so it reuses the tree's own vocabulary and needs
  no syntax extension.
- Handoff §4.4's table is adopted unchanged. It is correct; it is simply stated at the wrong
  frame class relative to `ClosureMCS`.
- Evidence is delivered as a standalone file compiled with `lake env lean`, not wired into
  `lake build`. Wiring it in would make the library depend on a spike; the successor task
  should promote the reusable parts (see Recommendations) rather than import this file.

## Recommendations

Prioritised, with the handoff's A → B → C split as the frame.

1. **Insert a new precondition task ahead of Task B: re-parameterise the restricted-MCS layer
   by frame class.** Change `RestrictedConsistent` / `RestrictedMCS`
   (`RestrictedMCS/Basic.lean:71-80`) and `closure_mcs_deductively_closed`
   (`FMP/ClosureMCS.lean:171`) to take `{fc : FrameClass}`, defaulting to `Base` so existing
   call sites are unaffected, and instantiate the FMP filtration at `Discrete`. This is
   mechanical but non-trivial in extent: `ClosureMCS`, `ClosureMCSBundle`, `FilteredWorld`,
   `FiniteModel`, and `TruthPreservation` all sit downstream. Risk: low-medium, effort:
   medium. **Task B cannot start before this lands** — it is not optional and not deferrable.
2. **Promote the unfolding schema into the library** as part of that task, in
   `FormalSystem/Theorems/TemporalDerived.lean` or a new `Theorems/DiscreteUnfolding.lean`:
   `succIndicator`, `nextConj`, `unfoldTableForward`, `unfoldTableBackward`. These are
   general-purpose facts about the `Discrete` system, useful well beyond the FMP, and they are
   already sorry-free. The frame-class-polymorphic plumbing (`orElim`, `andIntro`, `guardMono`,
   `eventMono`) is also worth promoting — the existing `Theorems/Propositional` library fixes
   `Base` for its disjunction reasoning, which is why this spike had to rebuild it.
3. **Re-scope Task B** to: (i) the "next is a normal modality" package at `Discrete`
   (`X⊤`, MP-closure, conjunctivity — two thirds already done), (ii) the successor construction
   via a full-MCS extension, (iii) `filteredStep_bwd` by `temporal_duality`, (iv)
   `FilteredStepFrame` via `TaskFrame.ofStep`. The handoff's "medium-high risk, concentrated in
   `fwd`" assessment stands, but the risk is now located: it is in (ii), not in the axiom base.
4. **Keep handoff §5's A → B → C order.** Nothing found here disturbs it. Task A (the bi-lasso
   layer) is untouched by this result and remains independently shippable; the argument for
   doing it first is strengthened, since Task B has just acquired a precondition.
5. **Retain this evidence file** alongside the two existing probes, per §7's regression-guard
   policy. `filteredStep_not_universal` is a permanent guard against reviving the Phase 7
   universal relation, and `filteredStep_fwd_fails` is a permanent guard against re-attempting
   the filtration at `FrameClass.Base`. Unlike the other two, this one is *not* currently in
   the build; wiring it in should wait until recommendation 1 lands, at which point
   `filteredStep_fwd_fails` becomes a statement about the `Base` instantiation specifically.

## Risks & Mitigations

- **Risk**: the re-parameterisation (recommendation 1) turns out to have wide blast radius
  through `FMP/TruthPreservation.lean` and `FMP/FMP.lean`.
  **Mitigation**: default the new parameter to `Base` so every existing call site elaborates
  unchanged; only the filtration used by Task B is instantiated at `Discrete`. Verify with
  `lake build FormalSystem.Metalogic.Decidability.FMP.FMP` before touching anything else.
- **Risk**: `fwd` fails again at `Discrete` for a reason not visible from here.
  **Mitigation**: the successor construction should be spiked the same way — build the
  "next is a normal modality" package first (it is small, and two of three lemmas exist), and
  only then attempt the Lindenbaum step. If the package lands and `fwd` still resists, that is a
  genuine `[BLOCKED]` with a much sharper goal state than the current one.
- **Risk**: `Discrete` and `Dedekind` are incomparable in `FrameClass`'s order
  (`Axioms.lean:511-517`), so a `Discrete`-instantiated FMP cannot borrow anything proved at
  `Dedekind`.
  **Mitigation**: none needed for Task B, which does not touch the Dedekind fragment — but the
  successor task should not assume `lift` is available in that direction.
- **Risk**: scope creep from "spike" into "implementation" when promoting the schema.
  **Mitigation**: recommendation 2 is a copy-and-rename of already-green declarations, not new
  proof work.

## Context Extension Recommendations

- **Topic**: Frame-class parameterisation as a repository-wide invariant.
  **Gap**: nothing in `.claude/context/project/lean4/` records that `RestrictedMCS`, and hence
  the whole FMP filtration layer, silently fixes `FrameClass.Base` while the target semantics
  is ℤ-time (i.e. `Discrete`). This spike's entire negative result is that mismatch, and it
  cost a full dispatch to discover.
  **Recommendation**: add a short note to the lean4 context — "MCS layers fix `FrameClass.Base`;
  check the frame class before assuming a temporal schema is available" — with pointers to
  `RestrictedMCS/Basic.lean:72,80` and `Axiom.minFrameClass` (`Axioms.lean:573`).

## Appendix

- Evidence file: `specs/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean`
  — 568 lines, no `sorry`, no vacuous definition. Compile with
  `lake env lean specs/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean`.
- Axiom audit, emitted by the file's own `#print axioms` block. All nine audited declarations
  report `[propext, Classical.choice, Quot.sound]` — no `sorryAx`:
  `succIndicator`, `unfoldForward`, `unfoldBackward`, `noBlockingTriple`, `nextConj`,
  `unfoldTableForward`, `unfoldTableBackward`, `filteredStep_fwd_fails`,
  `filteredStep_not_universal`.
- Handoff confidence table, updated by this spike:
  - "`filteredStep_fwd` is provable here — **Unknown**" → **resolved**: false at `Base`, open
    at `Discrete`, with the two known obstructions removed.
  - "No canonical relation exists to filter" → **confirmed** by construction: `filteredStep`
    had to be defined outright.
  - "`ℤ`-unfolding is exact and closure is adequate" → **upgraded** from semantic observation to
    machine-checked derivability at `Discrete`.
