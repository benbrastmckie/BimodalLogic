# Implementation Plan: Task #775

- **Task**: 775 - Residue-carrying cell index: attempt the factorization lemma over `ladderIndexRes T P B`, or settle it negatively
- **Status**: [IMPLEMENTING]
- **Effort**: 9 hours
- **Dependencies**: None (parent record 773 is `[COMPLETED]`; record 761 depends on this task and is `[BLOCKED]` on it)
- **Research Inputs**: specs/775_residue_index_factorization_lemma/reports/01_derivation-from-conclusion-stage.md
- **Artifacts**: plans/01_residue-index-parameter-refutation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The candidate as scoped — the six-coordinate index
`ladderIndexRes T P B = (q, min c T, c % (P+1), min n T, n % (P+1), clip (n - c) [-B, B])` with
its threshold `T` and period `P` **exhibited from the object** by `reachN_eventually_periodic`
and only the clip bound `B` from the formula — is predicted REFUTED at BOTH object-derived
parameters, uniformly in `B`, by two mechanisms the three existing gates never probed. Neither
mechanism needs the second region, the idle drift freedom the task description names as the
reason there is "no achievable window": both sit entirely inside the FIRST region, where the
countdown is deterministic.

**Mechanism (4) — the threshold cannot be object-derived.** `PlusTruthAt`'s `untl` clause is
strict (`∃ s, t < s ∧ … ∧ ∀ r, t < r → r < s → …`), so over `ℤ`-time `⊥ U χ` is exactly "`χ` at
the next instant", and a chain of `T + 1` nested nexts ending in the idle letter reads whether the
region's first idle state sits at distance EXACTLY `T + 1`. `Count true true` forces that state to
distance `c + 1` for every history, so for EVERY `(T, P, B)` the pair `(q, T, n)` against
`(q, T + (P+1), n)` with `n := T + (P+1) + B` collides in the index (both countdowns saturate the
threshold, both residues agree, `n` is shared, both gaps clip to `2B`) while the cells differ for
the depth-`(T+1)` formula. This fires on the fourteenth probe's own two-state fixture with no new
object. The consequence is the opposite of the parameter-origin rule as recorded: the threshold
must be at least the formula's `untl`-nesting depth — formula-derived, like `B`.

**Mechanism (5) — the exhibited period is the period of the wrong object.** `reachStep` iterates
the full `step` relation, so the exhibited `P` is the period of the SET-iteration on the whole
graph. But a formula can forbid a letter, and a forbidden letter restricts the object to a
sub-object whose pending cycle structure has a different period. On the object whose pending part
is a 3-cycle `a → b → c → a` and a 2-cycle `a → d → a` sharing `a`, the reach sets become
CONSTANT (period `1` from threshold `4`), yet every `d`-free pending walk from `a` back to `a` has
length `≡ 0 (mod 3)`: the type containing `p U (r ∧ ℓ_a)` and lacking `⊤ U ℓ_d` is realized at
`(a, c, n)` for `3 ∣ c` and at no state `(a, c', n)` with `3 ∤ c'`. For every modulus `P + 1`
coprime to `3` — which covers BOTH readings of "period 1" under the unrecorded `P` versus `P + 1`
instantiation convention — the index collides on such a pair at every `T` and every `B`.

A negative result is a successful outcome, on the same terms as the predecessor's. This plan is
falsify-first: Phases 1–2 land the two mechanisms as pinned theorems in a fifteenth wired
evidence probe; Phase 3 is a bounded, non-pinned ATTEMPT at the only positive statement the
analysis supports — sufficiency on the deterministic two-state fixture, where every history
through a pending state shares one object path, at a formula-derived threshold and parity —
with both outcomes pre-specified; Phases 4–6 wire the probe and amend the in-tree records and the
source-store context note so the parameter-origin rule stops saying the opposite of what is now
machine-checked; Phase 7 is the full gate. **No general factorization lemma is stated, in any
shape**: the form that survives this plan — parameters depending on the object AND the formula
jointly — is recorded as OPEN with its proof obligations named, never sorry'd, never weakened.

### Research Integration

- **The derivation note is a provenance record, not a sufficiency argument** — this plan re-derives
  rather than carries. What it carries, and where each item lands: the three settled negatives
  (gap coordinate; countdown parity; bounded carrier) are untouched and cited only; the OPEN
  candidate's exact body (`ladderIndexRes`, probe lines 608–615) is ported byte-for-byte into the
  Challenge block so the refutation is of THAT index; the exhibited-parameter theorems
  (`iterate_eventually_periodic`, `reachN_eventually_periodic`, probe lines 720–757) fix what
  "exhibited" means — an `∃ T P, 1 ≤ P ∧ ∀ k ≥ T, (reachStep step)^[k + P] S = (reachStep step)^[k] S`
  over the FULL step relation — which is exactly the reading mechanism (5) attacks.
- **The known obstruction is respected as a design constraint, not argued around.** The note's
  "no achievable window" finding (`second_region_any_length`, `second_region_sets_agree`) says the
  second region separates nothing. Both new mechanisms therefore sit inside the first region: (4)
  reads the exact distance to the forced first idle state; (5) reads the object path within the
  forced pending run. Neither uses `Drift`; `n` is held equal across every witnessing pair.
- **The parameter-origin rule is the finding under test.** The counter-observables note (source
  store, `ladder-counter-observables.md`, "The parameter-origin rule") records "deriving … the
  threshold and period from the formula is the error this rule exists to prevent". Mechanism (4)
  predicts the threshold MUST be formula-derived; mechanism (5) predicts the reach-set period is
  insufficient. Phase 6 amends that sentence only after Phases 1–2 have measured it.
- **The `P` versus `P + 1` convention is recorded as an ambiguity, not resolved by choice.** The
  index takes residues modulo `P + 1`; the exhibited period satisfies `1 ≤ P`; no record says
  whether the index is instantiated at `P := period` or `P := period − 1`. Every refutation below
  is stated for ALL `P` (mechanism 4) or for every `P` with `¬ 3 ∣ (P + 1)` (mechanism 5), so it
  holds under either reading. Recorded in this task's issue log at plan time (class
  `design-record defect or ambiguity`, severity `minor`).
- **Tactic notes carried from the predecessor's survey**, to port rather than re-derive: `Count`
  case arithmetic after `rw [count_tt]` closes by `omega`; index collisions by
  `simp only [ladderIndexRes, st, Prod.mk.injEq, Fin.mk.injEq, true_and]` then `omega`, EXCEPT
  that `omega` handles `%` only at a LITERAL modulus — residue coordinates at the symbolic modulus
  `P + 1` close by `Nat.add_mod_right` (`(x + z) % z = x % z`), and the product `3 * (P+1) * (T+1)`
  is nonlinear, so generalize it to an atom `C` with `T ≤ C` and `(P + 1) ∣ C` before `omega`;
  opaque `Bool` obligations need `cases <term> <;> simp [stepP]`; the Qp fixture's forced run is
  `pending_run`/`idle_at` (probe lines 310–358), whose countdown half uses only `Count` and is
  generic in the object.

### Prior Plan Reference

No prior plan for this task. The shape precedent is
`specs/773_ladder_cell_index_factorization/plans/01_cell-index-coordinate-obstructions.md`: eight
phases, 9.5 hours estimated, ~1.6 hours actual — but that round had two compiled research oracles
pre-landed at plan time, and this round has none, so its research phases (1–3 here) are costed at
their genuine uncertainty rather than at the predecessor's measured pace. Three lessons carried:
the plan-level `- **Status**:` field is reserved for `update-plan-status.sh` via the postflight and
must NOT be hand-edited by the implementer; a probe file must be `git add`-ed before the evidence
gate runs ("tracked, not merely present"); and an outcome theorem whose statement is not known at
plan time is NOT pinned in the Challenge block (Phase 3 follows this exactly), while a theorem whose
statement IS known is pinned and is then held to its signature (Phases 1–2).

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch, so ROADMAP.md was not consulted, is not edited,
and no roadmap phases are added (the orchestrate conclusion regenerates it).

