# Research Report: Task #893

**Task**: 893 - Declare the until-form limit-closure schema LCU and its mirror, with ZTime validity
**Started**: 2026-11-09T00:00:00Z
**Completed**: 2026-11-09T00:00:00Z
**Effort**: small
**Dependencies**: None (870, 871, 867 and the `omega_chain` segment-property repair are all landed)
**Sources/Inputs**: - Codebase (`FormalSystem/PlusLanguage/`, `docs/theorem-index.md`, `scripts/check-module-invariants.sh`, `FormalSystem/PlusLanguage/README.md`), lean-lsp MCP (`lean_run_code`, index `consulted`), the L⁺ ZTime completeness programme report (`specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`), Reynolds 2001 §9-§15 as transposed in that report
**Artifacts**: - `specs/893_lcu_until_form_schema_ztime_validity/reports/01_lcu-until-form-ztime-validity.md`
  - `specs/893_lcu_until_form_schema_ztime_validity/probes/01_lcu-ztime-validity.lean` (compiled, sorry-free)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The whole task is already machine-verified end to end.** `lcU`, `lcU_plusValidInt`,
  `lcU_plusValidZTime` and `lcU_reflectTime_plusValidZTime` compile against the built library
  with zero errors and zero sorries, in a single self-contained probe saved at
  `specs/893_lcu_until_form_schema_ztime_validity/probes/01_lcu-ztime-validity.lean`. All four
  declarations carry the tree's standard `pcq` profile `[propext, Classical.choice, Quot.sound]`.
  Implementation is a transcription of that probe plus the documentation and gate surfaces below.
- **One new helper is required, and it is not in the task description.** Closing the consequent's
  `G≤` for the *until*-form needs a **marker bracketing** lemma — for any `s ≥ c 0`, a `k` with
  `c k ≤ s < c (k + 1)` — which does not exist in the tree. `int_marker_exists_gt` (the `F`-form's
  arithmetic) gives a marker *beyond* `s` in a prescribed residue class and cannot serve: the
  until-witness needs the marker pair that *straddles* `s`, because the segment guard is only
  available between consecutive markers. Proposed as
  `FormalSystem.PlusLanguage.int_marker_bracket` in `PlusOmegaChain.lean`'s `ℤ` discharge section;
  verified, `pcq`.
- **The task description's segment property is off by one endpoint, and the correction is
  load-bearing.** The description says `P k η s s' := ⟐β` throughout `(s, s']`. The `untl` clause
  supplies `⟐β` only on the **open** interval `(s, s')` — at `s'` the until-witness carries `⟐α`,
  not `⟐β` — so the half-open reading is **not derivable** from the antecedent. The open reading
  is simultaneously what is provable and what the consequent needs. `omega_chain`'s `hP` agreement
  window is `(s, s']`, a strict superset of the open content window, so `hP` still discharges by
  state-locality of `⟐`. Instantiate `P k η s s' := ∀ r, s < r → r < s' → PlusTruthAt M η r (⟐β)`.
- **The proof is strictly shorter than `lcN`'s, not longer.** Two of `lcN_plusValidInt`'s
  structures disappear: there is no `by_cases` on reachability of an `⟐α`-point (the consequent's
  own `⟐α` guard supplies the start point directly, with `ρ₀ := σ` and `s₀ := t`, so `c 0 = t` and
  the `[t, c 0)` gap is empty), and there is no `bigAnd`/residue-class arithmetic (the recurrence
  family is constant, `A k := ⟐α` for every `k`). The left disjunct `⟐α` of the consequent is
  never used: the until-disjunct discharges every `s`, including `s = c k`.
- **Recommended approach**: a 4-phase plan — (1) `int_marker_bracket` in `PlusOmegaChain.lean`;
  (2) `lcU` + the three validity theorems in `PlusLCSchema.lean`; (3) docstring and README prose
  repair (five surfaces still assert `LCU` is undeclared); (4) `docs/theorem-index.md` rows, the
  C14 baseline pair, and the two generated line-count surfaces. No `sorry`, no new axiom, no
  `[BLOCKED]` risk identified.

## Context & Scope

Researched: how to declare the until-form limit-closure schema `LCU` in
`FormalSystem/PlusLanguage/PlusLCSchema.lean` beside `lcN`, prove its validity over the `ℤ`
fibre and at `.ZTime`, and state the backward schema as the `plusValidIn_reflectTime` corollary;
together with every mechanical surface the change trips.

Constraints taken as binding:

