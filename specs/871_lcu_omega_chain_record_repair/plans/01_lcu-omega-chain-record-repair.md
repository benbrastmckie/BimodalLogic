# Implementation Plan: LCU docstring correction, omega_chain segment-property restoration, backward LC_n

- **Task**: 871 - Correct LCU docstring and restore omega_chain segment-property parameter
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: `specs/871_lcu_omega_chain_record_repair/reports/01_lcu-omega-chain-record-repair.md`
- **Artifacts**: plans/01_lcu-omega-chain-record-repair.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Three purely corrective repairs to the landed `LC_n` / ω-chain layer, all confirmed against the
live tree and all verified by compiled probes during research: a false `LCU` claim in
`PlusLCSchema.lean`'s prose (and its echo in `docs/theorem-index.md`), the segment-property
parameter `P` and its stability hypothesis `hP` dropped from `omega_chain` when the evidence probe
was ported into the library, and the backward limit-closure schema that `plusValidIn_reflectTime`
already proves in one line. No new mathematics: a prose correction, a mechanical signature
restoration with a one-call-site adaptation, and a term-mode corollary. Definition of done: the
restored signatures and the new corollary compile with zero `sorry`, the two wrong-`LCU` surfaces
state what `LCU` actually is, and the repository's complete gate set is green with C14 carrying the
corollary's measured axiom profile.

### Research Integration

The research report is the primary input and it is unusually complete: every code change in this
plan was elaborated during research via `lean_run_code` with zero diagnostics, including the whole
of `lcN_plusValidInt` re-proved against the new `omega_chain` signature. Findings this plan acts
on directly:

- **Finding 1**: `lcN 1 α` is `⊡G≤(⟐α₀ → ⟐F⟐α₀) → ⟐G≤(⟐α₀ → F⟐α₀)` (one parameter, `F`-form, no
  `untl`); `LCU` is `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))` (two parameters, `untl`,
  consequent an implication *outside* the `⟐`). Neither is an instance of the other, and the
  `β := ⊤` degenerate reading does not rescue the claim either. Exactly two surfaces carry the
  wrong claim: `PlusLCSchema.lean` (module docstring section and the `lcN` declaration docstring)
  and `docs/theorem-index.md`'s `lcN_plusValidZTime` row.
