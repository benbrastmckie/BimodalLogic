# Research Report: LCU docstring correction, omega_chain segment-property restoration, backward LC_n

- **Task**: 871 - Correct LCU docstring and restore omega_chain segment-property parameter
- **Started**: 2026-11-05T00:00:00Z
- **Completed**: 2026-11-05T00:00:00Z
- **Effort**: ~0.5 hours
- **Dependencies**: None
- **Sources/Inputs**:
  - `FormalSystem/PlusLanguage/PlusLCSchema.lean` (read in full)
  - `FormalSystem/PlusLanguage/PlusOmegaChain.lean` (read in full)
  - `FormalSystem/PlusLanguage/PlusReversal.lean`, `FormalSystem/PlusLanguage/PlusValidity.lean`,
    `FormalSystem/PlusLanguage/PlusPasting.lean`, `FormalSystem/PlusLanguage/PlusTruth.lean`,
    `FormalSystem/PlusLanguage/Formula.lean`
  - `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` (Part I, lines 604-704)
  - `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md`
    (findings 1-2)
  - `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
    (section 2.3)
  - `docs/theorem-index.md`, `scripts/check-module-invariants.sh` (C14 baseline pair, C15 second assertion)
  - lean-lsp MCP `lean_run_code` (five compiled probes; `lean_local_search` reported
    `index: unavailable`, so declaration existence was additionally confirmed by grep over the
    source tree)
- **Artifacts**:
  - `specs/871_lcu_omega_chain_record_repair/reports/01_lcu-omega-chain-record-repair.md`
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All three parts are confirmed against the live tree, and all three are mechanical.** The
  docstring claim is false as stated, the `P` parameter is genuinely absent from the landed
  `omega_chain`, and the backward schema really is a one-line corollary.
- **Every code change was verified by a compiled probe during this research**, not predicted: the
  `P`-carrying `stg_step`/`omega_chain` port, the adapted `PlusLCSchema.lean` call site (the whole
  of `lcN_plusValidInt` re-proved against the new signature), the one-line backward corollary, and
  the intended `LCU` segment property's discharge of the new stability hypothesis all elaborate
  with zero diagnostics.
- **The axiom profiles do not move.** `#print axioms` on the restored declarations reports
  `[propext, Quot.sound]` for `stg_step` and `[propext, Classical.choice, Quot.sound]` for
  `omega_chain` — the values already in the C14 baseline — and the new corollary measures
  `[propext, Classical.choice, Quot.sound]` (`pcq`).