- **Zero debt.** No `sorry`, no new axiom, no vacuous placeholder. Satisfied: the proof is complete.
- **No completeness claim.** Nothing in the implementation may assert that `lcU` is derivable in
  TM⁺, that TM⁺ + `IsLCUAxiom` is complete, or that `lcU` follows from `lcN`. Those are open
  questions owned elsewhere; the deliverable is a *semantic* validity and nothing more.
- **`.Base` validity stays unclaimed.** `lcU`'s route runs through `omega_chain`, whose cofinality
  hypothesis has exactly one discharge in the tree (`intOrder_omega_cofinal`, over `ℤ` alone). The
  obstruction is identical in kind to `lcN`'s and must be recorded the same way.
- **No record-versioning language** in the Lean docstrings or READMEs: state the current design,
  never "previously undeclared" / "no longer open".

Out of scope: `IsLCUAxiom`, `ExtDerivation`, the extended proof system, and every ingredient of
the completeness engine (automata, ban preservation, the cut product). Those are separate tasks.

## Literature Proof Structure

**Source**: M. Reynolds, *An Axiomatization of Full Computation Tree Logic* (2001), §9-§15,
Lemma 17 — consumed here **indirectly**, through its transposition recorded in
`specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
§2.3 and finding 2.3. The paper itself was not re-read this session; the 879 report is the
settled record of the transposition and is treated as the literature interface.
**Strategy**: iterate a one-step until-commitment into an infinite one, by splicing.

### Step Map

1. Reynolds derives `⊢ Eα → EX((Eβ) U (Eα))` for the ban-preservation `α`, `β` — [Reynolds 2001]
   Lemma 17, step 1.
2. He generalises it to `⊢ AG(Eα → EX((Eβ) U (Eα)))` — [Reynolds 2001] Lemma 17, step 2.
3. He applies the limit-closure axiom to get `⊢ Eα → EG((Eβ) U (Eα))` — [Reynolds 2001] Lemma 17,
   step 3. **This is the only consumer of limit closure in the whole engine.**
4. The transposition to L⁺ reads `E` as `⟐`, `AG` as `⊡G≤`, and keeps `U` primitive:
   `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))` — [879 report] §2.3.
5. The *semantic* content of step 3 is the ω-chain of splices: `omega_chain` with the recurrence
   family at the markers and the segment property on the stretches — [879 report] finding 2.3,
   and `PlusOmegaChain.lean`'s own `stg_step` docstring, which names this consumer as the reason
   `P` is carried.

### Dependencies

- Step 4 depends on step 3 (it is its transposition), and fixes the exact formula this task declares.
- Step 5 depends on step 4 only for the formula's shape; its proof is independent of steps 1-3,
  which are *derivability* claims this task does not touch.

### Potential Formalization Challenges

- **Step 3/5**: the guard `⟐β` must hold on *every* stretch between consecutive markers, and the
  `untl` clause delivers it only on open intervals. This is the one place the transposition is not
  a transcription, and it is the origin of the endpoint correction in the Findings below.
- **Step 4**: the consequent's antecedent `⟐α` sits *outside* the `⟐`, unlike `lcN`'s, which is why
  `lcN` is not an instance of `lcU` in either direction. The Lean statement must keep that shape.

## Findings

### Codebase Patterns

- **`lcU`'s exact Lean form is already on the record.** The 879 report §1 carries it verbatim and
  reports it elaborating inside `probes/01_target-statements.lean`:
  `(stab (gle ((dstab α).imp (dstab (untl (dstab β) (dstab α)))))).imp ((dstab α).imp (dstab (gle ((dstab α).or (untl (dstab β) (dstab α))))))`.
  This is identical to the task description's formula and to the probe verified this session. No
  design freedom remains on the statement.
- **`PlusFormula.gle` is defined in `PlusLCSchema.lean`** (`φ.and φ.allFuture`), not in
  `Formula.lean`, so `lcU` must be declared in `PlusLCSchema.lean` after `gle` — exactly where the
  task places it.
- **`omega_chain`'s binder bundle is the intended fit.** Its `A : ℕ → F.Duration → F.WorldState →
  Prop` is state-valued (which `⟐` makes it) and its `P : ℕ → WorldHistory F → F.Duration →
  F.Duration → Prop` is history-valued, carried across the paste by `hP`. The eight-component
  conclusion supplies everything the until-form needs: `c 0 = s₀`, strict increase, `t ≤ c k ∧ A k
  (c k) (ρ.state (c k))`, and `P k ρ (c k) (c (k + 1))` on every consecutive pair.
- **`dstab` state-locality is what discharges `hP`.** `PlusTruth.dstab_iff` reads `⟐φ` at `(τ, r)`
  as `∃ κ, τ.state r = κ.state r ∧ …`, so an agreement `η'.state r = η.state r` transports it by
  `Eq.trans` — three lines inline, no helper lemma needed (`stab_state_only` exists in
  `PlusTruth.lean` but is not the convenient shape here).