## Goals & Non-Goals

**Goals**:
(The identifier set equals the eight theorem declarations of the Lean Challenge Statements block
below. Every other backtickable name in this block is deliberately left unbackticked, because the
snapshot tool reads every backticked token here as a Goal.)
- `truth_nextPow` — k nested strict-untl nexts read the formula exactly k instants later: over integer time, bot U chi is chi at the next instant.
- `depth_collision` — for every T, P and B, the two-state fixture's states (q, T, n) and (q, T + (P+1), n) with n = T + (P+1) + B have the same six-coordinate index.
- `cell_depth_ne` — their realized cells differ for the depth-(T+1) next-chain ending in the idle letter: the first idle state sits at distance exactly T + 1 at the first state and strictly later at the second.
- `object_only_parameters_refuted` — hence there is NO triple (T, P, B) under which the index factors the cells of the two-state fixture for every formula: the threshold cannot be formula-independent.
- `reach5_eventually_constant` — on the coprime-cycle fixture the full-graph reach sets from a are constant from threshold 4 on, so period 1 is an exhibited period of this object.
- `period_collision` — for every T, P and B, the states (a, 3(P+1)(T+1), n) and (a, 3(P+1)(T+1) + (P+1), n) with n = 3(P+1)(T+1) + (P+1) + B have the same six-coordinate index.
- `cell5_ne` — whenever 3 does not divide P + 1, their realized cells differ: the type containing p U (r AND l_a) and lacking top U l_d is realized at the first state and at no history through the second, because every d-free pending walk from a to a has length divisible by 3.
- `reach_period_refuted` — hence for every T, every B and every modulus coprime to 3 — in particular both readings of the exhibited period 1 — the index does not factor the coprime-cycle fixture's cells.