- **The port dropped three things from the probe, not one.** Besides `P` and its stability
  hypothesis `hP`, the landed `omega_chain` also dropped the probe's `c 0 = s₀` conclusion and its
  agreement-below-`s₀` conclusion. `c 0 = s₀` is load-bearing for `LCU` (it is what closes the
  `[t, c 0)` gap in `LCU`'s consequent `G≤`), so restoring `P` alone would leave the until-form
  still short of its stated semantic core. The full-fidelity signature was verified to compile.
- **Exactly two surfaces carry the wrong `LCU` claim**: `PlusLCSchema.lean` (module docstring and
  the `lcN` declaration docstring) and `docs/theorem-index.md`'s `lcN_plusValidZTime` row. No
  `typst/`, `latex/`, `research/` or `README` surface mentions `LCU` at all.
- **`omega_chain` has exactly one consumer in the library**, so the signature change is a
  one-call-site edit. The `omega_chain_*` names in `Metalogic/BXCanonical/Chronicle/` are a
  different, unrelated family.

## Context & Scope

Scope is the three corrective parts the dispatch names, all in
`FormalSystem/PlusLanguage/` plus the two record surfaces (`docs/theorem-index.md` and the C14
baseline pair in `scripts/check-module-invariants.sh`). Declaring the until-form `LCU` itself is
explicitly out of scope and waits on the oriented-forest Saturation lemma and the `SeparationOver`
task.

Constraints honoured in this dispatch: nothing under `FormalSystem/`, `Tests/`, `docs/` or
`scripts/` was modified; no `lake build` was run (all verification went through `lean_run_code`,
which elaborates against the already-built `.olean` closure); no claim about `LCU`'s validity at
any frame class is made here.

Concurrency: siblings 884 (plan) and 867 (research) were scheduled this same cycle. 884's declared
`file_scope` includes
`specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`,
which this dispatch read but did not write. No foreign commit, foreign uncommitted modification in
this task's territory, or build not started here was observed.

## Findings

### 1. Part (1): the `LCU` docstring claim is false, and it is a substantive error

`PlusLCSchema.lean` carries the claim twice:

- the module docstring's section `## `LCU`, and the relation to `blc``: "**`LCU` is the `n = 1`
  instance of `lcN`** — which is what the schema specializes to at a single parameter — and is not
  given a declaration of its own here";
- the `lcN` declaration docstring: "`LCU` is the `n = 1` instance."

Read against the definitions in the same file, the two formulas are:

- `lcN 1 α` unfolds to `⊡G≤(⟐α₀ → ⟐F⟐α₀) → ⟐G≤(⟐α₀ → F⟐α₀)` — **one** parameter (`(0+1) % 1 = 0`),
  `PlusFormula.someFuture` only, no `untl`.
- `LCU`, as the upstream axiomatizability report defines it, is
  `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))` — **two** parameters, the `untl`
  connective in both antecedent and consequent, and a consequent that is an implication *outside*
  the `⟐` rather than inside it.

These are different formulas and neither is an instance of the other. The degenerate reading does
not rescue the claim either: at `β := ⊤`, `LCU`'s antecedent does coincide with `lcN 1`'s, but its
consequent `⟐α → ⟐G≤(⟐α ∨ F⟐α)` is a disjunction under a separate `⟐α` guard, not `lcN 1`'s
`⟐G≤(⟐α₀ → F⟐α₀)`.

Why it is substantive rather than cosmetic: L⁺ has `untl` and `snce` as primitives, so a
Reynolds-style construction must discharge until-commitments as well as F-commitments, and the
F-form schema does not discharge an until-commitment's guard. A reader of the module today is
told the until-form ingredient is present when it is not.

Second surface: `docs/theorem-index.md`'s `FormalSystem.PlusLanguage.lcN_plusValidZTime` row
repeats "`LCU` is the `n = 1` instance". Both surfaces must be corrected together or the ledger
and the module disagree, which the index's own "How to read a row" preamble forbids.

### 2. Part (2): `P` is genuinely absent, and so are two further probe conclusions

The source probe's `omega_chain` (`specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean`,
lines 681-688) carries, beyond the landed signature:

- `P : ℕ → (ℤ → W) → ℤ → ℤ → Prop` — a property of a history and a half-open segment
  (declared at line 659, the probe's `variable` line);
- `hP : ∀ i (η η' : ℤ → W) s s', (∀ n, s < n → n ≤ s' → η' n = η n) → P i η s s' → P i η' s s'` —
  the stability hypothesis saying `P` reads only the segment `(s, s']`, which is exactly what makes
  it survive the splice;
- the strengthened step hypothesis, whose continuation must additionally satisfy `P i η s s'`;
- the conclusion `∀ k, P k τ (c k) (c (k + 1))`;
- **and two further conclusions the port also dropped**: `c 0 = s₀` and
  `∀ n, n ≤ s₀ → τ n = ρ₀ n`.

The landed `omega_chain` has none of these. Its docstring records `A` as "a predicate on a time and
a world state" and says nothing about segments; the port's own record described `P` as "the probe's
unused segment-property parameter". It is unused *by `lcN`*; it is precisely the hook the upstream
report names as `LCU`'s compiled semantic core — `A k := ⟐α` together with
`P k η s s' := "⟐β throughout the segment"`.

**`c 0 = s₀` matters for `LCU` and should be restored in the same edit.** `LCU`'s consequent asks
for `G≤(⟐α ∨ (⟐β U ⟐α))` from the evaluation time `t` onward. The chain is started at an
`⟐α`-point, and for `LCU` that point is `t` itself. Without `c 0 = s₀` the conclusion gives only
`t ≤ c k`, so the interval `[t, c 0)` is covered by no segment and no marker — the base case of the
coverage argument is missing. With `c 0 = s₀` and `s₀ := t` there is no gap. Restoring it costs
turning the existential `hstart` into the probe's five explicit arguments, which is a two-line
change at the single call site.

**Binder choice.** The probe's `P` consumes the raw history function `ℤ → W`. In the library the
faithful counterpart is `P : ℕ → WorldHistory F → F.Duration → F.Duration → Prop`, with `hP`'s
premise phrased on `.state` agreement over `(s, s']`. This is the shape `LCU` needs, because its
`P` is stated with `PlusTruthAt M η z (PlusFormula.dstab β)`, which wants a `WorldHistory`. (`A`
stays a time-and-state predicate; the two parameters face different directions and the module
docstring already explains why `A` cannot be history-valued.)

**Soundness of the restored hypothesis for the intended consumer, verified.** `stab_state_only`
(`PlusLanguage/PlusTruth.lean`) makes `⟐β` state-local, so the `LCU` segment property
`P k η s s' := ∀ z, s < z → z ≤ s' → PlusTruthAt M η z (⟐β)` satisfies `hP` — proved in probe 3
below from `dstab_iff` and state agreement alone.

**Call-site inventory.** `grep` over `FormalSystem/` and `Tests/` finds exactly one consumer of
`PlusLanguage.omega_chain`: `lcN_plusValidInt` in `PlusLCSchema.lean`. The unrelated
`omega_chain_c0`, `omega_chain_dom_mono`, `omega_chain_f_agrees` family in
`Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` is a different namespace and a
different construction; `stg_step` and `Stg` have no consumer outside `PlusOmegaChain.lean` itself.
The adaptation needed at the one site is: pass `P := fun _ _ _ _ => True`, discharge `hP` with
`fun _ _ _ _ _ _ h => h`, pass the start data as five explicit arguments instead of an anonymous
constructor, add `trivial` to the `hstep` witness tuple, and ignore three components in the
`obtain` pattern.

### 3. Part (3): the backward schema is a one-line corollary, and it typechecks

`plusValidIn_reflectTime` (`PlusLanguage/PlusReversal.lean`) is compiled at an *arbitrary*
`ProofSystem.FrameClass` with no closure hypothesis, and `PlusValidZTime` is by definition
`PlusValidIn ProofSystem.FrameClass.ZTime` (`PlusLanguage/PlusValidity.lean`). So the backward
limit-closure schema is:

    theorem lcN_reflectTime_plusValidZTime (n : ℕ) (hn : 0 < n) (α : ℕ → PlusFormula) :
        PlusValidZTime (lcN n α).reflectTime :=
      plusValidIn_reflectTime (lcN_plusValidZTime n hn α)

Verified: elaborates with zero diagnostics, and `#print axioms` reports
`[propext, Classical.choice, Quot.sound]`.

**Keep the statement at `(lcN n α).reflectTime`; do not expand the mirror.** Writing the mirror
form explicitly (`⊡H≤ … → ⟐H≤ …`) would require a new `H≤` definition (the module defines `gle`
only, and `Formula`/`PlusFormula` carry no reflexive-past closure), a `reflect_time_gle`
push-through lemma, and a `reflect_time_bigAnd` lemma for the `ℕ`-indexed conjunction defined in
`PlusLCSchema.lean`. That is three new declarations to state what the one-liner already proves, and
it exceeds "costs only a corollary". The docstring can state the mirror reading in prose instead:
`reflectTime` fixes `⊡` and exchanges `U`/`S`, `F`/`P`, `G`/`H`, so the reflection of `LC_n` is the
same cycling schema read backwards in time, and it is valid at `.ZTime` because `ℤ` is
reflection-symmetric.

### 4. Record-surface obligations the three parts incur

- `docs/theorem-index.md`: correct the `lcN_plusValidZTime` row's `LCU` sentence; update the
  `stg_step` and `omega_chain` rows' Statement cells to mention the segment property; add one row
  for the new corollary, with `ZTime` in the Frame class column and `pcq pinned:C14` in the Axioms
  column.
- `scripts/check-module-invariants.sh`: the C14 baseline is a **pair** of heredocs
  (`C14_BASELINE` and the `#print axioms` script `C14LEAN`) compared by exact string equality, so
  the new corollary needs one matched pair of lines appended **in the same position on both
  sides**, following the in-script convention documented above the block. The existing `stg_step`
  and `omega_chain` lines need no edit, since their measured profiles are unchanged.
- C15's second assertion requires every theorem-index row's declaration docstring to carry a
  `Paper:` line. The module's convention is `Paper: — (formalization-native; the manuscript states
  no limit-closure schema)`; the new corollary's docstring must carry it.
- `PlusOmegaChain.lean`'s module docstring: step 4 of "## The argument", the `## Main Results`
  bullet for `omega_chain`, and the `Stg`/`stg_step`/`omega_chain` declaration docstrings all
  describe the `A`-only signature and must be updated to introduce `P` and say what `hP` buys.
- `PlusLCSchema.lean`'s `## Main Results` list gains the new corollary;
  `FormalSystem/PlusLanguage.lean`'s pointer line for `omega_chain` (line 75) is generic enough to
  stand, but should be checked.

## Decisions