- **`lcN_plusValidInt` is the structural template**, down to `hante ρ he.symm` / `rw [gle_iff]`
  for unpacking `⊡G≤`, and to applying `ℤ`-stated marker arithmetic to `c : ℕ → F.Duration` by
  defeq at the application site (`int_marker_exists_gt`'s docstring records why the arithmetic is
  stated at `ℤ`: `omega` does not see through `↑intOrder = ℤ`). The same transport works for the
  new bracket lemma, verified.
- **Five surfaces currently assert that `LCU` is undeclared** and must be repaired in the same
  change:
  1. `FormalSystem/PlusLanguage/PlusLCSchema.lean` module docstring — the `## LCU, and the relation
     to blc` section ("**`LCU` itself is not declared anywhere in this tree**: there is no `LCU`
     definition, and no claim whatsoever about its validity at any frame class. It waits on the
     oriented-forest `Saturation` lemma and on separation over `ℤ`.") plus the `## Main
     Definitions` / `## Main Results` lists.
  2. `FormalSystem/PlusLanguage/PlusLCSchema.lean`'s `lcN` docstring ("`LCU` is not declared in
     this tree").
  3. `FormalSystem/PlusLanguage/PlusOmegaChain.lean`'s `stg_step` docstring ("Every current
     consumer in this tree instantiates it trivially (`PlusLCSchema.lean`'s `lcN_plusValidInt`
     passes `fun _ _ _ _ => True`)") — now false, and the "**Why `P` is carried at all**"
     paragraph should name its realised consumer.
  4. `docs/theorem-index.md` line 502 (the `lcN_plusValidZTime` row): "The until-form `LCU` … is
     not declared in this tree".
  5. `FormalSystem/PlusLanguage/README.md` line 41 (the `PlusLCSchema.lean` inventory
     description): same claim, plus the declaration list.
  The genuinely substantive distinctions in surfaces 1, 2, 4 and 5 — that `lcU` is **not** an
  instance of `lcN` and `lcN 1` is **not** `lcU`, that neither subsumes the other, and that
  `.Base` validity is open for both — are all still true and must be **kept**, stated on their own
  merits.

### External Resources

- No Mathlib search was needed beyond `Nat.find` / `Nat.find_spec` / `Nat.find_min`, all used in
  the verified bracket lemma. No new Mathlib dependency, no new import: `PlusLCSchema.lean`
  already imports `PlusOmegaChain` and `PlusReversal`, which is everything the three validity
  theorems consume (`omega_chain`, `intOrder_omega_cofinal`, `plusValidZTime_iff_plusValidInt`,
  `plusValidIn_reflectTime`).
- lean-lsp evidence tier: **LSP-backed**. The dispatch reported the server registered and
  reachable, and `lean_run_code` elaborated the full probe against the built `.olean` tree, so the
  compile result is a positive machine finding, not a degraded-index inference.

### The verified construction, in detail

Instantiation of `omega_chain (F := F.toTaskFrame) σ t A P hcof hP ρ₀ s₀ h0w h0s h0A hstep`:

| Slot | Instantiation | Discharge |
|------|---------------|-----------|
| `A` | `fun _ s v => ∃ η, v = η.state s ∧ PlusTruthAt M η s α` (constant in `k`) | this *is* `⟐α` read at a time and a state, by `dstab_iff` |
| `P` | `fun _ η s s' => ∀ r, s < r → r < s' → PlusTruthAt M η r (⟐β)` — **open** `(s, s')` | exactly the `untl` clause's guard conjunct |
| `hcof` | `fun c hc x => intOrder_omega_cofinal c hc x` | the `ℤ`-only discharge; this is what fixes the frame class |
| `hP` | three lines through `dstab_iff` + `Eq.trans` | `⟐` is state-local; the `(s, s']` agreement window covers the open content window |
| `ρ₀`, `s₀` | `σ`, `t` | so `c 0 = t`, and the `[t, c 0)` coverage gap is empty |
| `h0w`, `h0s` | `rfl`, `le_rfl` | — |
| `h0A` | `(dstab_iff M σ t α).1 hα` | the consequent's own `⟐α` guard, used directly |
| `hstep` | unpack `hA` → `dstab_iff` → `untl_iff` | the antecedent `⊡G≤(⟐α → ⟐(⟐β U ⟐α))` is *precisely* the splice hypothesis |

Closing the consequent, for an arbitrary `s ≥ t`: `int_marker_bracket hcl (c 0 = t ≤ s)` gives `k`
with `c k ≤ s < c (k + 1)`; take the `untl` witness `s' := c (k + 1)`, whose `⟐α` comes from
`(hcA (k + 1)).2` and whose guard on `(s, c (k + 1))` comes from `hcP k` composed with
`c k ≤ s`. The left disjunct `⟐α` is never taken.

### Recommendations

A sorry-free path exists and is verified. Recommended 4-phase decomposition:

**Phase 1 — `int_marker_bracket` in `FormalSystem/PlusLanguage/PlusOmegaChain.lean`.** Insert in
the `/-! ## The ℤ discharge of the cofinality hypothesis -/` section, after
`int_marker_exists_gt`. Statement (verified):

```lean
theorem int_marker_bracket {c : ℕ → ℤ} (hc : ∀ k, c k < c (k + 1)) {s : ℤ} (h0 : c 0 ≤ s) :
    ∃ k, c k ≤ s ∧ s < c (k + 1)
```

Needs a `Paper: — (formalization-native; …)` line (C15) and an entry in the module docstring's
`## Main Results` list. Update `stg_step`'s docstring in the same phase (surface 3 above).

**Phase 2 — `lcU` and the three validity theorems in `FormalSystem/PlusLanguage/PlusLCSchema.lean`.**
Transcribe the probe. Declaration order: `lcU` in the `/-! ## The schema -/` section after `lcN`;
`lcU_plusValidInt`, `lcU_plusValidZTime`, `lcU_reflectTime_plusValidZTime` in the
`/-! ## Validity at the ℤ fibre, and at .ZTime -/` section after the `lcN` trio. Each needs its own
`Paper:` line. Mirror `lcN`'s docstring discipline: state what is claimed (`.ZTime` / the `ℤ`
fibre), state that `.Base` is open and unclaimed with the cofinality obstruction named, and state
that **no derivability or completeness claim is made** — neither that `lcU` is a TM⁺ theorem nor
that it follows from `lcN`.