**Non-Goals**:
- **No general factorization lemma is stated, in any shape.** Not over object-exhibited parameters
  (refuted here, predicted), not over parameters depending on the object and the formula jointly
  (OPEN — Phase 3's fixture-level attempt is explicitly fixture-level and is not that lemma). No
  sorry, no axiom, no vacuous definition, no hypothesis added to a pinned statement, no same-named
  weaker restatement (`plan-compliance.md`, Statement Fidelity).
- No declaration is added to any module under FormalSystem/: no library module, no LadderRealize,
  no index claimed in the library. The only edit inside FormalSystem/ is the module docstring of
  the admissible-carrier module and the cluster README.
- No seventh coordinate, no wider tuple, no new index candidate. The repaired PARAMETER ORIGIN
  (threshold from the formula, modulus dominating sub-object periods) is recorded as the necessary
  condition the refutations establish, never claimed sufficient.
- No reopening of the three settled negatives (gap, parity, bounded carrier) and no re-run of the
  three existing gates, which already quantify over all T, P, B and are unaffected.
- No upper bound and no complexity bound; every quantity named is a COUNT.
- Nothing about HitPresented; no declaration mentions PlusValidZTime; the cell-set finiteness and
  cardinality results stay untouched; the box/stab acceptance clause is never dropped.
- No edit to ROADMAP.md, to any task's description, or to state.json by hand; no new task spawned
  (the successor decision — a set-valued per-state datum over a quotient, per the records — is the
  user's).
- No task number appears in any file outside specs/ — the evidence-script row, the cluster README,
  the theorem index and the context note cite durable anchors only.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Mechanism (4)'s prediction fails because `⊥ U χ` is not "next" under the landed clause | H | L | The clause was read at plan time (`PlusTruthAt.lean:89–90`, strict in both bounds); `truth_nextPow` is the FIRST declaration of Phase 1, so a failure surfaces before any fixture work; on failure the phase closes `[BLOCKED]` with the goal state recorded, never a restated weaker theorem |
| Mechanism (5)'s prediction fails because some `d`-free walk from `a` to `a` has length `≢ 0 (mod 3)` | H | L | The invariant is the residue of the state index along `d`-free pending steps (`walk_mod3`), checked by `decide` on `step5`'s four pending edges; if it fails the fixture is wrong, not the mechanism, and the phase closes `[BLOCKED]` |
| `decide` on `(reachStep step5)^[4] {a5} = Finset.univ` is slow or fails to reduce `Function.iterate` | M | M | Fall back to four explicit `reachStep` evaluations by `rfl`/`simp [reachStep]` on an 8-element `Fintype`, or state the four intermediate sets as lemmas; `native_decide` is FORBIDDEN (it adds an axiom) |
| The symbolic-modulus residue coordinate and the nonlinear product `3 * (P+1) * (T+1)` defeat `omega` | M | H | Named in the task lists: residues by `Nat.add_mod_right`, the product generalized to an atom with `T ≤ C` and `(P + 1) ∣ C` (`Nat.le_mul_of_pos_left`, `Dvd.intro`) before `omega`; `Nat.dvd_add_right` for `3 ∤ C + (P+1)` |
| Phase 3's attempt is open-ended and consumes the budget | H | M | Hard 2-hour cap, three enumerated sub-steps with a binding stop condition, both branches pre-specified; the phase closes on the enumeration, not on a verdict; nothing it leaves behind may be a `sorry` |
| An implementer reads "attempt the factorization lemma" as licence to state the general lemma with a hypothesis added or a `sorry` body | H | M | The Non-Goals forbid it; the Challenge block contains no positive factorization statement; Phase 3's target is named for the fixture (`qp_…`), carries a BoxStabFree hypothesis and a formula-derived threshold, and its header sentence says it is not the lemma |
| A record amendment re-describes the refuted exhibited-parameter candidate as live, or the context note keeps the sentence the refutation overturns | M | M | Phase 5 greps every touched record for `exhibited` / `reachN_eventually_periodic` / `object-derived` and requires each surviving occurrence to sit in a sentence naming the refutation; Phase 6 rewrites the parameter-origin rule's offending sentence verbatim |
| A record amendment trips C9 (`check-module-invariants.sh` matches `specs/[0-9]{3}_`), the task-reference lint, the README lint, or C14's stale-count tripwire | M | M | Cite only `specs/evidence/...` paths, declaration names and section headings; introduce no axiom or sorry COUNT in any amended markdown; no record-versioning language — state the current fact |
| The source-store path is not resolvable (`.claude-extensions.json` carries no `source_dir`) | M | L | The path `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/` is carried from the predecessor's summary and confirmed by `ls` at plan time; Phase 6 re-confirms and, if absent, follows `context/standards/source-store-deploy-boundary-narrative.md`'s unreachable-source-store fallback rather than writing under `.claude/` |
| The evidence gate run (33 probes) exceeds a foreground tool call | L | M | Run detached with a bounded waiter per `context/patterns/bounded-build-waiter.md` |
| A concurrent unguarded `lake` invocation collides with a guarded build | L | M | Every `lake` call goes through `lake-build-guard.sh`; an unexplained failure during concurrent work is checked against a competing unguarded build before being read as a regression |
| `typst-status-counts.sh` (pre-commit) regenerates `typst/generated/status.typ` | L | M | No library declaration changes, but the predecessor saw an 11-line drift from a docstring edit; if the hook regenerates it, commit it with the phase that triggered it and record the fact |
| `file_scope` drift: the filed scope predates this plan | L | H | `Files to modify` below is the harvest source; the plan-postflight file-scope widening notice will fire — expected, not a defect |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |
| 6 | 7 | 5, 6 |

Phases within the same wave can execute in parallel. Phases 1–3 append sections to ONE probe
file, so Phase 2 depends on Phase 1 and Phase 3 on Phase 2 to serialize the edits (Phase 3's only
logical dependency is Phase 1's generic lemmas). **Phases 1 and 2 are decision gates** with both
branches pre-specified in their bodies; a `[BLOCKED]` Phase 1 or 2 determines WHICH sentence
Phase 4's header carries and never prevents Phase 4 from running — the record is the deliverable
that does not depend on the research outcome. **Phase 3 is a bounded attempt**, non-pinned, whose
deliverable is its measurement record. Phase 7 is the final phase: it depends transitively on
every other phase and re-observes their measurements through the full gate set.

### Phase 1: Mechanism (4) — the Threshold Cannot Be Object-Derived [COMPLETED]

**Goal**: Land, in a new fifteenth evidence probe, the generic forced-run lemmas, the next-chain
truth lemma, and the uniform refutation of every formula-independent `(T, P, B)` on the
fourteenth probe's own two-state fixture.

**Tasks**:
- [x] Create `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` with a
      PROVISIONAL header (Phase 4 writes the final one) stating the two predictions below BEFORE
      the proofs are written, the same imports and `open`s as the fourteenth probe, and
      `namespace Probe775`. Port `ladderIndexRes` BYTE-FOR-BYTE from the fourteenth probe (lines
      608–615) and `reachStep` likewise (lines 743–747); these are the pinned definitional bodies.
- [x] Port fixture A verbatim from the fourteenth probe under its own names: `Qp`, `pendP`,
      `stepP`, `rlad_iff`, `count_tt`/`count_tf`/`count_ff`, `fwdP`, `bwdP`, `F`, the atoms `pA`,
      `rA`, `aA` (and new `dA` with its inequality lemmas), `labP`, `M`, `p`, `r`, `hist_path`,
      `hist_of_path`, the `Along` section with `state_eq`, `truth_p`, `truth_r`, and the `gRef`
      reference-history family with `gRef_isPath` and `gRef_zero` (lines 165–262, 414–478). Keep
      `tagAt` only as far as `gRef` needs it.
- [x] State the two forced-run lemmas GENERICALLY in the object — `pending_run_gen` (for any
      `step`, `pend`, any sliced-step path `g` with `(g 0).1 = (q, c, n)` and `pend q = true`:
      every `i ≤ c` has `pend (g i).1.1 = true` and countdown `c - i`) and `idle_at_gen`
      (`pend (g (c + 1)).1.1 = false`) — by the countdown half of the fourteenth probe's
      `pending_run`/`idle_at` (only `Count` is used). Both fixtures consume these.
- [x] Define `nextPow : ℕ → PlusFormula → PlusFormula` (`nextPow 0 χ = χ`,
      `nextPow (k+1) χ = .untl .bot (nextPow k χ)`) and prove `truth_nextPow` by induction on `k`:
      the strict clause gives `s < s'` with no `r` strictly between, so `s' = s + 1` (`omega` on
      `ℤ`, after `push_cast`); the `∀ r` obligation in the reverse direction is vacuous.
- [x] Define `phiDepth T := nextPow (T + 1) r`, `st`, `xT T P B := st false T (T + (P+1) + B)`,
      `yT T P B := st false (T + (P+1)) (T + (P+1) + B)`. Prove `depth_collision` coordinate by
      coordinate: `simp only [ladderIndexRes, st, Prod.mk.injEq, Fin.mk.injEq, true_and]`, then
      `min_eq_right`/`omega` for the thresholds and the gap, and `Nat.add_mod_right` for the
      countdown residue (`(T + (P + 1)) % (P + 1) = T % (P + 1)`).
- [x] Prove `phiDepth_mem_iff_of_mem_cell` (the analogue of the fourteenth probe's
      `phiP_mem_iff_of_mem_cell`, lines 495–511): for `T' ∈ cellAt M (phiDepth T) (0, st false c n) 0`,
      `phiDepth T ∈ T' ↔ pend (g (T + 1)) = false` along the history's path, via `mem_tpOf_iff`,
      `self_mem_plusSubformulaClosure`, `truth_nextPow`, `truth_r`. Then `cell_depth_ne`: the
      reference history through `xT` realizes a type containing `phiDepth T` (`idle_at_gen` at
      `c = T`); every type in the cell of `yT` lacks it (`pending_run_gen` at `i = T + 1 ≤ T + (P+1)`).
- [x] Prove `object_only_parameters_refuted` from `depth_collision` and `cell_depth_ne` (three
      lines: `rintro ⟨T, P, B, h⟩; exact cell_depth_ne T P B (h _ _ _ (depth_collision T P B))`).
- [x] **Decision gate, both branches pre-specified**:
      - **Branch R (predicted; the four theorems close)**: the header sentence Phase 4 carries is
        "the threshold is not object-derivable: for every (T, P, B) the index collides on a pair the
        depth-(T+1) next-chain separates".
      - **Branch N (a pinned statement does not close)**: mark this phase `[BLOCKED]` per
        `plan-compliance.md`, record the goal state and the clause of `PlusTruthAt` or `Count` that
        blocks it, leave NO declaration with a `sorry` body, and let Phase 4's header carry "mechanism
        (4) was predicted and did not close; the measured reason is …". Never add a hypothesis to a
        pinned statement to make it close.
      **Recorded: Branch R.** All four pinned statements closed on the first guarded compile (zero
      errors, zero warnings). The sentence Phase 4 carries: "the threshold is not object-derivable:
      for every (T, P, B) the index collides on a pair the depth-(T+1) next-chain separates".
      Measured file length after this phase: 423 lines (scope hypothesis 330–420; the 3-line excess is
      the fixture-B letter `dA` with its three inequality lemmas, not the tag machinery).
- [x] Compile through the guard and commit per the green-substep mandate.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The file is ~330–420 lines after this phase (a ~40-line provisional header,
~200 lines of ported fixture A, ~50 lines of generic run lemmas, ~80 lines of mechanism (4)).
Confirm with `wc -l`; a figure above 500 signals the port pulled in the tag machinery
(`tagAt`, `truth_phiP`) this mechanism does not need.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`
exiting 0 is the complete covering check — a file outside the Lake build graph that nothing
imports and that modifies no library module.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` - new fifteenth probe: provisional header, pinned definitional bodies, fixture A, generic run lemmas, mechanism (4)

**Verification**:
- The guarded `lake env lean` exits 0 with zero `error` and zero `warning` lines; no `sorry`, no
  `axiom`, no vacuous-definition pattern (grep count 0).
- The two predictions appear in the header above every declaration, written before the proofs.
- `ladderIndexRes` and `reachStep` are byte-identical to the fourteenth probe's bodies
  (`diff <(sed -n '608,615p' …obstructions.lean) <(…)` whitespace-normalised, zero drift).
- The four Goal signatures match the Challenge block with whitespace normalised.
- Exactly one of Branch R / Branch N is recorded in the phase body.

---

### Phase 2: Mechanism (5) — the Exhibited Period Is the Period of the Wrong Object [COMPLETED]

**Goal**: Land fixture B — two pending cycles of coprime lengths sharing a state — and prove that
period 1 is an exhibited period of its full-graph reach sets while every modulus coprime to 3
collides on a pair whose cells a depth-2 formula separates.

**Tasks**:
- [x] Append fixture B: `Q5 := Bool × Fin 4`, `pend5 := fun q => q.1`, `step5` with pending
      edges `0 → 1`, `0 → 3`, `1 → 2`, `2 → 0`, `3 → 0`, every pending `(true, i) → (false, i)`,
      and idle self-loops `(false, i) → (false, i)` (as in the Challenge block); `rlad5_iff`;
      `fwd5` and `bwd5` by the fourteenth probe's `fwdP`/`bwdP` recipe (pending: successor
      `(true, next i)` while `c > 0`, `(false, i)` at `c = 0`; idle: itself; backward: pending
      predecessor with countdown `c + 1` — `a` from `c` or `d`, `b` from `a`, `c` from `b`, `d`
      from `a` — and idle predecessor itself); `F5`, `lab5` (`pA` pending, `rA` idle, `aA` index 0,
      `dA` pending index 3), `M5`, `la`, `ld`, `endA := .untl p (r.and la)`,
      `evD := .untl (.imp .bot .bot) ld`, `phi5 := .imp endA evD`, `hist_path5`, `hist_of_path5`,
      `truth_p5`/`truth_r5`/`truth_la5`/`truth_ld5`.
- [x] Prove `reach5_eventually_constant`: `reach5_four : (reachStep step5)^[4] {a5} = Finset.univ`
      by `decide` (fallback: four explicit `reachStep` evaluations by `rfl`), and
      `reachStep5_univ : reachStep step5 Finset.univ = Finset.univ` (every state has a successor:
      `Finset.eq_univ_iff_forall` plus the pending successor `(true, next i)` or the idle
      self-loop); then induction on `k ≥ 4`. Record beside it that this EXHIBITS `T = 4`, `P = 1`
      in the shape `reachN_eventually_periodic` returns — and that `P = 1` is the minimal period,
      so the index's modulus under either instantiation reading is `1` or `2`, both coprime to 3.
- [x] Define `cyc : ℤ → Fin 4` (`⟨(i % 3).toNat, _⟩`, `Int.emod_nonneg`, `Int.emod_lt_of_pos`)
      with `cyc_succ` (`cyc (i+1)` follows the 3-cycle `0 → 1 → 2 → 0`, by `omega` on `Int.emod`
      at the literal modulus 3) and `cyc_zero_of_dvd`; the reference history `g5Ref (c n : ℕ)`:
      pending `(true, cyc t)` with countdown `(c - t).toNat` for `t ≤ c`, idle `(false, 0)` after
      (needs `3 ∣ c` so `cyc c = 0`), `n` fixed; `g5Ref_isPath` and `g5Ref_zero` by the
      fourteenth probe's `gRefRaw_step` trichotomy recipe. *(deviation: altered — `g5Ref` idles at `(false, cyc c)` rather than `(false, 0)`, so `g5Ref_isPath` needs no `3 ∣ c`; the divisibility is consumed only by `endA_ref`, where `l_a` is read)*
- [x] Prove `walk_mod3`: along any sliced-step path with `(g 0).1 = ((true, 0), c, n)`, for every
      `i ≤ c` such that no position `1 ≤ j ≤ i` is pending index 3, `(g i).1.1 = (true, cyc i)` —
      induction on `i` using `pending_run_gen` (pending-ness) and `step5`'s `d`-free pending edges
      (`decide` on the four cases after `cases` on the Fin indices).
- [x] Prove `endA_at_zero_iff`: along a history through `((true, 0), c, n)`, `endA` at `0` holds
      iff `(g (c + 1)).1.1 = (false, 0)`: the first idle position is `c + 1` (`pending_run_gen`,
      `idle_at_gen`), `r ∧ la` there forces index 0, and `step5`'s pending-to-idle clause copies
      the index so `(g c).1.1 = (true, 0)`.
- [x] Prove `cell5_ne` under `h3 : ¬ 3 ∣ (P + 1)`: with `C := c5 T P = 3 * (P+1) * (T+1)`,
      `3 ∣ C` and `¬ 3 ∣ C + (P + 1)` (`Nat.dvd_add_right`). The reference history through
      `x5` realizes a type with `endA` and without `evD` (no position carries `ld`: `g5Ref` never
      visits index 3 and `lab5` makes `ld` false at every idle state). For every type in the cell
      of `y5`: `endA ∈ T'` gives `(g (C + (P+1)))` at index 0 by `endA_at_zero_iff`; if no position
      in `[1, C + (P+1)]` were pending index 3, `walk_mod3` would give `cyc (C + (P+1)) = 0`, i.e.
      `3 ∣ C + (P+1)`, contradiction; so some position carries `ld`, hence `evD ∈ T'`
      (`truth_ld5`, the trivial guard `⊥ → ⊥`). Conclude as `cell_succ_ne` does.
- [x] Prove `period_collision` (no `h3` needed) by the Phase 1 recipe with the product generalized
      to an atom `C` carrying `T ≤ C` (`Nat.le_mul_of_pos_left` twice) and `(P + 1) ∣ C`; residues
      by `Nat.add_mod_right`; thresholds and gap by `omega`.
- [x] Prove `reach_period_refuted` from `period_collision` and `cell5_ne` (three lines).
- [x] **Decision gate, both branches pre-specified**:
      - **Branch R (predicted)**: Phase 4's header carries "the exhibited period is the period of
        the reach-SET iteration on the full graph, and a formula that forbids a letter restricts the
        object to a sub-object with a different period; period 1 is exhibited for the coprime-cycle
        object and every modulus coprime to 3 fails".
      - **Branch N**: `[BLOCKED]` per `plan-compliance.md`, goal state recorded, no `sorry` left,
        Phase 4's header carries the measured reason.
      **Recorded: Branch R.** All four pinned statements closed (second guarded compile; the first
      pass had two `absurd`-shaped one-line fixes in `endA_at_zero_iff`, zero other defects; zero
      warnings). `decide` closed `reach5_four`, `reachStep5_univ` and the `d`-free step facts outright.
      The sentence Phase 4 carries: "the exhibited period is the period of the reach-SET iteration on
      the full graph, and a formula that forbids a letter restricts the object to a sub-object with a
      different period; period 1 is exhibited for the coprime-cycle object and every modulus coprime
      to 3 fails". Measured: 486 lines added (909 total; scope hypothesis 250–350, signal at 450) —
      `fwd5`/`bwd5` ARE the ported recipe (~45 lines); the excess is the reference history, the two
      `Along5`/`Truth5` sections and the cell lemmas, each with its docstring.
- [x] Compile through the guard and commit per the green-substep mandate.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase adds ~250–350 lines (fixture B and its seriality ~120, the reach
theorems ~40, `cyc`/`g5Ref` ~60, `walk_mod3`/`endA_at_zero_iff`/`cell5_ne` ~100). Confirm with
`wc -l`; a figure above 450 added signals the seriality proofs were not ported from `fwdP`/`bwdP`.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`
exiting 0 is the complete covering check — a file outside the Lake build graph that nothing
imports and that modifies no library module.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` - fixture B, the reach-period exhibition, mechanism (5)

**Verification**:
- The guarded `lake env lean` exits 0 with zero `error` and zero `warning` lines; grep count 0 for
  `sorry`, `^axiom `, `native_decide`, and the vacuous-definition pattern.
- The four Goal signatures of this phase match the Challenge block with whitespace normalised.
- `reach5_eventually_constant` is stated with `k + 1` (period 1), not a larger period.
- Exactly one of Branch R / Branch N is recorded in the phase body.

---

### Phase 3: Bounded Attempt — Sufficiency on the Deterministic Fixture [COMPLETED]

**Goal**: Measure, within a hard 2-hour cap, whether the only positive statement the analysis
supports can be landed: on fixture A, where every history through a pending state shares one
object path, the realized cell is determined by the object state, the countdown's parity, and
whether the countdown is at least a FORMULA-derived threshold — for box/stab-free formulas.

**This phase is not pinned.** Its target statement is known in shape but its threshold function
is not known at plan time, and plan-compliance forbids pinning a statement that may need
adjustment. The deliverable is the measurement record; a landed theorem is a bonus, never the
factorization lemma.

**Target shape** (names are the decomposition; the exact threshold function `thr` is to be
defined by structural recursion on `PlusFormula` and recorded):
- `qp_truth_of_objPath` — for BoxStabFree `ψ`, the truth of `ψ` at `(σ, s)` on `M` depends only
  on the object projection `fun t => (g t).1.1` of `σ`'s path (induction on `ψ`; the `box`/`stab`
  cases are excluded by `boxStabFree_of_mem_subformulas`).
- `qp_forced_path` — every sliced-step path through `((true, tg), c, n)` has object projection
  `fun t => (if t ≤ c then (true, tagAt tg t) else (false, tagAt tg c))` (forward: `pending_run`,
  `idle_at`, idle-only successors; backward: `stepP`'s idle clause forbids idle-to-pending, so
  every predecessor of a pending state is pending with the flipped tag).
- `qp_type_shift` — for BoxStabFree `φ` and `c ≥ thr φ`, the type at `0` along the forced path
  from `(tg, c)` equals the type along the forced path from `(tg, c + 2)` (two-parameter eventual
  periodicity: pending positions are the one-parameter family `(tag, remaining)`, idle positions
  the two-parameter family `(c, age)`; the `untl` and `snce` cases re-index the witness position
  by `remaining` and use `tagAt`'s period 2).
- `qp_cell_eq_of_depth_parity` — for BoxStabFree `φ`, `thr φ ≤ c`, `thr φ ≤ c'`, `c % 2 = c' % 2`,
  and ANY `n`, `n'`: `cellAt M φ (wP tg c n) 0 = cellAt M φ (wP tg c' n') 0`.

**Tasks**:
- [x] Sub-step (a), 30 minutes: `qp_truth_of_objPath` and `qp_forced_path`. Record whether each
      closes; if (a) does not close within its budget, stop and record Branch O.
- [x] Sub-step (b), 60 minutes: define `thr` and attempt `qp_type_shift` for the `atom`/`bot`/`imp`
      cases and the `untl` case; then the `snce` case. Record the furthest constructor closed and
      the goal state at the first one that does not.
- [x] Sub-step (c), 30 minutes: if (b) closed, `qp_cell_eq_of_depth_parity` from (a), (b) and the
      singleton shape of the cell; record the landed signature verbatim in this phase body and in
      the probe header.
- [x] **Stop condition, binding**: the phase closes on this enumeration, never on a verdict. Do not
      open a fourth sub-step, do not weaken the target by adding a hypothesis to make it close, do
      not touch fixture B, do not state anything about the general object, and leave NO declaration
      with a `sorry` body — a sub-step that does not close is deleted from the file and recorded in
      this phase body with its goal state.
- [x] **Decision gate, both branches pre-specified**:
      - **Branch P (the fixture theorem lands)**: it is recorded in the probe header as a
        FIXTURE-LEVEL sufficiency theorem — necessity of a formula-derived threshold by mechanism
        (4), sufficiency on the two-state object — and explicitly NOT the factorization lemma: the
        fixture has no region restart, so every history shares one object path, and that is exactly
        what the general object lacks. Phase 5's records say the same in words.
      - **Branch O (it does not land within the cap)**: the header records the furthest sub-step
        closed and the obligation that blocked it, and the positive statement stays OPEN and unstated.
      **Recorded: Branch P.** Sub-step (a) closed (`qp_truth_of_objPath`, `qp_forced_path`; the
      object projection is abstracted as `TruthO : (ℤ → Qp) → ℤ → PlusFormula → Prop` and the forced
      path as `objP tg c`). Sub-step (b) closed: `thr` is `0` on atoms and `bot`, `max` on `imp`,
      `max + 2` on `untl`, `max` on `snce` (two per `untl` nesting: the two positions a shift by
      two exposes; nothing per `snce`: the past of a pending position is the same infinite
      alternating run on both paths); `qp_type_shift` closes every constructor, via the time-shift
      lemma `truthO_shift`, the rebase identity `objP tg c (t + d) = objP (tagAt tg d) (c - d) t`
      and the period-2 identity `objP tg (c + 2) t = objP tg c (t - 2)`. Sub-step (c) closed:
      `cellAt_eq_singleton` (the cell at a pending state is `{tpO φ tg c}`), `tpO_add_two`,
      `tpO_add_even`, and the landed signature, verbatim:
      `theorem qp_cell_eq_of_depth_parity {φ : PlusFormula} (hφ : PlusFormula.BoxStabFree φ)
      (tg : Bool) (c c' n n' : ℕ) (hc : thr φ ≤ c) (hc' : thr φ ≤ c') (hpar : c % 2 = c' % 2) :
      cellAt M φ ((0 : ℤ), st tg c n) 0 = cellAt M φ ((0 : ℤ), st tg c' n') 0` (the plan's `wP tg c n`
      is written out as `((0 : ℤ), st tg c n)`; no `wP` abbreviation was introduced). Wall clock,
      measured from the phase's start stamp: about 10 minutes for all three sub-steps across five
      guarded compiles (defects: two name fixes, one dead tactic, two `open Classical in`
      placements); the 2-hour cap and the three sub-step budgets were not approached. 519 lines
      added (1428 total; scope hypothesis 0–250 with a signal at 350 for a dishonoured stop
      condition — the stop condition was honoured on the enumeration, every sub-step closed, and
      the excess is the tagged `pending_run`/`idle_at` port plus `idle_run`/`pending_back`, the
      shift and rebase lemmas, and `thr_le_of_mem_subformulas`, each with its docstring).
      Sentence Phase 4's header carries: "on the two-state fixture the cell at a pending state is
      a singleton determined by the object state, the countdown's parity, and whether the
      countdown is at least the formula-derived threshold `thr φ`; this is FIXTURE-LEVEL
      sufficiency, resting on `qp_forced_path`, and is not the factorization lemma".
- [x] Compile through the guard and commit per the green-substep mandate.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Between 0 and ~250 lines are added, depending on the branch. A figure above
350 signals the stop condition was not honoured.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`
exiting 0 is the complete covering check — a file outside the Lake build graph that nothing
imports and that modifies no library module.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` - the attempt's landed declarations (Branch P) or nothing (Branch O); the measurement goes in the phase body and the Phase 4 header

**Verification**:
- The guarded `lake env lean` exits 0 with zero `error` and zero `warning` lines; grep count 0 for
  `sorry` and the vacuous-definition pattern.
- Exactly one of Branch P / Branch O is recorded, with the three sub-steps' outcomes and the
  wall-clock spent on each.
- On Branch P the landed signature carries a BoxStabFree hypothesis and a formula-derived
  threshold, and its name begins `qp_`; no declaration in this file states, or partially states, a
  factorization lemma over the general object.

---

### Phase 4: Probe Header, Axiom Block, and Evidence-Gate Wiring [NOT STARTED]

**Goal**: Replace the provisional header with the record the three decision gates produced, add
the `#print axioms` block, and wire the probe into the evidence gate as the fifteenth wired probe.

**Tasks**:
- [ ] Write the final header in the fourteenth probe's shape: title sentence; "What was asked";
      the two mechanisms with their settling declarations and the sentence each decision gate
      produced; the `P` versus `P + 1` convention ambiguity and why every statement is
      convention-independent; the Phase 3 outcome and, on Branch P, the explicit "fixture-level,
      not the lemma" paragraph; "What this probe does NOT say" (no general factorization lemma in
      any shape; no seventh coordinate; the three earlier negatives untouched; no finiteness added;
      nothing about HitPresented; no library declaration; the acceptance clause never dropped; the
      successor design not chosen); the refined parameter-origin rule as a NECESSARY condition —
      the threshold must be at least the formula's `untl`-nesting depth, the modulus must dominate
      the period of every letter-definable sub-object — never claimed sufficient; the "Axioms"
      paragraph; the compile line.
- [ ] Add `#print axioms` for every Goal and for `walk_mod3`, `pending_run_gen`, `idle_at_gen`,
      and any Phase 3 Branch P declaration, after `end Probe775`; record the printed readings in
      the header's Axioms paragraph (expected `[propext, Classical.choice, Quot.sound]` on the cell
      theorems, `[propext, Quot.sound]` on the index collisions).