- **`P`'s library type is `ℕ → WorldHistory F → F.Duration → F.Duration → Prop`**, not the
  state-function form, because the intended `LCU` instantiation is stated with `PlusTruthAt`.
- **`hP`'s segment is half-open `(s, s']`**, verbatim from the probe. The upstream report's prose
  says "`⟐β` on `(s, s')`"; the half-open form is what `paste_agreeFrom` discharges directly
  (it gives agreement on `[s, ∞)`, which is strictly stronger than needed) and what the probe
  proves, so the probe wins over the prose.
- **Restore the probe's full signature**, including `c 0 = s₀` and the agreement-below-`s₀`
  conclusion, rather than `P`/`hP` alone — justified by the `LCU` coverage gap in finding 2 and
  verified to compile. If the plan prefers to hold scope to the dispatch's literal wording, the
  `P`/`hP`-only variant also compiles (probe 2); the `c 0 = s₀` clause would then have to be added
  by whichever task lands `LCU`.
- **The backward schema stays unexpanded** at `(lcN n α).reflectTime` (finding 3).
- **The corrected `LCU` prose says what `LCU` is, not merely that it is not `lcN 1`.** Draft
  replacement for the module docstring section, for the plan to carry verbatim or amend:

  > **`LCU` is not an instance of `lcN`, and is not declared here.** `LCU` is the *until-form*
  > limit-closure schema `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))`: two parameters and
  > the `untl` connective, where `lcN` at `n = 1` is `⊡G≤(⟐α₀ → ⟐F⟐α₀) → ⟐G≤(⟐α₀ → F⟐α₀)` — one
  > parameter, `F` only, and no `untl`. Neither is an instance of the other. `PlusOmegaChain.lean`'s
  > `omega_chain` carries the segment-property parameter `P` that `LCU`'s semantic core needs, but
  > the formula and its validity are **not** stated anywhere in this tree.

## Recommendations

Priority order, all for the implementation phase of this task:

1. **`PlusOmegaChain.lean`: restore the probe's signature.** Transcribe the verified probe 4 text
   (appendix): `Stg` unchanged; `stg_step` gains `{P}` and `hP`, its `H` gains the `P k η s s'`
   conjunct, and its conclusion gains `P i y.hist x.mark y.mark`, proved by
   `hP i η _ x.mark s' (fun z h1 _ => hfrom z h1.le) hP'`; `omega_chain` gains `P`, `hP`, the five
   explicit start arguments, and the three restored conclusions. Update the module docstring (step
   4, `## Main Results`) and the three declaration docstrings.
2. **`PlusLCSchema.lean`: adapt the one call site** exactly as in finding 2's inventory, and
   **correct the `LCU` prose** in both places (module docstring section, `lcN` declaration
   docstring) using the draft in Decisions.
3. **`PlusLCSchema.lean`: add `lcN_reflectTime_plusValidZTime`** as the one-line corollary, with a
   `Paper: —` line and the mirror reading in prose, and list it under `## Main Results`.
4. **Record surfaces**: correct the `lcN_plusValidZTime` row in `docs/theorem-index.md`, refresh
   the `stg_step`/`omega_chain` Statement cells, add the corollary's row, and append the one
   matched C14 baseline pair.
5. **Verification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
   FormalSystem.PlusLanguage.PlusLCSchema` for the scoped check, then
   `bash scripts/check-module-invariants.sh` for C14/C15. Both are long-running; use the bounded
   wait idiom from `context/project/lean4/operations/long-builds.md`.

Zero-debt note: no part of this task needs a `sorry`, an axiom, or a placeholder. Every edit's
Lean content is already compiled in the probes below.

## Risks & Mitigations

- **Risk**: the `Nat.rec`-built `chain` in `omega_chain` relies on an iota-reduction defeq between
  `chain (k+1)` and `(stg_step hP hstep (chain k)).choose`; adding arguments to `stg_step` could in
  principle disturb it. **Mitigated**: probe 4 elaborates the whole restored `omega_chain`
  unchanged in that respect, zero diagnostics.
- **Risk**: the C14 baseline pair is compared by exact string equality and by position, so a line
  appended at the wrong trailing position in one heredoc silently fails the check. **Mitigation**:
  append to both heredocs in the same relative position, immediately after the existing
  `lcN_plusValidZTime` lines, and read the in-script comment block above the baseline before
  editing.
- **Risk**: `docs/theorem-index.md`'s Axioms column is generated from the baselines, never typed;
  a hand-typed cell that disagrees fails C14. **Mitigation**: the measured value for the new
  corollary is `pcq`, measured in this session, not carried.
- **Risk** (scope): restoring `c 0 = s₀` widens the dispatch's literal wording. **Mitigation**:
  both variants are verified; the decision is recorded above with its reason, and the narrower
  variant remains available to the plan.
- **Risk**: `lean_local_search` reported `index: unavailable` for this session, so an empty LSP
  search result would not have been proof of absence. **Mitigation**: every absence claim in this
  report (no second `LCU` surface, one `omega_chain` consumer) rests on `grep` over the source
  tree, not on an empty index result; every presence claim rests on a compiled probe.

## Tactic Survey Results

Not applicable — no goal in this task is closed by tactic search. The three changes are a
docstring correction, a mechanical signature port transcribed from a compiled probe, and a term-mode
one-liner. The five `lean_run_code` probes in the appendix are the verification of record.

## Context Extension Recommendations

- **Topic**: porting a `specs/evidence/` probe into the library without silently dropping binders.
- **Gap**: this task exists because a port described a live parameter as "unused" and removed it,
  together with two conclusions nobody recorded as removed. There is no context file stating the
  obligation that a port either carries every binder and conclusion of its source or records each
  omission by name at the declaration site.
- **Recommendation**: a short note under `context/project/lean4/patterns/` (for example
  `evidence-probe-port-fidelity.md`) stating the rule — a dropped binder is recorded in the ported
  declaration's docstring with the reason and the source line range — and pointing at this episode
  as the worked example. This is a recommendation for a separate meta task, not part of this one.

## Appendix

### Verification probes (all run via lean-lsp `lean_run_code`, all zero diagnostics)

1. The one-line backward corollary against the live library — `plusValidIn_reflectTime
   (lcN_plusValidZTime n hn α) : PlusValidZTime (lcN n α).reflectTime`.
2. `P`/`hP`-only `stg_step` + `omega_chain`, plus `omega_chain_pfree` deriving the landed
   `P`-free conclusion from the new one (the backward-compatibility demonstration).
3. The intended `LCU` segment property `P k η s s' := ∀ z, s < z → z ≤ s' → PlusTruthAt M η z (⟐β)`
   discharging `hP`, from `dstab_iff` and state agreement.
4. The full-fidelity `omega_chain` (with `c 0 = s₀` and agreement below `s₀`) **together with**
   `lcN_plusValidInt` re-proved against it — the complete part-(2) change set, call site included.
5. `#print axioms` on the restored `stg_step` and `omega_chain` (`[propext, Quot.sound]` and
   `[propext, Classical.choice, Quot.sound]`) and on the new corollary (`pcq`).