**Phase 3 — prose repair.** Surfaces 1, 2, 4, 5 from the Codebase Patterns list. Keep every
still-true distinction; delete only the undeclared-ness assertions, and write the replacement in
the present tense with no reference to what the text used to say.

**Phase 4 — index, pins, generated surfaces.** Four `docs/theorem-index.md` rows
(`int_marker_bracket`, `lcU_plusValidInt`, `lcU_plusValidZTime`,
`lcU_reflectTime_plusValidZTime`), each with an `Axioms` cell of `pcq pinned:C14`; four matched
additions to **both** halves of `scripts/check-module-invariants.sh`'s C14 baseline pair (the
`#print axioms` line in the `C14LEAN` heredoc and the exact-string
`'…' depends on axioms: [propext, Classical.choice, Quot.sound]` line in `C14BASE`, in the same
order, at the tail of the `PlusLanguage` block); then regenerate the two generated line-count
surfaces.

## Decisions

- **`P` is instantiated on the open interval `(s, s')`, not the half-open `(s, s']` the task
  description names.** Reason: the `untl` clause's guard conjunct is `∀ r, t < r → r < s → …`,
  open; at `s'` the witness carries the *event* `⟐α`. Nothing is lost — the consequent only ever
  reads the guard strictly between two markers. `omega_chain`'s `hP` agreement window stays
  `(s, s']` as written; no change to `PlusOmegaChain.lean`'s `stg_step`/`omega_chain` signatures is
  needed or proposed.
- **`A` is constant in `k`.** The task description says `A k := ⟐α`, and that is correct: unlike
  `lcN`, there is no index cycling, so no `bigAnd`, no `% n`, and no `int_marker_exists_gt`.
- **`ρ₀ := σ` and `s₀ := t`.** Taking the start history to be the evaluation history itself (rather
  than the `⟐α`-witness) makes `c 0 = t` and removes the `[t, c 0)` gap outright, so the
  agreement-below-`s₀` conclusion of `omega_chain` goes unused. This is why no `by_cases` on
  reachability is needed.