- [ ] `git add` the probe (the gate's rule is "tracked, not merely present").
- [ ] In `scripts/check-evidence-probes.sh`: add one 120-column-wrapped row to the `# --- WIRED ---`
      comment table, after the `ladder-cell-index-obstructions` row, in the same shape (what it holds
      in place; axioms), and one `WIRED=(` array entry
      `"seam-gluing-ray-product/ladder-residue-index-refutation"` after the fourteenth's. Cite
      declaration names and section headings only — no task number.
- [ ] `bash -n scripts/check-evidence-probes.sh`, then run the gate detached with a bounded waiter;
      require `PASS` with the new probe named and zero FAIL.
- [ ] Commit per the green-substep mandate.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The header is ~120–180 lines; the script edit is one table row (~6–10 wrapped
lines) plus one array line. Confirm with `git diff --stat`; a script diff above 15 lines signals an
unintended edit elsewhere in the file.

**Tier Justification**: `bash -n scripts/check-evidence-probes.sh` followed by a full detached run
of `bash scripts/check-evidence-probes.sh` reporting the new probe PASS, together with the guarded
`lake env lean` of the probe, is the complete covering check — the script is a standalone gate
with no test suite of its own and the probe is outside the build graph.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` - final header and axiom block
- `scripts/check-evidence-probes.sh` - one wired-table row and one `WIRED` array entry

**Verification**:
- The guarded `lake env lean` of the probe exits 0; every `#print axioms` line prints a reading
  without `sorryAx` and without any axiom beyond `propext`, `Classical.choice`, `Quot.sound`.
- `check-evidence-probes.sh` reports every wired probe PASS including the new one (33 wired).
- The header's sentences for mechanisms (4), (5) and the Phase 3 outcome are the ones recorded in
  Phases 1–3's decision-gate bodies, verbatim.
- No task number in the script row; `grep -nE 'task [0-9]|specs/[0-9]{3}_' scripts/check-evidence-probes.sh`
  returns nothing new.

---

### Phase 5: Amend the In-Tree Records [NOT STARTED]

**Goal**: Stop every in-tree record describing the exhibited-parameter candidate as the live
candidate, and record what is now machine-checked about where the parameters must come from.

**Tasks**:
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` — module DOCSTRING only,
      the bullet "No index of a ladder cell is claimed": add that the residue-carrying candidate at
      object-exhibited parameters is refuted at both parameters by the wired probe
      `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`
      (`object_only_parameters_refuted`: the first idle state's exact distance is observable to the
      formula's depth; `reach_period_refuted`: the reach-set period is not the period of a
      letter-restricted sub-object), that the threshold must therefore be formula-derived and the
      modulus must dominate sub-object periods, and that the positive lemma — for parameters
      depending on the object and the formula jointly — is OPEN and asserted nowhere. On Phase 3
      Branch P, one sentence naming the fixture-level theorem as fixture-level. Zero declarations
      added or changed (12 top-level declarations before and after).
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the "(W): what landed and what
      did not" passage (the sentence "the gated residue-carrying one the same probe exhibits") and
      the fourteenth-probe Evidence paragraph: add a fifteenth-probe Evidence paragraph in the same
      register (what it establishes, what it withholds, the settling declarations), and amend the
      (W) sentence so the residue-carrying candidate is named refuted at its exhibited parameters.
      The `LadderModel.lean` row is amended only if its line count changes (it is a count and C14
      watches it).
- [ ] `docs/theorem-index.md` — the row clauses that cite `ladder-cell-index-obstructions.lean`
      (the `ladderFrameAdm`/`ladderModel` rows and neighbours): add the fifteenth probe's citation
      and the one-clause refutation summary. No declaration cell, no axiom cell, no count touched.
- [ ] Grep every touched record for `exhibited`, `reachN_eventually_periodic`, `object-derived`,
      `ladderIndexRes`: each surviving occurrence must sit in a sentence that names the refutation
      or the OPEN status. No record-versioning language ("no longer", "previously"); state the
      current fact.
- [ ] Scoped guarded build of `FormalSystem.Metalogic.Decidability.RaySummary.LadderModel`
      (docstring-only edit; confirms the module still elaborates), `bash scripts/readme-lint.sh`,
      `bash scripts/check-module-invariants.sh` (C9, C9D, C14 PASS), then commit per the
      green-substep mandate. If the pre-commit hook regenerates `typst/generated/status.typ`,
      commit it with this phase and record the fact.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Three files; roughly one amended bullet in the docstring (~10–14 lines), one
new Evidence paragraph plus one amended sentence in the README (~25–35 lines), and 2–4 amended row
clauses in the theorem index. Confirm with `git diff --stat`; a docstring delta above 20 lines or
any `+theorem`/`+def` line in `LadderModel.lean` signals a declaration was added.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderModel`
exiting 0 plus `bash scripts/readme-lint.sh` and `bash scripts/check-module-invariants.sh` is the
complete covering check — a docstring-only edit to one module (no signature changes, so no
dependent can break) and two markdown records whose only mechanical consumers are those two lints.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` - module docstring bullet (no declarations)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - (W) narrative sentence and a fifteenth-probe Evidence paragraph
- `docs/theorem-index.md` - row clauses citing the fourteenth probe
- `typst/generated/status.typ` - only if the pre-commit hook regenerates it; no edit is planned

**Verification**:
- Scoped guarded build exits 0; `readme-lint.sh` PASS with 0 broken references;
  `check-module-invariants.sh` C9/C9D/C14 PASS.
- `grep -c '^theorem\|^def\|^abbrev\|^instance' LadderModel.lean` is unchanged (12 top-level
  declarations).
- No file outside `specs/` carries a task number introduced here.
- Every surviving mention of the exhibited parameters sits in a sentence naming the refutation.

---

### Phase 6: Amend the Counter-Observables Context Note in the Source Store [NOT STARTED]

**Goal**: Make the lean extension's guidance stop stating the opposite of what is now
machine-checked: add mechanisms (4) and (5) to the gate table and rewrite the parameter-origin
rule as the refutations leave it.

**Tasks**:
- [ ] Re-confirm the source store: `.claude-extensions.json` carries no `source_dir`; the path
      carried from the predecessor's summary is
      `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`
      (confirmed present at plan time by `ls`). If absent, follow
      `context/standards/source-store-deploy-boundary-narrative.md`'s unreachable-source-store
      fallback; NEVER write under `.claude/`.
- [ ] "The three mechanisms" → "The five mechanisms": add **(4) the threshold against the
      formula's depth** and **(5) the reach-set period against a letter-restricted sub-object**,
      each with its settling declarations in the fifteenth probe and its one-sentence mechanism.
- [ ] The gate table: add rows 4 (pair `(q, T, n)` against `(q, T + (P+1), n)`, `n = T + (P+1) + B`,
      formula the depth-`(T+1)` next-chain) and 5 (the coprime-cycle object, pair
      `(a, 3(P+1)(T+1), n)` against `(a, 3(P+1)(T+1) + (P+1), n)`, formula `p U (r ∧ ℓ_a)` with
      `⊤ U ℓ_d` in the closure), and state that gates 4–5 are REFUTATIONS of the exhibited
      parameters, not separations the candidate passes.
- [ ] "The parameter-origin rule": rewrite so that `B` AND the threshold come from the FORMULA
      (`B` from the gap the formula can see; the threshold at least the formula's `untl`-nesting
      depth), the modulus must dominate the period of every letter-definable sub-object of the
      object (the reach-set period of the full graph does not), and the sentence "deriving … the
      threshold and period from the formula is the error this rule exists to prevent" is replaced
      by the corrected rule. State the corrected rule as NECESSARY, proved by the two refutations,
      and its sufficiency as OPEN.
- [ ] "What is still open": the positive lemma for parameters depending on the object and the
      formula jointly is OPEN; the proof obligations a successor would meet are named (eventual
      periodicity of realizable types in the countdown over the product of the object with the
      closure; a region-length pumping lemma for `untl`/`snce`-depth-bounded formulas; the next
      deadline's coupling through `Drift`; the box/stab letters through the anchor-layer equations);
      on Phase 3 Branch P, the fixture-level theorem is named as the one-path special case.
- [ ] No registration change: the file is already registered in that tree's `index-entries.json`
      and `context/project/lean4/README.md`. The deployed mirror under `.claude/` is never
      hand-authored and arrives with the next regeneration — state this as the expected outcome.
- [ ] Commit per the green-substep mandate (the source store is its own git tree; commit there
      with the task's session ID, scoped to this one file).

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: prose

**Commit Mode**: per-substep

**Tier Justification**: The edit is one guidance markdown file with zero executable surface in a
source-store tree outside this repository's gates, so no suite covers it (`suite_selection_select`
returns `__FULL_SWEEP__`); the honest covering check is the `prose` row's diff read-through
confirming every changed hunk is prose, plus `grep -nE 'task [0-9]|specs/[0-9]{3}_'` on the file
returning nothing.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md` - mechanisms (4)–(5), gate rows 4–5, the corrected parameter-origin rule, the open-status section

**Verification**:
- Diff read-through: every changed hunk is prose; the sentence the refutations overturn is gone
  and the corrected rule is stated as necessary, with sufficiency OPEN.
- No task number, no record-versioning language, durable anchors only (probe filename,
  declaration names, section headings).
- Nothing was written under `.claude/`.

---

### Phase 7: Full Gate and Final Verification [NOT STARTED]

**Goal**: Re-observe every phase's measurement through the repository's complete gate set, with
nothing trusted on sight.

**Tasks**:
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh` (all gates, no
      `--only-gate` narrowing and no `--skip-slow`), `bash scripts/check-evidence-probes.sh`,
      `bash scripts/check-module-invariants.sh`, `bash scripts/readme-lint.sh`,
      `bash .claude/scripts/check-task-references.sh`, `bash scripts/typst-sync-check.sh` (if
      present), and the full guarded project build
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`. Every run goes
      detached with a bounded waiter per `context/patterns/bounded-build-waiter.md`, and each
      verdict is read from the guard's own result rather than a pipe exit code.
- [ ] Re-grep the repository for a zero-debt violation introduced by this task: no `sorry`, no
      `axiom`, no `native_decide`, no vacuous-definition pattern in the probe;
      `bash .claude/scripts/lean-sorry-census.sh` unchanged.
- [ ] Confirm the resting posture mechanically: no positive factorization statement over the
      general object exists as a declaration in any file this task wrote (the only non-negated
      occurrences of the shape are inside negations and the quoted target in the header; on Phase 3
      Branch P, the fixture theorem's name begins `qp_` and carries its BoxStabFree hypothesis);
      zero declarations added under `FormalSystem/`; `AnchorLayer.lean` and `Trace.lean`
      unchanged; no file outside `specs/` carries a task number introduced here; the axiom count is
      unchanged from the dispatch-start commit.
- [ ] Run `bash .claude/scripts/lean-challenge-snapshot.sh --check 775 .` as an ADVISORY drift
      check if a manifest exists; otherwise diff the eight Goal signatures and the two pinned
      definitional bodies against the Challenge block with whitespace normalised. Report the verdict;
      never use it alone to fail anything.
- [ ] If the pre-commit hook regenerates `typst/generated/status.typ`, commit the regenerated file
      with this phase and record the fact in the summary.
- [ ] Final commit for the phase. Leave the plan-level `- **Status**:` field for the postflight.

**Timing**: 1 hour

**Depends on**: 5, 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `typst/generated/status.typ` - only if the pre-commit hook regenerates it; no edit is planned

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` exits 0 with every gate it aggregates passing, run in
  this dispatch and observed green rather than trusted on sight.
- `check-evidence-probes.sh` reports every wired probe PASS, including the fifteenth.
- `check-module-invariants.sh`, `readme-lint.sh` and the full guarded `lake build` exit 0;
  `check-task-references.sh`'s pre-existing repo-wide baseline is reported as measured, with none
  of its occurrences in any file this task touched.
- Zero-debt grep across the probe returns no match for `sorry`, `^axiom `, `native_decide`, or a
  vacuous-definition pattern.
- The eight Challenge statements are present at their pinned signatures in the wired probe; the
  advisory drift check's verdict is reported.
- No phase heading carries a status other than `[COMPLETED]`, `[COMPLETED WITH EXCLUSIONS]`,
  `[PARTIAL]` or `[BLOCKED]` as its own body justifies; the plan-level `- **Status**:` field is
  left for the postflight and is not hand-edited.

---

## Lean Challenge Statements

The eight `theorem` declarations are the Goals and carry `sorry` bodies. Everything above them is
supporting context declared with `abbrev`, which the snapshot tool neither counts as a Goal nor
rewrites — but it DOES swallow any non-`theorem` text between two `theorem` declarations into the
preceding `:= sorry`, so every `abbrev` precedes the first `theorem`. The seriality facts the probe
proves in full (`fwdP`, `bwdP`, `fwd5`, `bwd5`) appear as `sorry`-bodied `abbrev`s: not Goals, their
statements pinned by position only. Definitional bodies (`ladderIndexRes` and `reachStep`, ported
byte-for-byte from the fourteenth probe; `nextPow`; both objects, step relations, labellings and
formulas; the witnessing states) are part of the contract and are written out. Identifiers are
ASCII for the snapshot tool's regex. Phase 3's fixture-level theorems are deliberately NOT pinned:
their threshold function is not known at plan time, so they are an outcome rather than a
commitment, and they are not Goals.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe775

-- The re-scoped candidate, ported byte-for-byte from the fourteenth probe.
abbrev ladderIndexRes (T P B : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    Q × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) × Fin (2 * B + 1) :=
  (x.1.1,
    ⟨min x.1.2.1 T, by omega⟩,
    ⟨x.1.2.1 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min x.1.2.2 T, by omega⟩,
    ⟨x.1.2.2 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min ((x.1.2.2 + B) - x.1.2.1) (2 * B), by omega⟩)

-- The reachability map, ported byte-for-byte from the fourteenth probe.
abbrev reachStep {Q : Type} [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool)
    (S : Finset Q) : Finset Q :=
  S.biUnion (fun q => Finset.univ.filter (fun q' => step q q' = true))

-- k nested nexts, with X chi := bot U chi.
abbrev nextPow : ℕ → PlusFormula → PlusFormula
  | 0, chi => chi
  | k + 1, chi => .untl .bot (nextPow k chi)

-- Fixture A: the two-state alternating object of the fourteenth probe, ported verbatim.
abbrev Qp : Type := Bool × Bool

abbrev pendP : Qp → Bool := fun q => q.1

abbrev stepP : Qp → Qp → Bool := fun x y =>
  if x.1 then (if y.1 then (y.2 != x.2) else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

-- Proved as theorems in the probe; abbrev here only so the snapshot tool keeps the ordering.
abbrev fwdP : ∀ t x, ∃ y, RladAdm stepP pendP t x y := sorry

abbrev bwdP : ∀ t x, ∃ y, RladAdm stepP pendP (t - 1) y x := sorry

abbrev F : FrameOver intOrder := ladderFrameAdm stepP pendP fwdP bwdP

abbrev pA : Atom := ⟨"p", none⟩
abbrev rA : Atom := ⟨"r", none⟩
abbrev aA : Atom := ⟨"a", none⟩
abbrev dA : Atom := ⟨"d", none⟩

abbrev labP : Qp → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1 else if at_ = aA then q.2 else false

abbrev M : TaskModel F.toTaskFrame := ladderModel stepP pendP fwdP bwdP labP

abbrev p : PlusFormula := .atom pA
abbrev r : PlusFormula := .atom rA

-- The depth-(T+1) next-chain ending in the idle letter.
abbrev phiDepth (T : ℕ) : PlusFormula := nextPow (T + 1) r

abbrev st (tg : Bool) (c n : ℕ) : LadderState Qp pendP :=
  ⟨((true, tg), c, n), fun h => by cases h⟩

abbrev xT (T P B : ℕ) : LadderState Qp pendP := st false T (T + (P + 1) + B)

abbrev yT (T P B : ℕ) : LadderState Qp pendP := st false (T + (P + 1)) (T + (P + 1) + B)

-- Fixture B: two pending cycles of coprime lengths sharing a state.
-- Pending indices: 0 = a, 1 = b, 2 = c, 3 = d; edges a -> b -> c -> a and a -> d -> a.
-- Every pending (true, i) steps to its idle copy (false, i); idle states self-loop.
abbrev Q5 : Type := Bool × Fin 4

abbrev pend5 : Q5 → Bool := fun q => q.1

abbrev step5 : Q5 → Q5 → Bool := fun x y =>
  if x.1 then
    (if y.1 then
      ((x.2 == 0 && (y.2 == 1 || y.2 == 3)) || (x.2 == 1 && y.2 == 2) ||
        (x.2 == 2 && y.2 == 0) || (x.2 == 3 && y.2 == 0))
     else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

abbrev fwd5 : ∀ t x, ∃ y, RladAdm step5 pend5 t x y := sorry

abbrev bwd5 : ∀ t x, ∃ y, RladAdm step5 pend5 (t - 1) y x := sorry

abbrev F5 : FrameOver intOrder := ladderFrameAdm step5 pend5 fwd5 bwd5

abbrev lab5 : Q5 → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1
  else if at_ = aA then (q.2 == 0) else if at_ = dA then (q.1 && q.2 == 3) else false

abbrev M5 : TaskModel F5.toTaskFrame := ladderModel step5 pend5 fwd5 bwd5 lab5

abbrev la : PlusFormula := .atom aA
abbrev ld : PlusFormula := .atom dA

-- p U (r AND l_a): the region ends on the idle copy of a.
abbrev endA : PlusFormula := .untl p (r.and la)

-- top U l_d, with top := bot -> bot: some strictly later state is pending d.
abbrev evD : PlusFormula := .untl (.imp .bot .bot) ld

-- The probe formula; both observables are in its closure.
abbrev phi5 : PlusFormula := .imp endA evD

abbrev a5 : Q5 := (true, 0)

abbrev st5 (i : Fin 4) (c n : ℕ) : LadderState Q5 pend5 :=
  ⟨((true, i), c, n), fun h => by cases h⟩

-- A countdown divisible by 3 and by P + 1, at or above every threshold T.
abbrev c5 (T P : ℕ) : ℕ := 3 * (P + 1) * (T + 1)

abbrev x5 (T P B : ℕ) : LadderState Q5 pend5 :=
  st5 0 (c5 T P) (c5 T P + (P + 1) + B)

abbrev y5 (T P B : ℕ) : LadderState Q5 pend5 :=
  st5 0 (c5 T P + (P + 1)) (c5 T P + (P + 1) + B)

theorem truth_nextPow {G : FrameOver intOrder} (N : TaskModel G.toTaskFrame)
    (σ : WorldHistory G.toTaskFrame) (k : ℕ) (chi : PlusFormula) (s : ℤ) :
    PlusTruthAt N σ s (nextPow k chi) ↔ PlusTruthAt N σ (s + k) chi := sorry

theorem depth_collision (T P B : ℕ) :
    ladderIndexRes T P B (xT T P B) = ladderIndexRes T P B (yT T P B) := sorry

theorem cell_depth_ne (T P B : ℕ) :
    cellAt M (phiDepth T) ((0 : ℤ), xT T P B) 0 ≠ cellAt M (phiDepth T) ((0 : ℤ), yT T P B) 0 :=
  sorry

theorem object_only_parameters_refuted :
    ¬ ∃ T P B : ℕ, ∀ φ : PlusFormula, ∀ x y : LadderState Qp pendP,
        ladderIndexRes T P B x = ladderIndexRes T P B y →
          cellAt M φ ((0 : ℤ), x) 0 = cellAt M φ ((0 : ℤ), y) 0 := sorry

theorem reach5_eventually_constant :
    ∀ k : ℕ, 4 ≤ k → (reachStep step5)^[k + 1] {a5} = (reachStep step5)^[k] {a5} := sorry

theorem period_collision (T P B : ℕ) :
    ladderIndexRes T P B (x5 T P B) = ladderIndexRes T P B (y5 T P B) := sorry

theorem cell5_ne (T P B : ℕ) (h3 : ¬ 3 ∣ (P + 1)) :
    cellAt M5 phi5 ((0 : ℤ), x5 T P B) 0 ≠ cellAt M5 phi5 ((0 : ℤ), y5 T P B) 0 := sorry

theorem reach_period_refuted (T P B : ℕ) (h3 : ¬ 3 ∣ (P + 1)) :
    ¬ ∀ x y : LadderState Q5 pend5, ladderIndexRes T P B x = ladderIndexRes T P B y →
        cellAt M5 phi5 ((0 : ℤ), x) 0 = cellAt M5 phi5 ((0 : ℤ), y) 0 := sorry

end Probe775
```

## Testing & Validation

- [ ] The probe compiles through the guard at exit 0 with zero `error` and zero `warning` lines
      after each of Phases 1–4; `#print axioms` prints no `sorryAx` and no axiom beyond `propext`,
      `Classical.choice`, `Quot.sound`.
- [ ] `ladderIndexRes` and `reachStep` in the probe are byte-identical (whitespace-normalised) to
      the fourteenth probe's bodies, so the refutation is of the index as landed.
- [ ] The eight Goal signatures match the Challenge block with whitespace normalised; the advisory
      `lean-challenge-snapshot.sh --check` verdict is reported if a manifest exists.
- [ ] `check-evidence-probes.sh` PASS with 33 wired probes, the fifteenth named.
- [ ] `verify-deploy.sh` (full), `check-module-invariants.sh`, `readme-lint.sh`, the full guarded
      `lake build`, and `lean-sorry-census.sh` all green; `check-task-references.sh`'s pre-existing
      baseline reported as measured with no occurrence in a file this task touched.
- [ ] No positive factorization statement over the general object exists as a declaration anywhere
      this task wrote; zero declarations added under `FormalSystem/`; no task number outside `specs/`.
- [ ] Each decision gate (Phases 1, 2, 3) has exactly one branch recorded with the sentence the
      probe header carries, verbatim.

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` — the fifteenth
  wired evidence probe: generic forced-run lemmas, the next-chain truth lemma, mechanism (4) on
  fixture A, mechanism (5) on fixture B with the exhibited period, the Phase 3 outcome, and a header
  recording the refined parameter-origin rule as necessary and the positive lemma as OPEN.
- `scripts/check-evidence-probes.sh` — one wired-table row and one `WIRED` entry.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` (docstring),
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `docs/theorem-index.md` — amended
  records.
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/ladder-counter-observables.md`
  — mechanisms (4)–(5), gate rows 4–5, the corrected parameter-origin rule.
- `specs/775_residue_index_factorization_lemma/summaries/01_residue-index-parameter-refutation-summary.md`
  — written by the implementation postflight.

## Rollback/Contingency

- No library declaration is added, so no downstream module can break; the docstring and record
  edits revert with `git checkout -- <file>` on a clean tree (or after
  `bash .claude/scripts/git-snapshot.sh 775` on a dirty one, per `rules/git-workflow.md`).
- If Phase 1 or 2 closes `[BLOCKED]` (a prediction does not close), the probe still lands with the
  mechanism that did close and the measured reason for the other; Phase 4's header carries both
  sentences; the records say exactly what was and was not refuted. A `[BLOCKED]` phase means the
  implementation returns `partial` with `requires_user_review: true`, never `implemented`.
- If Phase 3 overruns, the stop condition closes it on Branch O with no declaration left behind;
  nothing downstream depends on its success.
- If the evidence gate or the full build fails for a reason outside this task (a competing
  unguarded `lake`, a pre-existing baseline), report it as measured and do not bypass any gate
  with `--no-verify`.
- The source-store edit is reverted in that tree by `git checkout -- <file>` there; the deployed
  mirror is never hand-edited in either direction.