The probe texts are not reproduced here; they are mechanical expansions of the signatures quoted
in findings 2 and 3 and are reconstructible from them. The implementation phase should re-elaborate
rather than trust this summary.

### Source locations cited

- Wrong `LCU` claim: `FormalSystem/PlusLanguage/PlusLCSchema.lean`, module docstring section
  `## `LCU`, and the relation to `blc``, and the `lcN` declaration docstring.
- Second wrong-claim surface: `docs/theorem-index.md`, the
  `FormalSystem.PlusLanguage.lcN_plusValidZTime` row.
- Probe source for part (2): `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean`,
  `variable` line 659, `stg_step` lines 661-676, `omega_chain` lines 681-702.
- Landed declarations to change: `FormalSystem/PlusLanguage/PlusOmegaChain.lean` (`Stg`,
  `stg_step`, `omega_chain`), `FormalSystem/PlusLanguage/PlusLCSchema.lean` (`lcN_plusValidInt`
  call site, docstrings, new corollary).
- Reflection machinery: `FormalSystem/PlusLanguage/PlusReversal.lean`
  (`plusValidIn_reflectTime`), `FormalSystem/PlusLanguage/PlusValidity.lean` (`PlusValidZTime`),
  `FormalSystem/PlusLanguage/Formula.lean` (`reflectTime` and its push-through family).
- State-locality used by `hP`: `FormalSystem/PlusLanguage/PlusTruth.lean` (`stab_state_only`).
- Paste lemmas used by `stg_step`: `FormalSystem/PlusLanguage/PlusPasting.lean`
  (`paste_agreeUpTo`, `paste_agreeFrom`).
- Gate machinery: `scripts/check-module-invariants.sh` (C14 baseline pair, C15 second assertion).
- `LCU`'s definition of record and its semantic core:
  `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
  section 2.3; the two defects this task repairs are stated in
  `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md`
  findings 1-2.