- **`int_marker_bracket` lives in `PlusOmegaChain.lean`, not `PlusLCSchema.lean`.** It is `ℤ`
  marker arithmetic, its three siblings (`int_marker_add_le`, `intOrder_omega_cofinal`,
  `int_marker_exists_gt`) all live there and all carry `docs/theorem-index.md` rows, and it is
  stated at `ℤ` for the same `omega`-does-not-see-through-`↑intOrder` reason recorded in
  `int_marker_exists_gt`'s docstring.
- **No new module.** Nothing is added to `FormalSystem/`'s file set, so
  `lake exe mk_all --lib FormalSystem` (C33) and the `FAIL INV` file-set staleness path are both
  out of scope. Line counts change, which is a different surface (see Risks).

## Risks & Mitigations

- **Risk: the pre-commit hook blocks Phase 1's and Phase 2's commits.** Both phases change `.lean`
  line counts, and `.githooks/pre-commit` runs `scripts/typst-sync-check.sh --counts-only`, which
  **blocks** on a stale `typst/generated/status.typ` `formalsystem-line-count` (currently
  `394424`). *Mitigation*: every phase that touches a `.lean` file carries
  `typst/generated/status.typ` in its own file scope and runs
  `lake build && bash scripts/typst-sync-check.sh --fix` before committing — in that phase, not
  deferred to Phase 4. This is Condition 1 of
  `.claude/context/project/lean4/patterns/plan-authoring-gate-collisions.md`, surface (b).
- **Risk: the module-inventory blocks go stale.** `FormalSystem/PlusLanguage/README.md`'s
  `<!-- BEGIN GENERATED: inventory dir=FormalSystem/PlusLanguage -->` table carries per-file line
  counts (`PlusLCSchema.lean` 338, `PlusOmegaChain.lean` 404) and `README.md` carries the totals
  block. *Mitigation*: `bash scripts/check-module-invariants.sh --emit-inventory` in Phase 4,
  verified with `--emit-inventory --check`. **Note the ordering constraint**: the generator
  *preserves* the hand-written Description cell and refreshes only the numbers, so Phase 3's prose
  edit to the `PlusLCSchema.lean` description must be made by hand and survives the regeneration —
  it must not be deferred to the generator.
- **Risk: C14 fails as a HARD STOP.** The C14 check compares its two heredocs by exact string
  equality and treats divergence as "a HARD STOP, not a new baseline". *Mitigation*: add the four
  `#print axioms` lines and the four baseline lines in the **same order**, with the profile text
  copied from the probe's own output (`[propext, Classical.choice, Quot.sound]` for all four), and
  run `bash scripts/check-module-invariants.sh` to confirm.
- **Risk: C15 fails on the whole batch at once.** Every `docs/theorem-index.md` row needs a
  `Paper:` line in the declaration's own doc comment. *Mitigation*: all four new declarations get
  `Paper: — (formalization-native; the manuscript states no limit-closure schema)`, matching the
  `lcN` family.
- **Risk: a verification criterion written as a repo-wide absolute zero.** Several gates here are
  baseline-relative (`C16`/`nolints.json`, `C20_DECL`). *Mitigation*: per Condition 4 of the
  gate-collisions checklist, phase criteria must be scoped to the touched files or stated as a
  delta against the pre-task commit, never as an absolute repo-wide zero or exit 0.
- **Non-risk, checked**: `longFile` (both files stay far under 1500 after the additions — ~450 and
  ~445), C26 (`lcU` is the only new `def` and has no underscore; `theorem` names are exempt), C5
  (no new name resembles a module path), and `check-metalogic-cycles.sh` assertion B (no new import
  is added at all, let alone an upward one).
- **Scope discipline**: the implementation must not drift into `IsLCUAxiom`, `ExtDerivation`, or
  any derivability statement. The task says "No completeness claim", and the docstrings are the
  place that boundary is most likely to be crossed by accident.

## Tactic Survey Results