- **Finding 2**: the port dropped **three** things, not one — `P`, `hP`, *and* the probe's
  `c 0 = s₀` conclusion plus its agreement-below-`s₀` conclusion. `c 0 = s₀` is load-bearing for
  `LCU` (it closes the `[t, c 0)` gap in `LCU`'s consequent `G≤`), so Phase 1 restores the probe's
  full signature rather than `P`/`hP` alone. `omega_chain` has exactly one consumer in the
  library, so this is a one-call-site change.
- **Finding 3**: `plusValidIn_reflectTime` is compiled at an arbitrary `ProofSystem.FrameClass`
  with no closure hypothesis and `PlusValidZTime φ` is by definition
  `PlusValidIn ProofSystem.FrameClass.ZTime φ`, so the backward schema is a one-liner at
  `(lcN n α).reflectTime`. The expanded mirror form is explicitly rejected: it would need a new
  `H≤` definition, a `reflect_time_gle` push-through lemma, and a `reflect_time_bigAnd` lemma —
  three new declarations to state what the one-liner already proves.
- **Finding 4**: the record-surface obligations (`docs/theorem-index.md` rows, the C14 baseline
  *pair*, C15's `Paper:`-line requirement) are enumerated and drive Phase 5.

**One carried caveat the implementer must honour.** The research report deliberately did **not**
reproduce its five probe texts ("they are mechanical expansions of the signatures quoted in
findings 2 and 3 and are reconstructible from them. The implementation phase should re-elaborate
rather than trust this summary"). Every Lean signature in this plan's `## Lean Challenge
Statements` block is therefore a **transcription** from the report's prose, not a re-measured
artifact — re-elaborate each one before trusting it, per the Scope Hypothesis lines below.

### Prior Plan Reference

No prior plan for this task. The directly relevant prior artifact is task 864's plan
(`specs/864_land_lc_schema_limit_closure_soundness/plans/01_lc-schema-limit-closure-soundness.md`),
which landed the very modules this task repairs and whose final phase is the model for Phase 5's
gate set, its measure-then-paste C14 discipline, and its ledger-row column conventions. Effort
calibration from that plan: guarded scoped module builds were cheap; the unscoped build and
`check-module-invariants.sh` dominated, so Phase 5 carries the hour.

### Roadmap Alignment

No `roadmap_path` and no `roadmap_flag` were provided in this dispatch, so no roadmap-review or
roadmap-update phase is included and `specs/ROADMAP.md` is neither consulted nor modified by this
plan.

### Scope decision: full-fidelity restoration, not `P`/`hP` alone

The dispatch's literal wording names `P` together with its stability hypothesis, citing probe
lines 659-684. This plan restores the probe's **full** signature instead — additionally `c 0 = s₀`
and the agreement-below-`s₀` conclusion, which fall at probe lines 685-688, just past the cited
range. Reason (research finding 2, verified): `LCU`'s consequent asks for
`G≤(⟐α ∨ (⟐β U ⟐α))` from the evaluation time `t` onward, and without `c 0 = s₀` the conclusion
gives only `t ≤ c k`, leaving the interval `[t, c 0)` covered by no segment and no marker — the
base case of the coverage argument missing. Restoring `P` alone would leave the until-form still
short of its stated semantic core, and the omission would have to be repaired by whichever task
lands `LCU`. The cost is two extra lines at the single call site (turning `hstart` into five
explicit arguments) and three ignored components in one `obtain` pattern.

Both variants were verified to compile during research. If Phase 1 discovers the wider variant is
not in fact mechanical, the narrow `P`/`hP`-only variant is the documented fallback — see
Rollback/Contingency.

## Goals & Non-Goals

**Goals**:
- `stg_step` -- one splice, carrying the segment-property parameter, its stability hypothesis, the
  strengthened continuation hypothesis, and the segment-property conclusion at the new marker.
  Exact signature pinned under Lean Challenge Statements below.
- `omega_chain` -- the ω-chain principle at full probe fidelity: the segment-property parameter and
  its stability hypothesis, five explicit start arguments in place of an existential, and the three
  restored conclusions (the first marker equals the start time, agreement below the start time, and
  the segment property on every consecutive marker pair). Exact signature pinned under Lean
  Challenge Statements below.
- `lcN_reflectTime_plusValidZTime` -- the backward limit-closure schema, as the one-line
  reflection corollary of the forward schema's ZTime validity, stated at the reflected formula
  rather than an expanded mirror form.

**Non-Goals**:
- **Declaring the until-form `LCU` itself.** Explicitly out of scope per the dispatch: it waits on
  the oriented-forest `Saturation` lemma and the `SeparationOver` task. No phase may introduce an
  `LCU` definition, an `LCU` validity claim, or a `sorry` reaching for one. The repaired prose
  states what `LCU` *is* and that it is **not** declared in this tree.
- Any claim about `LCU`'s validity at any frame class.
- `.Base` validity of `LC_n` or of the backward schema. The cofinality obstruction is unchanged
  and stays stated-not-claimed.
- The **expanded mirror form** of the backward schema (`⊡H≤ … → ⟐H≤ …`). Rejected on cost grounds
  in research finding 3; the mirror reading goes in the corollary's docstring prose instead.
- Any change to `omega_limit`, `marker_mono`, `marker_agree_add`, `int_marker_add_le`,
  `intOrder_omega_cofinal`, or `int_marker_exists_gt`. Their signatures and measured axiom
  profiles are untouched by this task.
- Any new pasting operator. `PlusPasting.paste`, `paste_agreeUpTo` and `paste_agreeFrom` are
  reused unchanged.
- The `context/project/lean4/patterns/evidence-probe-port-fidelity.md` note the research report
  recommends. That is a separate meta task, not part of this one.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The Challenge Statement signatures are transcribed from the research report's prose, not from a re-measured probe (the report omitted its probe texts on purpose) | H | M | Phase 1 re-elaborates each restored signature before committing; every affected phase carries a Scope Hypothesis naming the carried figure and its source record. Per `plan-compliance.md`'s Statement Fidelity, an adjustment that makes a statement **weaker** under the same name is a `[BLOCKED]` escalation, not a permitted edit; a transcription slip corrected *upward* against the live library is a permitted adjustment |
| The `Nat.rec`-built `chain` in `omega_chain` relies on an iota-reduction defeq between `chain (k+1)` and `(stg_step … x).choose`; adding arguments to `stg_step` could disturb it | H | L | Research probe 4 elaborated the whole restored `omega_chain` with zero diagnostics, unchanged in that respect. If it does break, the failure is at Phase 1's own scoped build, before any downstream phase runs |
| A signature change lands without its call site, leaving `PlusLanguage` red | H | M | Phase 1 is a declared `Commit Mode: atomic-batch` over exactly two files; intermediate per-file states are expected red and MUST NOT be committed |
| The C14 baseline pair is compared by exact string equality **and by position**, so a line appended at the wrong trailing position in one heredoc silently fails | H | M | Both heredocs currently end with their `lcN_plusValidZTime` line, so the new corollary's line is appended **last in both**; Phase 5 reads the in-script comment block above `C14_BASELINE` before editing and confirms from C14's expected-vs-actual diff that only the new line differs |
| A hand-typed axiom profile in `docs/theorem-index.md` or in the C14 baseline | H | M | Phase 5 measures with `#print axioms` first and pastes the measured output second. The research-measured value is `pcq`; that figure is carried, not authoritative, and Phase 5 re-measures rather than trusting it |
| `stg_step`'s or `omega_chain`'s measured axiom profile moves under the restored signature, breaking an existing pinned C14 row | M | L | Research measured both post-restoration: `[propext, Quot.sound]` for `stg_step` and `[propext, Classical.choice, Quot.sound]` for `omega_chain` — the values already in the baseline, so no existing row should move. An existing row moving is a HARD STOP at Phase 5, not a new baseline |
| Concurrent sibling 867 has **undeclared** `file_scope` and may touch `docs/theorem-index.md` or `scripts/check-module-invariants.sh`; sibling 884's declared scope includes `specs/**`, `TODO.md` and `state.json` | M | M | Re-read both shared files immediately before editing them in Phase 5; stage only this task's own hunks with an explicit file list, never a directory or glob add; never run `git-snapshot.sh` in its reverting default mode; treat a build failure outside this task's own file scope as possibly a sibling's in-flight edit; on observing a foreign commit, a foreign uncommitted modification, or a build not started here, STOP and report after checking `git log` |
| The unscoped build is long and collides with a sibling's unguarded `lake` call | M | M | Every `lake` invocation routes through `lake-build-guard.sh` with an explicit `--timeout 1800`, under the bounded-wait idiom in `context/project/lean4/operations/long-builds.md`; an unexplained failure outside this task's modules is checked for guard bypass before being treated as a regression |
| A Lean doc-comment edit is treated as zero-compile-surface and breaks elaboration | M | L | Phases 2 and 3 declare tier `local`, not `prose`, precisely because a Lean `/-! -/` or `/-- -/` comment is parsed syntax with a real compile surface; each is covered by a guarded scoped build of its own module |
| `lean_local_search` reported `index: unavailable` during research, so an empty LSP result is not proof of absence | L | L | Every absence claim this plan relies on (two `LCU` surfaces, one `omega_chain` consumer) rests on grep over the source tree, and each is re-confirmed by its phase's own Scope Hypothesis |
| The generated doc-sync surfaces (`typst/generated/status.typ`, three README inventory blocks) go stale on any `.lean` line-count change and fail their gates at the very end, after every substantive phase has already committed | M | H | Phase 5 regenerates both families explicitly with their own owning commands, and `--emit-inventory --check` plus a full `typst-sync-check.sh` are in its verification set. `typst-sync-check.sh --fix` needs a built library, so it runs AFTER the unscoped build, not before. The research report did not cover this surface at all — it is derived here from the harvester's own companion-path augmentation, which is why it is called out rather than assumed |
| A doc-sync surface is hand-edited to make its gate pass | H | L | All four are machine-owned and declared as such in Phase 5's `Files to modify`; the only sanctioned writers are `typst-sync-check.sh --fix` and `check-module-invariants.sh --emit-inventory`. A hand-edit passes the diff and reappears on the next regeneration |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 2, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Restore the full-fidelity `stg_step` / `omega_chain` signatures and adapt the one call site [COMPLETED]

**Goal**: Land the segment-property parameter `P`, its stability hypothesis `hP`, the strengthened
continuation hypothesis, and the three restored `omega_chain` conclusions, with
`lcN_plusValidInt`'s single call site adapted in the same atomic batch so `PlusLanguage` is never
left red at a commit boundary.

**Tasks**:
- [ ] Re-read `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` lines 649-702 (the
      probe's `Stg`, `stg_step` and `omega_chain`) and
      `FormalSystem/PlusLanguage/PlusOmegaChain.lean` lines 255-333 (the landed `Stg`, `stg_step`
      and `omega_chain`) side by side. The probe is the fidelity authority; the library's binder
      ORDER and its `WorldHistory`/`.state` vocabulary are the shape authority.
- [ ] Confirm by grep that `PlusLanguage.omega_chain` still has exactly one consumer under
      `FormalSystem/` and `Tests/` (`lcN_plusValidInt` in `PlusLCSchema.lean`), and that
      `stg_step` and `Stg` still have no consumer outside `PlusOmegaChain.lean` itself. The
      `omega_chain_c0` / `omega_chain_dom_mono` / `omega_chain_f_agrees` family in
      `Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` is a DIFFERENT namespace and a
      different construction — do not touch it.
- [ ] Add the `P : ℕ → WorldHistory F → F.Duration → F.Duration → Prop` parameter to `stg_step`
      and `omega_chain`. `P` takes a `WorldHistory`, not a raw state function: the intended `LCU`
      instantiation is stated with `PlusTruthAt`, which wants a history. `A` stays a
      time-and-state predicate — the two parameters face different directions, and the module
      docstring already explains why `A` cannot be history-valued.
- [ ] Add `hP`, the stability hypothesis, with its segment **half-open** as `(s, s']`:
      `∀ i (η η' : WorldHistory F) s s', (∀ z, s < z → z ≤ s' → η'.state z = η.state z) →
      P i η s s' → P i η' s s'`. The half-open form is verbatim from the probe and is what
      `paste_agreeFrom` discharges directly; where the upstream axiomatizability report's prose
      says "`⟐β` on `(s, s')`", the probe wins over the prose.
- [ ] Strengthen `stg_step`'s `H` and `omega_chain`'s `hstep` so the continuation additionally
      satisfies `P k η s s'`, and add `stg_step`'s new conclusion `P i y.hist x.mark y.mark`,
      proved by `hP i η _ x.mark s' (fun z h1 _ => hfrom z h1.le) hP'`.
- [ ] Replace `omega_chain`'s existential `hstart` with the probe's five explicit arguments
      (`ρ₀`, `s₀`, `h0w`, `h0s`, `h0A`) and add the three restored conclusions: `c 0 = s₀`,
      `∀ z, z ≤ s₀ → ρ.state z = ρ₀.state z`, and `∀ k, P k ρ (c k) (c (k + 1))`. Keep the
      already-landed `t ≤ c k` conjunct — restoring fidelity must not drop what is already there.
- [ ] Adapt `lcN_plusValidInt`'s single call site: pass `P := fun _ _ _ _ => True`, discharge `hP`
      with `fun _ _ _ _ _ _ h => h`, pass the start data as five explicit arguments instead of an
      anonymous constructor, add `trivial` to the `hstep` witness tuple, and ignore the three new
      components in the `obtain` pattern.
- [ ] Confirm zero `sorry` and no vacuous-definition pattern (`:= True`, `:= Unit`, `:= trivial`)
      introduced into either module body. The `P := fun _ _ _ _ => True` instantiation at the call
      site is an ARGUMENT, not a definition body, and is the intended backward-compatible
      instantiation — not an instance of that prohibition.
- [ ] Commit both files together as one atomic batch, with an explicit file list.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: exactly **one** library consumer of `PlusLanguage.omega_chain`
(`lcN_plusValidInt`) and **zero** consumers of `stg_step` / `Stg` outside `PlusOmegaChain.lean`.
This is a figure CARRIED from `specs/871_lcu_omega_chain_record_repair/reports/01_lcu-omega-chain-record-repair.md`
finding 2's call-site inventory, not re-derived at plan-authoring time; confirm it at
implementation time by grepping `FormalSystem/` and `Tests/` for each of the three names and
adapting however many call sites are actually found, rather than however many this line predicts.
Separately, every Lean signature in `## Lean Challenge Statements` below is transcribed from that
same report's prose (its probe texts were deliberately not reproduced) — re-elaborate each before
committing.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage`
covers the changed module plus its one enumerated direct dependent (`PlusLCSchema`), which is the
complete call-site set for an arity change confined to this namespace.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusOmegaChain.lean` - `stg_step` and `omega_chain` gain `P`, `hP`,
  the strengthened continuation hypothesis, and the restored conclusions
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` - `lcN_plusValidInt`'s single `omega_chain` call
  site adapted to the new signature

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusOmegaChain`
  exits 0. Read the guard's own `result` verdict, never a pipe exit code.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusLCSchema`
  exits 0 — this is the enumerated direct dependent, and it is what proves the call-site
  adaptation landed.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage`
  exits 0.
- `grep -n "sorry" FormalSystem/PlusLanguage/PlusOmegaChain.lean FormalSystem/PlusLanguage/PlusLCSchema.lean`
  returns nothing.
- The landed `omega_chain` conclusion contains all three restored clauses; confirm by reading the
  committed signature, not by inference from a green build (a green build does not distinguish the
  full-fidelity variant from the narrow one).

---

### Phase 2: Repair `PlusOmegaChain.lean`'s docstrings to describe the restored signature [COMPLETED]

**Goal**: Bring the module's prose back into agreement with its code, so that `P` and what `hP`
buys are introduced where a reader meets them, and no docstring still describes the `A`-only
signature.

**Tasks**:
- [ ] Update step 4 of the module docstring's `## The argument` section ("**The chain**
      (`omega_chain`)") to say that the splice additionally carries a segment property across the
      paste, and why `hP`'s half-open `(s, s']` reading is what survives it.
- [ ] Update the `## Main Results` bullet for `omega_chain` (and for `stg_step`, whose bullet also
      describes the old conclusion) to mention the segment property and the restored conclusions.
- [ ] Update the `Stg` declaration docstring: it currently records `A` as "a predicate on a time
      and a world state" and says nothing about segments. `A`'s description stays correct as-is;
      add the complementary account of `P` and of why the two parameters have different arities
      and different carriers.
- [ ] Update the `stg_step` and `omega_chain` declaration docstrings to state the new hypotheses
      and conclusions, and to record WHY `P` is carried even though the module's only current
      consumer instantiates it trivially: it is the hook the until-form limit-closure schema's
      semantic core needs, and it was dropped once already as "the probe's unused segment-property
      parameter".
- [ ] Record, at the `omega_chain` declaration site, the probe source range this signature is
      faithful to (`specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean`, the
      `variable` line and `stg_step`/`omega_chain`), so a future port has a fidelity anchor rather
      than a judgement call.
- [ ] Preserve each declaration's existing
      `Paper: — (formalization-native; the manuscript states no limit-closure schema)` line
      verbatim. C15's second assertion requires it on every theorem-index-rowed declaration.
- [ ] Re-read `FormalSystem/PlusLanguage.lean` lines 72-75 and confirm the `PlusOmegaChain`
      pointer ("`omega_chain`, which iterates a `paste` and takes the limit") still describes the
      module honestly. Edit it only if the restored signature makes it misleading; a generic
      pointer that remains true is left alone.
- [ ] Commit with an explicit file list.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: **five** docstring sites in `PlusOmegaChain.lean` (module docstring step 4,
the `## Main Results` bullets, and the `Stg` / `stg_step` / `omega_chain` declaration docstrings),
plus one check-only pointer line in `FormalSystem/PlusLanguage.lean`. This enumeration is CARRIED
from `specs/871_lcu_omega_chain_record_repair/reports/01_lcu-omega-chain-record-repair.md`
finding 4's record-surface list, not re-derived here; confirm it at implementation time by reading
the module top to bottom and repairing every site that still describes the `A`-only signature,
rather than exactly five.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusOmegaChain`
covers the edit — a Lean `/-! -/` or `/-- -/` comment is parsed syntax with a real elaboration
surface, so the single-module build (not the `prose` tier's diff read-through) is the honest
covering check, and no externally visible signature changes in this phase.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusOmegaChain.lean` - module docstring step 4 and `## Main Results`;
  the `Stg`, `stg_step` and `omega_chain` declaration docstrings
- `FormalSystem/PlusLanguage.lean` - check only; edit the `PlusOmegaChain` pointer line (around
  line 72-75) solely if the restored signature makes it misleading

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusOmegaChain`
  exits 0. Read the guard's own `result` verdict.
- `grep -n "unused segment-property\|a predicate on a time and a world state" FormalSystem/PlusLanguage/PlusOmegaChain.lean`
  no longer reports any text describing `omega_chain`'s parameter bundle as `A`-only.
- Each of `Stg`, `stg_step` and `omega_chain` still carries its
  `Paper: — (formalization-native; …)` line, confirmed by grep.
- No change to any declaration signature in this phase: `git diff` for this phase touches comment
  and docstring regions only.

---

### Phase 3: Correct the `LCU` claim in `PlusLCSchema.lean` [COMPLETED]

**Goal**: Replace the false "`LCU` is the `n = 1` instance of `lcN`" claim, on both surfaces in
this module, with prose that states what `LCU` actually is, that neither formula is an instance of
the other, and that `LCU` is not declared anywhere in this tree.

**Tasks**:
- [ ] Rewrite the module docstring's `## \`LCU\`, and the relation to \`blc\`` section. The
      research report's Decisions section carries a draft to use verbatim or amend; it must state
      all four of: `LCU`'s actual formula
      `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))` (two parameters, `untl`); `lcN 1 α`'s
      actual formula `⊡G≤(⟐α₀ → ⟐F⟐α₀) → ⟐G≤(⟐α₀ → F⟐α₀)` (one parameter, `F` only, no `untl`);
      that neither is an instance of the other; and that `PlusOmegaChain.lean`'s `omega_chain`
      carries the segment-property parameter `P` that `LCU`'s semantic core needs, while the
      formula and its validity are NOT stated anywhere in this tree.
- [ ] Leave the section's existing `blc`-relation paragraph intact — it is correct and unrelated:
      `blc` is the `n = 1` limit-closure formula valid at `.Base` by Zorn plus the Extension
      Theorem, `lcN` is the `n ≥ 1` cycling schema valid at `.ZTime` by the ω-chain, and neither
      implies the other.
- [ ] Correct the `lcN` declaration docstring, which currently reads "`LCU` is the `n = 1`
      instance." — the same false claim in one sentence. Point it at the module docstring section
      rather than duplicating the full account.
- [ ] Record, in one sentence, WHY the error is substantive rather than cosmetic: L⁺ has `untl` and
      `snce` as primitives, so a Reynolds-style construction must discharge until-commitments as
      well as `F`-commitments, and the `F`-form schema does not discharge an until-commitment's
      guard. A reader of the module today is told the until-form ingredient is present when it is
      not.
- [ ] Do NOT introduce an `LCU` definition, an `LCU` validity claim, or any declaration reaching
      for one. The corrected prose names `LCU` and states that it is undeclared; that is the whole
      of this phase's content.
- [ ] Commit with an explicit file list.

**Timing**: 0.25 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: exactly **two** surfaces in this module carry the wrong `LCU` claim — the
module docstring's `## \`LCU\`, and the relation to \`blc\`` section and the `lcN` declaration
docstring (the `docs/theorem-index.md` row is the third surface overall and belongs to Phase 5).
This figure is CARRIED from
`specs/871_lcu_omega_chain_record_repair/reports/01_lcu-omega-chain-record-repair.md` finding 1,
not re-derived here; confirm at implementation time with
`grep -rn "LCU" FormalSystem/ docs/ typst/ latex/ research/ README.md` and repair every surface
actually found. The report measured zero `LCU` mentions under `typst/`, `latex/`, `research/` or
any README; if the grep disagrees, the extra surfaces are in scope for this phase.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusLCSchema`
covers the edit — a Lean doc comment has a real elaboration surface, and this phase changes no
signature, so the single-module build is the cheapest honest check.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` - the module docstring's `LCU` section and the
  `lcN` declaration docstring

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusLCSchema`
  exits 0. Read the guard's own `result` verdict.
- `grep -n "n = 1 instance" FormalSystem/PlusLanguage/PlusLCSchema.lean` returns nothing on any
  line mentioning `LCU` (the `blc`-relation paragraph's own correct "`n = 1` limit-closure formula"
  phrasing is about `blc`, not `LCU`, and must survive).
- The corrected prose states `LCU`'s two-parameter `untl` form, `lcN 1`'s one-parameter `F` form,
  the non-instance relation, and that `LCU` is undeclared here — confirmed by reading the hunk.
- `grep -rn "LCU" FormalSystem/` shows no new declaration named `LCU` and no validity claim about
  it.

---

### Phase 4: Add the backward limit-closure corollary [COMPLETED]

**Goal**: State `lcN_reflectTime_plusValidZTime` as the one-line `plusValidIn_reflectTime`
corollary of `lcN_plusValidZTime`, with the mirror reading given in prose rather than expanded in
syntax.

**Tasks**:
- [ ] Add, after `lcN_plusValidZTime` in `PlusLCSchema.lean`:
      `theorem lcN_reflectTime_plusValidZTime (n : ℕ) (hn : 0 < n) (α : ℕ → PlusFormula) :
      PlusValidZTime (lcN n α).reflectTime := plusValidIn_reflectTime (lcN_plusValidZTime n hn α)`.
      Term mode, one line, no tactic block.
- [ ] Confirm the two facts that make the one-liner go through, by reading the live signatures
      rather than trusting this plan: `plusValidIn_reflectTime`
      (`FormalSystem/PlusLanguage/PlusReversal.lean`) is stated at an **arbitrary**
      `ProofSystem.FrameClass` with no closure hypothesis, and `PlusValidZTime φ` is by definition
      `PlusValidIn ProofSystem.FrameClass.ZTime φ`
      (`FormalSystem/PlusLanguage/PlusValidity.lean`).
- [ ] Keep the statement at `(lcN n α).reflectTime`. Do NOT expand the mirror form: it would need
      a new `H≤` definition (the module defines `gle` only, and neither `Formula` nor
      `PlusFormula` carries a reflexive-past closure), a `reflect_time_gle` push-through lemma, and
      a `reflect_time_bigAnd` lemma for the `ℕ`-indexed conjunction — three new declarations to
      state what the one-liner already proves.
- [ ] Write the docstring: give the mirror reading in prose (`reflectTime` fixes `⊡` and exchanges
      `U`/`S`, `F`/`P`, `G`/`H`, so the reflection of `LC_n` is the same cycling schema read
      backwards in time, valid at `.ZTime` because `ℤ` is reflection-symmetric), say why the
      expanded form is deliberately not written, and carry the module's
      `Paper: — (formalization-native; the manuscript states no limit-closure schema)` line. The
      `Paper:` line is required by C15's second assertion for any declaration that gets a
      theorem-index row, which this one does in Phase 5.
- [ ] Add the corollary to the module docstring's `## Main Results` list.
- [ ] Add `FormalSystem.PlusLanguage.PlusReversal` to the module's imports if the build reports it
      missing; check first, since the import graph may already reach it transitively.
- [ ] Confirm zero `sorry` and no vacuous-definition pattern introduced.
- [ ] Commit with an explicit file list.

**Timing**: 0.25 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: one new declaration, one `## Main Results` bullet, and at most one new
import line — and the corollary's axiom profile is `pcq`
(`[propext, Classical.choice, Quot.sound]`). That profile is a figure CARRIED from
`specs/871_lcu_omega_chain_record_repair/reports/01_lcu-omega-chain-record-repair.md` finding 3,
measured there and not re-derived at plan-authoring time; Phase 5 re-measures it with
`#print axioms` and pastes the measured output rather than this carried value. If a new import is
in fact needed, confirm it does not create an upward-import edge by running
`bash scripts/check-metalogic-cycles.sh` in Phase 5.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusLCSchema`
covers the edit — a new theorem added at the end of one module with no existing declaration's
signature changed, so nothing outside this module can break on it.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` - the new `lcN_reflectTime_plusValidZTime`
  corollary, its docstring, the `## Main Results` entry, and an import line if the build needs one

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusLCSchema`
  exits 0. Read the guard's own `result` verdict.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage`
  exits 0.
- The corollary's body is the one-line term `plusValidIn_reflectTime (lcN_plusValidZTime n hn α)`
  and its statement is `PlusValidZTime (lcN n α).reflectTime` — not an expanded mirror form.
- `grep -n "sorry" FormalSystem/PlusLanguage/PlusLCSchema.lean` returns nothing.
- The corollary's docstring carries a `Paper:` line, confirmed by grep.

---

### Phase 5: Record surfaces, axiom baseline, and the complete gate set [COMPLETED WITH EXCLUSIONS]

**Goal**: Close the task: correct the third wrong-`LCU` surface, refresh the two ledger rows whose
Statement cells now misdescribe their declarations, pin the new corollary's **measured** axiom
profile into the C14 baseline pair, and run the repository's complete gate set green.

**Tasks**:
- [ ] Re-read `docs/theorem-index.md` and `scripts/check-module-invariants.sh` immediately before
      editing. Both are plausible shared targets for sibling 867, whose `file_scope` is
      undeclared. On observing a foreign commit or a foreign uncommitted modification in either
      file, STOP and report after checking `git log` — do not proceed and do not dismiss it as
      noise.
- [ ] Correct `docs/theorem-index.md`'s `FormalSystem.PlusLanguage.lcN_plusValidZTime` row: remove
      the "`LCU` is the `n = 1` instance" sentence and replace it with the corrected account, kept
      short enough for a table cell. The row's own `blc` clause ("neither this nor `blc_plusValid`
      subsumes the other") is correct and stays.
- [ ] Refresh the `FormalSystem.PlusLanguage.stg_step` and `FormalSystem.PlusLanguage.omega_chain`
      rows' Statement cells to mention the segment property and, for `omega_chain`, the restored
      conclusions. Both rows' `Axioms` cells need no edit — research measured both profiles as
      unchanged — but confirm that from C14's own output, not from this line.
- [ ] Add one new row for `FormalSystem.PlusLanguage.lcN_reflectTime_plusValidZTime`, following the
      section's existing rows as the pattern: `Paper label` is `—` for formalization-native
      results; `Lean name` is the FULLY QUALIFIED name, always; `File` is a path with no line
      numbers; `Frame class` reads `ZTime`; the `Axioms` cell carries the measured profile plus
      `pinned:C14`.
- [ ] Append `#print axioms FormalSystem.PlusLanguage.lcN_reflectTime_plusValidZTime` to the
      `C14LEAN` probe heredoc, **last**, immediately after the existing
      `lcN_plusValidZTime` line — which is currently the final line of that heredoc. Read the
      in-script comment block above `C14_BASELINE` first ("they must list the same declarations in
      the same order. Edit them together, appending to both").
- [ ] Run the C14 measurement, capture the emitted `'...' depends on axioms: [...]` line verbatim,
      and paste it into `C14_BASELINE` at the **matching last position**. **Measure, then paste.**
      Never type an axiom profile by hand — that is the defect C14 exists to catch. The research
      report's `pcq` is a carried expectation to compare against, never the value to write.
- [ ] Copy the same measured profile into the new `docs/theorem-index.md` row's `Axioms` cell. That
      cell is generated from the baseline, never typed.
- [ ] Refresh the generated doc-sync surfaces that any `.lean` edit drifts. Phases 1-4 change line
      counts in two modules, which is enough to stale all of them:
      - `bash scripts/typst-sync-check.sh --fix` regenerates `typst/generated/status.typ`. It
        NEEDS A BUILT LIBRARY (its write path reads a per-declaration axiom report out of the
        build), so run it after the unscoped build below, not before. It never stages anything —
        stage the regenerated file explicitly. It also reports, read-only, any module-map or
        machine-appendix drift it does not itself repair; neither is expected from this task, and
        either appearing is a signal to stop and read rather than to regenerate blindly.
      - `bash scripts/check-module-invariants.sh --emit-inventory` rewrites the three registered
        generated-inventory blocks that cover `FormalSystem/PlusLanguage`
        (`FormalSystem/PlusLanguage/README.md`, `FormalSystem/README.md`, `README.md`). Then
        `--emit-inventory --check` must exit 0, which is what proves the rewrite is settled.
- [ ] Run the complete gate set below and confirm every gate green against its pre-task baseline.
- [ ] Commit with an explicit file list, never a directory or glob add.

**Timing**: 1 hour

**Depends on**: 2, 4

**Verification Tier**: full

**Scope Hypothesis**: **four** `docs/theorem-index.md` touches (one corrected `lcN_plusValidZTime`
cell, two refreshed Statement cells for `stg_step` and `omega_chain`, one new corollary row) and
**one** matched C14 pair (one `C14LEAN` line plus one `C14_BASELINE` line, both appended last),
with the existing `stg_step` and `omega_chain` baseline rows unchanged. The "profiles unchanged"
half is a figure CARRIED from
`specs/871_lcu_omega_chain_record_repair/reports/01_lcu-omega-chain-record-repair.md` findings 2
and 3; confirm it from C14's own expected-vs-actual diff, which must name ONLY the new line. An
existing row moving is a HARD STOP, not a new baseline. Separately, **four** generated doc-sync
surfaces are expected to drift from Phases 1-4's line-count changes (`typst/generated/status.typ`
plus the three registered README inventory blocks) — this one is NOT carried from the research
report, which did not cover the doc-sync surface at all; it is derived at plan-authoring time from
`plan-file-scope-harvest.sh`'s own companion-path augmentation for this plan. Confirm it by
running each regenerator and observing what it actually rewrites, rather than assuming four.

**Files to modify**:
- `docs/theorem-index.md` - the `lcN_plusValidZTime` row's `LCU` sentence, the `stg_step` and
  `omega_chain` Statement cells, and one new row for the corollary
- `scripts/check-module-invariants.sh` - one new `#print axioms` line in the C14 probe heredoc and
  the matching measured line in `C14_BASELINE`, appended last in both
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`; never
  hand-edited
- `FormalSystem/PlusLanguage/README.md` - generated-inventory block rewritten by
  `check-module-invariants.sh --emit-inventory`; never hand-edited
- `FormalSystem/README.md` - same generated-inventory rewrite (its block covers
  `dir=FormalSystem` with `rows=loose`)
- `README.md` - same generated-inventory rewrite (its block covers `dir=FormalSystem` with
  `rows=totals desc=no`)

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (unscoped, full
  project) exits 0. Read the guard's own `result` verdict, never a pipe exit code. Use the bounded
  wait idiom from `context/project/lean4/operations/long-builds.md`: a foreground call with the
  Bash tool's own `timeout` raised to `600000`, or the detach-plus-bounded-waiter form if it does
  not fit one call.
- `bash scripts/check-module-invariants.sh` exits 0, with C14 reporting "every pinned declaration
  matches its axiom baseline", C15 passing both assertions, and the INV check reporting no stale
  generated-inventory block. If C14 fails, confirm from its expected-vs-actual diff that only the
  new corollary line differs.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 — the regenerated
  README inventory blocks are byte-settled, not merely rewritten once.
- `bash scripts/typst-sync-check.sh` exits 0 (all four checks), confirming
  `typst/generated/status.typ` agrees with a live regeneration and that no backticked span in
  `typst/**` was broken by a renamed or re-signatured declaration. Check the command's exit
  status, not a diff of its stdout.
- `bash scripts/check-metalogic-cycles.sh` exits 0 against its pre-task baseline, with no new
  upward-import edge in assertion B's allowlist.
- `bash scripts/check-evidence-probes.sh` exits 0 — the `specs/evidence/limit-closure-schema/`
  probe is untouched by this task, so its entry must remain `WIRED` and green.
- `grep -rn "sorry" FormalSystem/PlusLanguage/PlusOmegaChain.lean FormalSystem/PlusLanguage/PlusLCSchema.lean`
  returns nothing, and neither module contains a prohibited vacuous-definition pattern
  (`:= True`, `:= Unit`, `:= trivial`) in a declaration body.
- `bash .claude/scripts/verify-deploy.sh` exits 0 for the doc/markdown surface this task touches
  (`docs/theorem-index.md`). Under a dispatch-time `## Batch Gate Deferral`, record in this phase's
  verification notes that the full set was deferred to the batch stage rather than independently
  run; the phase's declared `full` tier in this file is unchanged either way.
- `grep -rn "n = 1 instance" docs/theorem-index.md FormalSystem/PlusLanguage/PlusLCSchema.lean`
  returns nothing on any line mentioning `LCU` — the final check that all three wrong-claim
  surfaces are closed together, so the ledger and the module cannot disagree.
- The new `docs/theorem-index.md` row carries a fully qualified `Lean name`, no line numbers in
  `File`, and an `Axioms` cell whose value was copied from the measured C14 output.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `bash .claude/scripts/verify-deploy.sh` exits 0 for the touched doc surface | Not satisfiable as written, and deferred to the batch stage. Every one of this script's gates lints the deployed `.claude/` tree against `agent-system/extensions/**`; none covers `docs/theorem-index.md` or project-root `scripts/**`, and this task touches no file under either `.claude/**` or `agent-system/**`. Independently, this dispatch's own `<deploy-freshness-context>` reports the deployed tree already STALE for `core`, `lean` and `literature` before this task began, so a run here would fail for reasons this task neither caused nor may fix (hand-patching `.claude/**` is prohibited). The dispatch's `## Batch Gate Deferral` directive applies: the full set runs once for the whole batch | Gate-selection audit: `gate_selected 1..21+` in `.claude/scripts/verify-deploy.sh`, each guarded on `$TARGET/.claude` or `$TARGET/agent-system/extensions`. The doc surface's actual covering checks were run instead and are green: `check-module-invariants.sh` C14/C15/C20/C9D, `--emit-inventory --check`, `typst-sync-check.sh` (all 4), and `.claude/scripts/check-task-references.sh` (0 unexempted occurrences) |
| `bash scripts/check-module-invariants.sh` exits 0 | Exits 1 on **C16** (`env_linter`) alone — one `unusedArguments` finding at `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136` (`mem_cellAt_of_shift_of_hasForwardSlack`, argument 23 `hslk`), not on `scripts/nolints.json`'s baseline. **Pre-existing and out of this task's scope**, not a regression introduced here: the file is clean in the working tree, its last commit (`ea08629d8`, task 850 phase 7) is an ancestor of this task's base `2dee31e7a`, it references none of the four declarations this task changed, and no `.lean` file under `FormalSystem/` is dirty. Reported rather than re-pinned — `--update` would grandfather it, and touching another task's declaration is out of scope | Gate transcript: `PASS INV`, `PASS C14` (both assertions, including "every pinned declaration matches its axiom baseline"), `PASS C15` (both assertions), `PASS C20`, `PASS C21`, `PASS C27`, `PASS C9D`; the single `FAIL` line is C16. The declaration is already named in `specs/ROADMAP.md` and in tasks 761/850 artifacts |

**Verification notes (batch deferral)**: per this dispatch's `## Batch Gate Deferral`, the
complete gate set was **deferred to the batch stage** rather than independently run in full. The
phase's declared `**Verification Tier**: full` above is unchanged. What was run here, scoped to
the files this phase actually touched: the guarded unscoped `lake build` (exit 0, 2957 jobs, 0
`error:`), `check-module-invariants.sh` (every group PASS except the pre-existing C16 above),
`--emit-inventory --check` (exit 0), `typst-sync-check.sh` (exit 0, all four checks),
`check-metalogic-cycles.sh` (exit 0, no new upward edge from Phase 4's `PlusReversal` import),
`check-evidence-probes.sh` (exit 0; `limit-closure-schema/lc-schema-omega-chain` still `WIRED`
and `PASS`), and `.claude/scripts/check-task-references.sh` (exit 0).

**Scope Hypothesis outcome**: four `docs/theorem-index.md` touches landed exactly as predicted
(one corrected `lcN_plusValidZTime` cell, two refreshed Statement cells, one new corollary row),
and the C14 pair matched — one `C14LEAN` line and one `C14_BASELINE` line, both appended last,
with C14 passing on the first run and no existing row moving. The measured corollary profile is
`[propext, Classical.choice, Quot.sound]` (`pcq`), confirming the carried expectation; `stg_step`
(`[propext, Quot.sound]`) and `omega_chain` (`pcq`) re-measured unchanged. The doc-sync half came
in at **three** surfaces, not four: `typst/generated/status.typ` plus two README inventory blocks
(`FormalSystem/PlusLanguage/README.md` and `README.md`). `FormalSystem/README.md` was already
byte-settled and `--emit-inventory` did not rewrite it.

---

## Lean Challenge Statements

The three statements below are declared under a `Challenge` sub-namespace so the module can
`import` `PlusOmegaChain` (for `Stg`) and `PlusLCSchema` (for `lcN`) without colliding with the
live declarations of the same leaf names. Every signature here is a **transcription** from the
research report's prose — the report deliberately did not reproduce its probe texts — so each must
be re-elaborated against the live library before Phase 1 or Phase 4 commits.

```lean
import FormalSystem.PlusLanguage.PlusOmegaChain
import FormalSystem.PlusLanguage.PlusLCSchema
import FormalSystem.PlusLanguage.PlusReversal

namespace FormalSystem.PlusLanguage.Challenge

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage

/--
One splice, carrying a segment property across the paste. `P` reads only the half-open segment
`(s, s']`, which is what `hP` says and what `paste_agreeFrom` discharges.
-/
theorem stg_step {F : TaskFrame} [F.IsRegular] {w : F.WorldState} {t : F.Duration}
    {A : ℕ → F.Duration → F.WorldState → Prop}
    {P : ℕ → WorldHistory F → F.Duration → F.Duration → Prop}
    (hP : ∀ i (η η' : WorldHistory F) s s',
      (∀ z, s < z → z ≤ s' → η'.state z = η.state z) → P i η s s' → P i η' s s')
    (H : ∀ (ρ : WorldHistory F), ρ.state t = w → ∀ k s, t ≤ s → A k s (ρ.state s) →
      ∃ (η : WorldHistory F) (s' : F.Duration), η.state s = ρ.state s ∧ s < s' ∧
        A (k + 1) s' (η.state s') ∧ P k η s s')
    {i : ℕ} (x : Stg F w t A i) :
    ∃ y : Stg F w t A (i + 1), x.mark < y.mark ∧
      (∀ z, z ≤ x.mark → y.hist.state z = x.hist.state z) ∧ P i y.hist x.mark y.mark := sorry

/--
The ω-chain principle at full probe fidelity: the segment-property parameter `P` with its
stability hypothesis `hP`, five explicit start arguments in place of an existential `hstart`, and
the three restored conclusions — `c 0 = s₀`, agreement below `s₀`, and `∀ k, P k ρ (c k) (c (k+1))`.
`c 0 = s₀` is what closes the `[t, c 0)` gap for the until-form schema's consequent.
-/
theorem omega_chain {F : TaskFrame} [F.IsRegular] (σ : WorldHistory F) (t : F.Duration)
    (A : ℕ → F.Duration → F.WorldState → Prop)
    (P : ℕ → WorldHistory F → F.Duration → F.Duration → Prop)
    (hcof : ∀ c : ℕ → F.Duration, (∀ k, c k < c (k + 1)) → ∀ x : F.Duration, ∃ k, x ≤ c k)
    (hP : ∀ i (η η' : WorldHistory F) s s',
      (∀ z, s < z → z ≤ s' → η'.state z = η.state z) → P i η s s' → P i η' s s')
    (ρ₀ : WorldHistory F) (s₀ : F.Duration) (h0w : ρ₀.state t = σ.state t) (h0s : t ≤ s₀)
    (h0A : A 0 s₀ (ρ₀.state s₀))
    (hstep : ∀ (ρ : WorldHistory F), ρ.state t = σ.state t → ∀ k s, t ≤ s → A k s (ρ.state s) →
      ∃ (η : WorldHistory F) (s' : F.Duration), η.state s = ρ.state s ∧ s < s' ∧
        A (k + 1) s' (η.state s') ∧ P k η s s') :
    ∃ (ρ : WorldHistory F) (c : ℕ → F.Duration), ρ.state t = σ.state t ∧
      (∀ z, z ≤ s₀ → ρ.state z = ρ₀.state z) ∧ c 0 = s₀ ∧
      (∀ k, c k < c (k + 1)) ∧ (∀ k, t ≤ c k ∧ A k (c k) (ρ.state (c k))) ∧
      (∀ k, P k ρ (c k) (c (k + 1))) := sorry

/--
The backward limit-closure schema, as the one-line `plusValidIn_reflectTime` corollary of
`lcN_plusValidZTime`. Stated at `(lcN n α).reflectTime`; the mirror form is deliberately not
expanded.
-/
theorem lcN_reflectTime_plusValidZTime (n : ℕ) (hn : 0 < n) (α : ℕ → PlusFormula) :
    PlusValidZTime (lcN n α).reflectTime := sorry

end FormalSystem.PlusLanguage.Challenge
```

The `stg_step` and `omega_chain` binder bundles are plan-time proposals: the probe's own bundle
re-expressed in the library's `WorldHistory`/`.state` vocabulary and in the library's existing
binder ORDER (which differs from the probe's). Per `plan-compliance.md`'s Statement Fidelity
section, an adjustment that makes a statement **weaker** — adding a hypothesis, specialising a
quantifier, or restating a strictly weaker claim under the same name — is a `[BLOCKED]`
escalation, not a permitted edit; correcting a transcription slip upward against the live library
is permitted and expected. `lcN_reflectTime_plusValidZTime`'s signature is fixed: it is the result
of record and research verified it elaborates as written.

## Testing & Validation

- [x] Guarded scoped build green for `FormalSystem.PlusLanguage.PlusOmegaChain`.
- [x] Guarded scoped build green for `FormalSystem.PlusLanguage.PlusLCSchema`.
- [x] Guarded scoped build green for `FormalSystem.PlusLanguage`.
- [x] Guarded unscoped build (`-- build`, no module) green.
- [x] Zero `sorry` in `PlusOmegaChain.lean` and `PlusLCSchema.lean`; zero vacuous definitions.
- [x] The landed `omega_chain` conclusion carries all three restored clauses (`c 0 = s₀`,
      agreement below `s₀`, `∀ k, P k ρ (c k) (c (k + 1))`) — read from the committed signature,
      not inferred from a green build.
- [x] `bash scripts/check-module-invariants.sh` green, with C14 matching the re-measured baseline
      and its diff naming only the new corollary line. *(deviation: altered — C14 passed on the first run with no diff at all; the script's overall exit is 1 on the pre-existing out-of-scope C16 `env_linter` finding alone, see Phase 5's Reasoned Exclusions)*
- [x] `bash scripts/check-module-invariants.sh --emit-inventory --check` green (README inventory
      blocks byte-settled).
- [x] `bash scripts/typst-sync-check.sh` green (all four checks).
- [x] `bash scripts/check-metalogic-cycles.sh` green against its pre-task baseline.
- [x] `bash scripts/check-evidence-probes.sh` green.
- [ ] `bash .claude/scripts/verify-deploy.sh` green for the touched doc surface. *(deviation: skipped — no verify-deploy gate covers `docs/theorem-index.md` or project-root `scripts/**`; this task touches no `.claude/**` or `agent-system/**` file, and the deployed tree was already stale before this task. Deferred to the batch stage per the dispatch's Batch Gate Deferral; see Phase 5's Reasoned Exclusions)*
- [x] No declaration named `LCU` exists anywhere under `FormalSystem/`, and no validity claim is
      made about it — the Non-Goal confirmed mechanically, not assumed.
- [x] All three wrong-`LCU` surfaces closed together: `grep -rn "n = 1 instance"` over
      `docs/theorem-index.md` and `FormalSystem/PlusLanguage/PlusLCSchema.lean` returns nothing on
      a line mentioning `LCU`.

## Artifacts & Outputs

- `specs/871_lcu_omega_chain_record_repair/plans/01_lcu-omega-chain-record-repair.md` (this file)
- `specs/871_lcu_omega_chain_record_repair/summaries/01_lcu-omega-chain-record-repair-summary.md`
  (written at implementation completion)
- `FormalSystem/PlusLanguage/PlusOmegaChain.lean` - restored `stg_step` / `omega_chain` signatures
  and repaired docstrings
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` - adapted call site, corrected `LCU` prose, new
  `lcN_reflectTime_plusValidZTime` corollary
- `docs/theorem-index.md` - corrected `lcN_plusValidZTime` row, refreshed `stg_step` /
  `omega_chain` Statement cells, one new corollary row
- `scripts/check-module-invariants.sh` - one matched C14 baseline pair for the new corollary
- `typst/generated/status.typ`, `FormalSystem/PlusLanguage/README.md`, `FormalSystem/README.md`,
  `README.md` - regenerated doc-sync surfaces (machine-owned; produced by
  `typst-sync-check.sh --fix` and `check-module-invariants.sh --emit-inventory`, never
  hand-edited)

## Rollback/Contingency

- **Phase 1 fails to elaborate the full-fidelity signature** (for example the `Nat.rec` iota
  defeq breaks under the added arguments): fall back to the narrow `P`/`hP`-only variant, which
  research verified compiles independently (probe 2, together with an `omega_chain_pfree`
  deriving the landed `P`-free conclusion from the new one). Record the fallback and its reason in
  the `omega_chain` docstring **by name**, so the `c 0 = s₀` omission is tracked at the
  declaration site rather than rediscovered by a later port, and note that whichever task lands
  the until-form schema inherits it. Do not reach for a `sorry`: this task needs none, and a
  narrower verified signature is strictly better than a wider unverified one.
- **Phase 4's one-liner does not typecheck**: this is a signal that `plusValidIn_reflectTime` or
  `PlusValidZTime` is not shaped as research found it. Re-read both live signatures and report the
  discrepancy; do NOT expand the mirror form as a workaround (three new declarations, explicitly
  out of scope) and do NOT weaken the statement to make it go through.
- **Phase 5's C14 shows an EXISTING baseline row moving**: HARD STOP. That is a real axiom-profile
  regression somewhere in the restored signatures, not a baseline to update. Report it rather than
  re-pinning.
- **Reverting the task**: every phase commits a bounded, explicit file list, so
  `git revert` of the phase commits in reverse order restores the pre-task state. The repair is
  additive-and-corrective with no migration, no data change, and no generated artifact, so no
  further unwind step is needed. If an in-flight working tree must be discarded instead, take a
  durable checkpoint first and follow `context/contracts/recovery.md`'s rollback rung for the
  exact `git-snapshot.sh` invocation shape, including its out-of-scope override flag — never a
  bare reverting `git-snapshot.sh` call as a routine precaution, and never a destructive git
  operation while a concurrent sibling is live in this tree.