The survey was run as a whole-proof compile rather than per-goal tactic probing, because the
construction is a single `omega_chain` instantiation whose every slot was discharged on the first
or second attempt. Results of record, from `lean_run_code`:

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| whole of `lcU_plusValidInt` | `classical` + `intro`/`obtain`/`refine` through `omega_chain` | success | `gle_iff`, `dstab_iff`, `untl_iff`, `or_iff`, `omega_chain`, `intOrder_omega_cofinal`, `int_marker_bracket` |
| `hP` (segment-property stability) | `obtain … := (dstab_iff …).1 …; exact (dstab_iff …).2 ⟨κ, (hag …).trans hκ, hval⟩` | success | `dstab_iff`, `Eq.trans` |
| `hstep` (one splice) | `rw [dstab_iff]; rw [untl_iff]; obtain; exact` | success | `dstab_iff`, `untl_iff` |
| `∃ m, s < c m` (inside the bracket lemma) | `obtain … := intOrder_omega_cofinal …; exact ⟨m, by omega⟩` | success | `intOrder_omega_cofinal`, `omega` |
| `c k ≤ s` (inside the bracket lemma) | `have := Nat.find_min hex (m := k) (by omega); omega` | success | `Nat.find_min`, `omega` |
| `s < c (k + 1)` via `Nat.exists_eq_succ_of_ne_zero` | `rw [← hk]; exact hm` | **fail** | rewrite pattern was `k.succ`, target `k + 1` |
| `s < c (k + 1)` via `obtain ⟨k, hk⟩ : ∃ k, Nat.find hex = k + 1 := ⟨Nat.find hex - 1, by omega⟩` | `rw [← hk]; exact hm` | success | the `+ 1` spelling makes the rewrite pattern match syntactically |

The one failure is recorded because it is the single defect found across the whole construction,
and its remedy (spell the predecessor obligation as `∃ k, … = k + 1` rather than going through
`Nat.exists_eq_succ_of_ne_zero`) is already baked into the saved probe.

## Context Extension Recommendations

- **Topic**: `omega_chain`'s two-family binder bundle as a reusable instantiation recipe.
- **Gap**: `PlusOmegaChain.lean`'s docstrings explain *why* `A` is state-valued and `P` is
  history-valued, but nothing records the **interval-endpoint discipline** a consumer must observe
  — that `P`'s content window must be strictly inside the `(s, s']` agreement window `hP` offers,
  and that an `untl`-sourced guard is therefore open on the right. This is precisely the point the
  task description got wrong, which makes it a documentation gap rather than a one-off slip.
- **Recommendation**: add the recipe (the eight-slot instantiation table in this report's
  "The verified construction, in detail" section, generalised) to
  `.claude/context/project/lean4/patterns/` — or, better, as a short `### Instantiating omega_chain`
  subsection of `PlusOmegaChain.lean`'s own module docstring, where a future consumer will
  actually read it.

## Appendix

### Searches and probes used

- `lean_run_code` ×3: (a) full construction, one error (`Nat.succ` rewrite); (b) bracket lemma in
  isolation, clean, `pcq`; (c) full construction with the fix, **clean**, all four declarations
  `pcq`. Probe (c) is saved verbatim at
  `specs/893_lcu_until_form_schema_ztime_validity/probes/01_lcu-ztime-validity.lean`.
- `grep` sweeps: `LCU` across `--include=*.lean --include=*.md` (five live deliverable surfaces,
  listed above); `C14` in `scripts/check-module-invariants.sh` (baseline pair located at the
  `C14BASE` / `C14LEAN` heredocs); `lcN|omega_chain|PlusLCSchema` in `docs/theorem-index.md` (rows
  491-503) and in the READMEs.
- No rate-limited search tool was needed or called, so no fallback table was exercised.

### Files read

- `FormalSystem/PlusLanguage/PlusLCSchema.lean` (full), `PlusOmegaChain.lean` (full),
  `Formula.lean` (lines 1-300), `PlusTruth.lean` (lines 80-200), `PlusIntTransfer.lean`
  (lines 155-200), `PlusReversal.lean` (lines 178-220).
- `docs/theorem-index.md` (lines 18-27, 490-503), `FormalSystem/PlusLanguage/README.md`
  (lines 30-46, 130-135), `scripts/check-module-invariants.sh` (C14 heredoc pair, the
  `--emit-inventory` generator, the `ENFORCE_*` header), `.githooks/pre-commit`,
  `typst/generated/status.typ` (the `formalsystem-line-count` line).
- `.claude/context/project/lean4/patterns/plan-authoring-gate-collisions.md` (full).
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
  (lines 78-180).

### References

- M. Reynolds, *An Axiomatization of Full Computation Tree Logic* (2001), §9-§15, Lemma 17 — via
  the 879 report's transposition, not re-read this session.
- M. Reynolds, *An Axiomatization of PCTL\** (2003) — the source of the `F`-form schema `lcN`
  transposes; cited in `PlusLCSchema.lean` as `[reynolds2003]`.
- `specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` — the compiled probe
  `PlusOmegaChain.lean` names as its fidelity anchor for `stg_step`/`omega_chain`'s signatures.
