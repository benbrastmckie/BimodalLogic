# Implementation Plan: Task #759

- **Task**: 759 - Node fixture probe: HitPresented for a ⊡-bearing formula at an infinite-width seam (hitPresented_node or its negation)
- **Status**: [IMPLEMENTING]
- **Effort**: 14.5 hours
- **Dependencies**: 758 (serialization edge only: shared `scripts/check-evidence-probes.sh` and RaySummary README; 758 is `[COMPLETED]`, so the edge is discharged)
- **Research Inputs**: specs/759_node_hit_presented_probe/reports/01_node-hit-presented-probe.md
- **Artifacts**: plans/01_node-hit-presented-probe.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Author the wired evidence probe `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`
(`namespace Probe759`) establishing the POSITIVE headline: on the library fixture
`NoFiniteWidth.M`, at every pre-seam `(t, Node.pre m)`, for the fixture's own ⊡-bearing witness
`Φ` (28 closure members, re-derived at plan time), `HitPresented` holds at every depth `1 ≤ k`
for a presentation whose state count `windowN m k + 5` is EXHIBITED in the statement, with
`windowN m k = min m (Nat.card (KType (clSig Φ) k) + 1)` — a count of depth-`k` types, uniform
over every seam index `m`. The negative headline `not_hitPresented_node` is provably unavailable
on `Node` (every seam fibre is finite: `m + 1` histories through `(t, pre m)`), which the probe
records in its header without triggering any Stage 0 ruling. The route is the model-A truncation
argument of `hit-presented-model-a.lean` (`Probe745`) transplanted to `Node`: seam classification
replaces model A's rigidity, the fixture's four relative-position letter classes replace its three
letters, and the library's `kTypeOf_listSeg_replicate_eventually_periodic_bounded` plus
`familyTriples_subset_deleteRun` do the shrinking unchanged. Then wire the probe into
`scripts/check-evidence-probes.sh` and record it in the RaySummary README. No library file under
`FormalSystem/` is touched; nothing is `sorry`, axiom, or vacuous.

### Research Integration

- **Verdict**: positive. `through_pre` (transcribed and sharpened from `Probe758`) shows exactly
  `m + 1` histories pass through `(t, pre m)`, each canonical and eventually constant both ways,
  so trace-level `Presented` holds at window `m` and the negative is false at every seam, for
  every `Φ'`. Recorded as the by-product theorem `presented_node`; NOT the headline's route.
- **Formula**: `Φ' := Φ` (first in the dispatch's order; `D` and `⊡Xp` not needed). `cl Φ` has
  28 members (re-derived this session by compiling the research prototype, `lake env lean`
  exit 0), carries all four `⊡`-letters of the fixture, and `Probe758.truth_transfer` shows the
  28-way enumeration closes by one `simp only`.
- **Two indices**: seam index `m` and depth `k` are independent; the dispatch's single-`k`
  statement is the corollary `hitPresented_node_canon` at `τ := histOf k (t + 1)`.
- **General `τ`**: `HitCl M τ t Φ k` depends on `τ` only through `τ.state t` (`spliced` is built
  from `seamOmegaEquiv t (τ.state t)`), so the primary binder is `τ` with
  `hτ : τ.state t = .pre m`.
- **Compiled oracle**: `specs/759_node_hit_presented_probe/prototype/node-hit-presented-proto.lean`
  (114 lines, exit 0 at plan time) holds `seam_state`, `through_pre`, `canon_through`,
  `spliced_state`, `exists_splice_eq`, `hitCl_pre` at `[propext, Classical.choice, Quot.sound]`;
  Phase 1 ports it.
- **Trace shape** (report, from `truth_transfer`): on a canonical history `histOf k' t'`, every
  closure letter at time `s` depends only on the class of `d := t' - s` in `{≥2, 1, 0, <0}`,
  never on `k'`. Four letter vectors `ℓ₂, ℓ₁, ℓ₀, ℓ₋` plus the `now` bit at `s = t`. Writing
  `c_i` for the trace of the `i`-th history through `(t, pre m)` (`t' = t + 1 + i`):
  `c_0 = ℓ₂^(ω*)·[ℓ₁+now]·ℓ₀·ℓ₋^ω`; for `1 ≤ i`, `c_i = ℓ₂^(ω*)·[ℓ₂+now]·ℓ₂^(i-1)·ℓ₁·ℓ₀·ℓ₋^ω`.
  The constant run `ℓ₂^(i-1)` on `[t + 1, t + i)` is model A's `a`-run.
- **Containment adjustment** (report, Codebase Patterns): the `seam_lt_W1` analogue must take its
  nonempty positive segment ABOVE `t + i + 1`, because `t + i` (`ℓ₁`) and `t + i + 1` (`ℓ₀`) sit
  between the run and the `ℓ₋^ω` tail. Cover `t + i + 2` to get `z₁`, then cover `W (z₁ + 1)` to
  get `z₂ ≥ z₁ + 1`; that segment reads `ℓ₋` throughout. Written into Phase 4 so the implementer
  does not transcribe model A's version literally.
- **Gadget edge case found at plan time** (recorded in `issues.jsonl`): the report's sketch
  (`A, N₀, N₊, C_1 … C_(L-1), O, Z, P` on `Fin (L + 5)`) has six fixed states and no room for `O`
  when `L = 0`, which the headline needs at `m = 0`. This plan fixes the encoding: the chain is
  `C_1 … C_L` with `C_L` playing `O`'s role (reads `ℓ₁`), `N₊` may enter the chain at ANY `C_j`,
  and at `L = 0` `N₊` has no successor so no anchored run passes it. Same count `L + 5`, same
  realized traces `{c_i : i ≤ L}`. See Phase 6 for the index table.
- **Collection conventions**: file under `specs/evidence/seam-gluing-ray-product/`, imports
  library modules only (the fixture IS a library module and is imported; `Probe758`'s lemmas are
  transcribed, never imported), `#guard` on the closure card, `#print axioms` foot, header
  sections "What it does NOT say" and "Axiom record", compile line. The gate requires the file
  to be git-tracked, so Phase 1 commits it.
- **Effort basis**: model A, 1595 lines (re-measured), two implement dispatches (749's summary,
  read this session). 758's port took ~1 hour against a 3-hour plan. Estimated probe:
  1300–1600 lines.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch, so ROADMAP.md was not consulted. The task
description's GUARDRAILS (a)–(e) are carried into Phase 1's header checklist and Phase 8's
"does NOT say" section verbatim.

## Goals & Non-Goals

**Goals** (the identifier set equals the `## Lean Challenge Statements` block):
- `windowN` — the exhibited window, `min m (Nat.card (KType (clSig Φ) k) + 1)`, a count.
- `QN` — the state type `Fin (L + 5)` of the presentation with window `L`.
- `card_QN` — `Fintype.card (QN L) = L + 5`.
- `card_QN_le` — `Fintype.card (QN (windowN m k)) ≤ Nat.card (KType (clSig Φ) k) + 6`, the
  count uniform over every pre-seam.
- `labN` — the computable labelling `QN L → (clSig Φ).preds → Bool` (a `def`, not
  `noncomputable`).
- `stepN` — the computable step table `QN L → QN L → Bool`.
- `hitPresented_node` — the headline: `HitPresented M τ t Φ (labN (windowN m k))
  (stepN (windowN m k)) k` for every `τ` with `τ.state t = .pre m`, every `1 ≤ k`.
- `hitPresented_node_canon` — the dispatch's single-`k` shape at `τ := histOf k (t + 1)`.
- `presented_node` — the by-product `Presented M τ t Φ (labN m) (stepN m)`: the exact
  realization at window `m`, the reason the negative is unavailable. Not used by the headline.

**Non-Goals**:
- No lemma is added under `FormalSystem/`; the probe imports the library and re-proves nothing
  of it (`Probe758`'s truth lemmas are transcribed, as the collection's convention requires).
- No `not_hitPresented_node`: it is false on this fixture; the header says so and why.
- No general-row statement (H5), no `PlusValidZTime`, no `Adm`, no ladder, no `⊡(Pp)`, no
  finiteness hypothesis added to the fixture, no complexity bound of any kind, no claim that
  `⊡`-letters discriminate between devices, no claim of minimality of `windowN`.
- No use of `hitPresented_of_presented` on the headline's route (it would lose the uniform count).
- The README edit is the Evidence sentence plus two minimal in-place numeral amendments (see
  Phase 9); nothing structural, no new section.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The four 28-entry letter tables (Phase 3) carry a hand error | M | M | The bridge `clTrace_canon_apply` is proved against the real semantics by a `truth_transfer`-style `simp only` over the enumerated closure, so a wrong entry is a compile failure, never a silent defect; four class lemmas with one shared skeleton. Fallback: a small decidable evaluator on the closure's syntax (truth of primitives per class from the eight `truth_*` lemmas), same bridge |
| `seam_lt_W1` analogue transcribed literally from model A stalls on the `ℓ₁ ℓ₀` tail | M | M | The two-hop cover (`t + i + 2`, then `W (z₁ + 1)`) is written into Phase 4's task text |
| Index confusion (`m` seam, `k` depth, `i` history, `L = windowN m k`, run length `n = i - 1`) | M | M | Names fixed in the Challenge Statements and every phase; `hk : 1 ≤ k` is consumed exactly at `mem_hitOf_iff` and at the keystone `segZ_const_of_kTypeOf_eq_replicate` |
| Gadget at `L = 0` (seam `m = 0`): no room for a separate `O` state | M | H (if the report's sketch is followed) | Phase 6's encoding (chain `C_1 … C_L`, `C_L` reads `ℓ₁`, `N₊ → C_j` for every `j`; `N₊` dead at `L = 0`) resolves it; `#guard` on `QN 2` and the run characterization at `L = 0` are explicit checks |
| `rw` transparency failures on goals mentioning `(.pre m : F.WorldState)` (758's hazard 1) | M | M | Apply iff-lemmas in term mode (`.mp/.mpr`) as the prototype does; never `rw` them on `WorldState`-typed goals |
| `truth_transfer`'s `simp only` set drifts during transcription | M | L | Copy the call verbatim from `node-cell-stabilization.lean`; `forall_eq` (not `forall_eq_or_imp`); `push Not` (not `push_neg`) at this Mathlib pin |
| Over-reading the verdict as evidence for (C)'s general row or as testing the truncation's necessity | H | M | Header language fixed in Phases 1 and 8: "one fixture, every pre-seam"; "`Node`'s seam fibres are finite, so this does NOT test the truncation argument's necessity — a Hit-level falsifier needs a seam with infinitely many histories through it" |
| Gate fails an untracked probe | M | L | Phase 1 `git add`s and commits the file; every later phase commits; Phase 9 adds the `WIRED` entry only once the file compiles whole |
| `git-commit-phase.sh` omits the staged probe (758 observed a task-directory-scope fallback) | L | M | Commit with `.claude/scripts/git-commit-scoped.sh` and explicit paths, as 758 ended up doing |
| README edits collide with task 744; script edit with 734 | L | L | Left to the admission gate per the dispatch; edits are one appended paragraph, two numerals, one table row, one array element; `git status` on both files is clean at plan time |
| C9 / task-reference lint trips on the README or script edit | M | L | Cite only `specs/evidence/...` paths, declaration names, section headings; never `specs/759_…` or "task N" outside `specs/**` |
| Probe gate run (29 files) or full `lake build` exceeds a foreground tool call | L | M | Run detached with a bounded waiter per `context/patterns/bounded-build-waiter.md`; builds via `lake-build-guard.sh` only |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phases 1–8
append sections to ONE file in dependency order (each phase's compile check covers every earlier
section), and Phase 9 wires the finished file. Phases 2 and 6 are logically independent of
Phases 3–5 but share the file, so they are serialized rather than declared parallel.

**Index discipline (binding for every phase)**: `m : ℕ` seam pre-index; `k : ℕ` depth
(`hk : 1 ≤ k`); `i : ℕ` history index, `0 ≤ i ≤ m`; `t' := t + 1 + i` the `x`-time of the
`i`-th history; `W := Nat.card (KType (clSig Φ) k)`; `L := windowN m k = min m (W + 1)`; run
length `n := i - 1` on `[t + 1, t + i)`; `cN t i := clTrace M Φ t (histOf 0 (t + 1 + i))` the
canonical representative of the `i`-th trace (thread-index-free by `clTrace_canon_apply`).

### Phase 1: Header Skeleton, Seam Classification, and `HitCl` as a Finite Union [COMPLETED]

**Goal**: Create `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` with the
header's skeleton and the ported prototype: every history through `(t, pre m)` is one of
`m + 1` canonical histories, and `HitCl` at the seam is their finite union — for a GENERAL `τ`
with `τ.state t = .pre m`.

**Tasks**:
- [x] Write the header docstring (`/- … -/` before the imports, modeled on
      `hit-presented-model-a.lean`'s and `node-cell-stabilization.lean`'s) with these sections,
      in this order, leaving the "What `hitPresented_node` does NOT say" and "Axiom record"
      sections as placeholders to be finalized in Phase 8:
      - Title line: "Probe 759 (requirement (C)'s Hit-level hypothesis on a ⊡-bearing alphabet
        at an infinite-width seam, on the one-region fixture): POSITIVE — `HitPresented` holds
        at every pre-seam `(t, pre m)` of `NoFiniteWidth.M` for the fixture's witness `Φ` at
        every depth `k ≥ 1`, with the presentation size `windowN m k + 5` EXHIBITED as a count,
        uniform over every seam index."
      - **Formula**: `Φ' := Φ` (the fixture witness), fallback `D`, then `⊡Xp` — recorded in that
        order; `Φ` chosen; `cl Φ` has 28 members and carries all four `⊡`-letters of the fixture.
      - **Which headline**: positive. The negative `not_hitPresented_node` is FALSE on `Node` at
        every seam for every `Φ'`: the seam fibre is finite (`through_pre`: exactly `m + 1`
        histories through `(t, pre m)`), so trace-level `Presented` holds at window `m`
        (`presented_node`) and `hitPresented_of_presented` would already give `HitPresented`.
        No Stage 0 ruling arises from this probe. Nothing here bears on
        `Probe735.not_presented`, whose fixture has an infinite seam fibre.
      - **The fixture**: `NoFiniteWidth.M` on `F` (library module, imported — regular by
        `F_isRegular`; every history canonical by `hist_canon`); cites `histOf`, `histOf_state`,
        `canon_of_lt/self/gt`, `truth_p/Fp/Pp/Xp`, `Φ_true`, `box_global`,
        `seamOmegaEquiv`, `spliced`, `hitCl_eq_iUnion`, `mem_hitOf_iff`,
        `kTypeOf_listSeg_replicate_eventually_periodic_bounded`,
        `familyTriples_subset_deleteRun`, `segZ_const_of_kTypeOf_eq_replicate` and re-proves
        none of them. `Probe758`'s truth lemmas are transcribed, not imported.
      - **The argument, in three sentences**: seam classification; four letter classes; model-A
        truncation (`W0_le_seam`/`run_lt_W1` containment is a fixture fact; shrink by `p`;
        strong induction into the window); then a one-gadget presentation whose anchored runs
        trace exactly `{c_i : i ≤ L}`.
      - **Bound verdict**: `windowN m k = min m (W + 1)`, `card_QN_le`: a COUNT of states and of
        depth-`k` types, in `AnchorLayer.lean`'s words as model A quotes them; uniform in `m`;
        not a complexity bound of any kind; no minimality claimed.
      - **What `Node` does and does NOT test**: first `HitPresented` positive on a ⊡-bearing
        alphabet and on an infinite-width model; but its seam fibres are FINITE, so it does not
        test the truncation argument's necessity (model A, with infinitely many splices through
        `(t, a)`, did); a future Hit-level falsifier for (C) needs a seam with infinitely many
        histories through it. The truncation here buys the uniform count, not satisfiability.
      - **Guardrails (a)–(e)**: (a) alphabet `clSig Φ`, 28 closure letters plus `now`,
        closure-indexed; (b) `Node` has infinite width and the probe adds no finiteness — the
        finiteness USED is of the seam fibre, a property of this fixture's states, not a
        hypothesis; (c) `windowN`, `card_QN`, `card_QN_le` count states and types, never a running
        time, never `∃ L`; (d) zero debt — no automata library, no Büchi/MSO citation, no cslib
        require, no sorry/axiom/vacuous definition; (e) forward-only — the `Pp`/`⊡Pp`/`⊡¬Pp`
        letters of `cl Φ` are read off canonical histories as closure DATA, nothing here is a
        backward Bool-fixture bridge or bears on deciding `⊡(Pp)`, and `⊡`-letters are not
        claimed to discriminate between devices. One fixture, every pre-seam; nothing about
        general regular `ℤ`-models or `PlusValidZTime`.
      - Compile line: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`.
- [x] Imports and opens exactly as the prototype: `import FormalSystem`; the five `open` lines
      (`FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage`;
      `FormalSystem.Metalogic.Decidability`;
      `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth`;
      `FormalSystem.Metalogic.Decidability.RaySummary`;
      `FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness`);
      `namespace Probe759`; `#guard (plusSubformulaClosure Φ).card = 28`.
- [x] Section `/-! ## Which histories pass through the pre-seam -/`: port from the prototype
      `seam_state (m) (t) : (histOf m (t + 1)).state t = .pre m`,
      `through_pre (h : σ.state z = .pre m) : ∃ i, i ≤ m ∧ ∀ s, σ.state s = canon (m - i) (z + 1 + i) s`,
      `canon_through (m i) (hi : i ≤ m) (t) : (histOf (m - i) (t + 1 + i)).state t = .pre m`.
- [x] Section `/-! ## HitCl depends on the seam only through its state -/`: port
      `spliced_state`, `exists_splice_eq`; add
      `hitCl_eq_through (τ) : HitCl M τ t Φ k = ⋃ σ ∈ {σ : WorldHistory F | σ.state t = τ.state t}, familyTriples (clSig Φ) k (clTrace M Φ t σ)`
      (from `hitCl_eq_iUnion`, `spliced_state`, `exists_splice_eq`), and the general-`τ`
      `hitCl_pre (τ) (hτ : τ.state t = .pre m) : HitCl M τ t Φ k = ⋃ i ∈ Finset.range (m + 1), familyTriples (clSig Φ) k (clTrace M Φ t (histOf (m - i) (t + 1 + i)))`
      (rewrite with `hitCl_eq_through`, `hτ`, then `through_pre`/`canon_through` and
      `WorldHistory.ext_state` as the prototype's `hitCl_pre` does).
- [x] `end Probe759`; temporary `#print axioms Probe759.hitCl_pre`; compile; `git add` the file
      and commit with `.claude/scripts/git-commit-scoped.sh` (explicit path).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Header skeleton ~110–140 lines plus ~90 lines of Lean (prototype's 114
less its `#eval`/`#check` scaffolding, plus `hitCl_eq_through` and the general-`τ` `hitCl_pre`).
Confirm with `wc -l`; a figure outside 180–280 is a signal to re-check, not a defect.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`
exiting 0 is the complete covering check — the file sits outside the Lake build graph, nothing
imports it, and no library module is modified.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` - new probe file: header skeleton, seam classification, `hitCl_eq_through`, `hitCl_pre`

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` exits 0 with
  zero `error` lines; `#print axioms Probe759.hitCl_pre` reads
  `[propext, Classical.choice, Quot.sound]`.
- `#guard (plusSubformulaClosure Φ).card = 28` passes (re-derived, not carried).
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` exits 0.

---

### Phase 2: Fixture Truth Lemmas and the Four Letter Vectors [COMPLETED]

**Goal**: Transcribe from `node-cell-stabilization.lean` the closure-truth lemmas on canonical
histories, and define the four computable letter vectors over `(clSig Φ).preds` with their
distinguishing entries.

**Tasks**:
- [x] Section `/-! ## The closure letters on a canonical history (transcribed) -/`: transcribe
      verbatim from `Probe758` (names kept): `truth_A'`, `truth_C'`, `truth_D` (box letters
      global via `box_global` + `Φ_true`); within `section Canon` with
      `variable {σ} {k} {t} (hσ : ∀ s, σ.state s = canon k t s)` / `include hσ`:
      `truth_stabFp (s) : … ↔ s < t`, `truth_stabPp : … ↔ t < s`, `truth_stabNegPp : … ↔ s ≤ t`,
      `truth_stabNegXp : … ↔ t ≤ s`. Do NOT transcribe `SameClass`, `truth_transfer`,
      `tpOf_eq_of`, `through_post`, `through_x`, or any cell lemma.
- [x] Section `/-! ## The four letter classes -/`: define the four member lists
      `T₂ T₁ T₀ T₋ : List PlusFormula` *(deviation: altered — `₋` (U+208B) is not a Lean identifier character; the negative-class list and vector are named `Tₙ`/`ℓₙ`)* — the closure members true in class `d ≥ 2`, `d = 1`,
      `d = 0`, `d < 0` respectively (`d := t' - s`), determined by the truth table of the
      primitives (`p`: F F T F; `Fp`: T T F F; `Pp`: F F F T; `Xp`: F T F F; `⊡Fp`: T T F F;
      `⊡Pp`: F F F T; `⊡¬Pp`: T T T F; `⊡¬Xp`: F F T T; `A'`, `C'`, `D`, `⊤`: T T T T; `⊥`:
      F F F F; composites by their connectives) — and the vectors
      `ℓ₂ ℓ₁ ℓ₀ ℓ₋ : (clSig Φ).preds → Bool` each `| .inl ψ => decide (ψ.1 ∈ T_) | .inr () => false`
      (the prototype's `ℓtest` pattern, computable).
- [x] `letterAt (d : ℤ) : (clSig Φ).preds → Bool := if 2 ≤ d then ℓ₂ else if d = 1 then ℓ₁ else if d = 0 then ℓ₀ else ℓ₋`,
      with `letterAt_now (d) : letterAt d (clNow Φ) = false`.
- [x] Closure-membership facts for the discriminating letters, by `decide`:
      `cl_Fp : Fp ∈ plusSubformulaClosure Φ`, `cl_Xp`, `cl_p`, `cl_Pp`; and the distinguishing
      entries `ℓ₂_Fp : ℓ₂ (clLetter Φ cl_Fp) = true`, `ℓ₋_Fp : ℓ₋ (clLetter Φ cl_Fp) = false`,
      `ℓ₂_Xp = false`, `ℓ₁_Xp = true`, `ℓ₀_p = true`, `ℓ₁_p = false`, `ℓ₋_p = false`
      (by `simp [ℓ₂, …]`/`decide`), plus `now_ne_Fp : clNow Φ ≠ clLetter Φ cl_Fp :=
      clNow_ne_clLetter Φ cl_Fp` and the three others.
- [x] Compile; commit.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~90 lines transcribed (758's lines 85–175) plus ~80 lines of lists and
vectors; the lists have 28 candidates each. Confirm the lists' lengths with `#eval T₂.length`
etc. during authoring (expected: each a sublist of the 28 members; exact lengths are the
implementer's to read off, not carried here).

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`
exiting 0 is the complete covering check — single out-of-graph file, no library edit.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` - truth lemmas, `T₂ T₁ T₀ T₋`, `ℓ₂ ℓ₁ ℓ₀ ℓ₋`, `letterAt`, membership and entry facts

**Verification**:
- `lake env lean …/hit-presented-node.lean` exits 0 with zero `error` lines.
- `#eval ℓ₂ (clLetter Φ cl_Fp)` prints `true`; `#eval ℓ₋ (clLetter Φ cl_Fp)` prints `false`
  (live `#eval`s may be kept or removed; the `theorem` entries above are the record).

---

### Phase 3: The Letter Bridge `clTrace_canon_apply` [COMPLETED]

**Goal**: Prove that the closure trace of any canonical history is exactly the `letterAt`
read-out plus the `now` bit — the per-class bridge that makes every later trace equation a
pointwise `omega` check. This is the cost driver; the compile check is the verification.

**Tasks**:
- [x] Four class lemmas, one shared skeleton each (`truth_transfer`'s `simp only` call with the
      truth lemmas unfolded first; `forall_eq`; `List.mem_cons`; `decide`-evaluated membership):
      `truth_class₂ (hσ : ∀ s, σ.state s = canon k' t' s) (s) (hd : 2 ≤ t' - s) : ∀ ψ ∈ plusSubformulaClosure Φ, (PlusTruthAt M σ s ψ ↔ ψ ∈ T₂)`,
      `truth_class₁ (hd : t' - s = 1)`, `truth_class₀ (hd : t' - s = 0)`, `truth_class₋ (hd : t' - s < 0)`. *(deviation: altered — the negative class lemma is `truth_classₙ` (identifier constraint, as `Tₙ`/`ℓₙ`); a `letter_cases` exhaustion helper and the four `letterAt_of_*` selectors were added so the bridge and read-outs are `rw` + `omega`; `truth_class₀` substitutes `s = t'` rather than feeding it to `simp`)*
- [x] `clTrace_canon_apply (k' : ℕ) (t t' : ℤ) (ℓ : (clSig Φ).preds) (z : ℤ) : clTrace M Φ t (histOf k' t') ℓ z ↔ (ℓ = clNow Φ ∧ z = t) ∨ letterAt (t' - z) ℓ = true`
      — `rcases ℓ with ⟨ψ, hψ⟩ | ⟨⟩`; the `now` case is `clTrace`'s `.inr` branch and
      `letterAt_now`; the letter case splits on the class of `t' - z` and applies the class lemma
      with `histOf_state`.
- [x] `clTrace_canon_eq (k' t t') : clTrace M Φ t (histOf k' t') = fun ℓ z => (ℓ = clNow Φ ∧ z = t) ∨ letterAt (t' - z) ℓ = true`
      (`funext`, `propext`, `clTrace_canon_apply`), and its corollary
      `clTrace_canon_thread_free (k₁ k₂ t t') : clTrace M Φ t (histOf k₁ t') = clTrace M Φ t (histOf k₂ t')`.
- [x] Define `cN (t : ℤ) (i : ℕ) : (clSig Φ).preds → ℤ → Prop := clTrace M Φ t (histOf 0 (t + 1 + i))`
      and restate `hitCl_pre` as
      `hitCl_pre' (τ) (hτ) : HitCl M τ t Φ k = ⋃ i ∈ Finset.range (m + 1), familyTriples (clSig Φ) k (cN t i)`
      via `clTrace_canon_thread_free`.
- [x] Positional read-outs used by Phases 4 and 7, all from `clTrace_canon_apply` + `omega`:
      `cN_below (i) (z) (hz : z < t) (ℓ) : cN t i ℓ z ↔ ℓ₂ ℓ = true`;
      `cN_seam_zero (ℓ) : cN t 0 ℓ t ↔ ℓ = clNow Φ ∨ ℓ₁ ℓ = true`;
      `cN_seam_pos (i) (hi : 1 ≤ i) (ℓ) : cN t i ℓ t ↔ ℓ = clNow Φ ∨ ℓ₂ ℓ = true`;
      `cN_run (i) (z) (hz : t + 1 ≤ z) (hz' : z < t + i) (ℓ) : cN t i ℓ z ↔ ℓ₂ ℓ = true`;
      `cN_one (i) (ℓ) : cN t i ℓ (t + i) ↔ ℓ₁ ℓ = true` (for `1 ≤ i`; and `cN t 0 ℓ t` handled above);
      `cN_zero (i) (ℓ) : cN t i ℓ (t + i + 1) ↔ ℓ₀ ℓ = true`;
      `cN_above (i) (z) (hz : t + i + 1 < z) (ℓ) : cN t i ℓ z ↔ ℓ₋ ℓ = true`.
- [x] Compile; commit.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 250–350 lines (report's estimate for this section, from model A's 100-line
five-letter read-out scaled to 28 letters and four classes). If a class lemma's `simp only`
leaves residue, inspect with `lean_goal` and add the missing truth unfolding rather than
switching tactic families; if the lists approach proves stubborn after one honest attempt, use
the report's fallback (a decidable evaluator on closure syntax) and record the deviation in
`issues.jsonl` — it changes no statement.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`
exiting 0 is the complete covering check — single out-of-graph file, no library edit.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` - four class lemmas, `clTrace_canon_apply`, `clTrace_canon_eq`, `clTrace_canon_thread_free`, `cN`, `hitCl_pre'`, positional read-outs

**Verification**:
- `lake env lean …/hit-presented-node.lean` exits 0 with zero `error` lines.
- `#print axioms Probe759.clTrace_canon_apply` reads `[propext, Classical.choice, Quot.sound]`
  (no `sorryAx`).

---

### Phase 4: Containment, `deleteRun`, and the Shrink [COMPLETED]

**Goal**: Discharge on `Node` the three hypotheses of `familyTriples_subset_deleteRun` for the
`ℓ₂`-run of `cN t i`: containment in the middle segment of EVERY factorization (`k ≥ 1`),
constancy, and the pointwise `deleteRun` identity; conclude the shrink `cN t (i + p) → cN t i`.

**Tasks**:
- [x] Section `/-! ## The ℓ₂-run inside the middle segment -/` with the model-A docstring adapted
      (keystone twice; depth `k ≥ 1` consumed at the keystone).
- [x] `W0_le_seam (k) (hk : 1 ≤ k) (t) (i) (F : SegmentFactorization (clSig Φ) k (cN t i)) : F.W 0 ≤ t`
      — transcribe model A's `W0_le_seam` with `ℓ₂` for `ℓ₀`, `cN_below` for
      `clTrace_jump_letter_below`, and `now ∉ ℓ₂` via `letterAt_now`/`ℓ₂ (clNow Φ) = false`.
- [x] `run_lt_W1 (k) (hk) (t) (i) (hi : 2 ≤ i) (F : SegmentFactorization (clSig Φ) k (cN t i)) : t + i - 1 < F.W 1`
      — the ADJUSTED `seam_lt_W1`: by contradiction `F.W 1 ≤ t + i - 1`, so `t + i - 1` lies in a
      positive segment `zp` (`F.cover`, `F.mono`); obtain `z₁` covering `t + i + 2`, then `z₂`
      covering `F.W (z₁ + 1)` with `z₁ + 1 ≤ z₂`; the segment `[F.W z₂, F.W (z₂ + 1))` lies
      entirely above `t + i + 1` and reads `ℓ₋` throughout (`cN_above`), is nonempty, and fixes
      `τpos` (`kTypeOf_segZ_eq_replicate_of_const`, `F.pos_type`); the keystone
      `segZ_const_of_kTypeOf_eq_replicate hk` then makes segment `zp` constantly `ℓ₋`, but
      `t + i - 1` reads `ℓ₂` (`cN_run`, since `t + 1 ≤ t + i - 1 < t + i` needs `2 ≤ i`) and
      `ℓ₂ Fp = true ≠ ℓ₋ Fp = false` (`ℓ₂_Fp`, `ℓ₋_Fp`).
- [x] `run_subset_middle (k) (hk) (t) (i) (hi : 2 ≤ i) (F) : F.W 0 ≤ t + 1 ∧ t + 1 + (i - 1 : ℕ) ≤ F.W 1`
      (from the two above; `omega` with the cast).
- [x] `deleteRun_cN (t) (i p : ℕ) (hi : 1 ≤ i) : deleteRun (cN t (i + p)) (t + 1) p = cN t i`
      — `funext ℓ u; propext`; `deleteRun_of_lt`/`deleteRun_of_le`; `clTrace_canon_apply` on
      both sides; the relative positions `(t + 1 + (i + p)) - (u + p) = (t + 1 + i) - u` and the
      `now` conditions close by `omega` (model A's `deleteRun_clTrace_jump`, with `cN`).
- [x] `familyTriples_cN_shrink (k) (hk) (t) (m₀ p : ℕ) (hper : ∀ n, m₀ ≤ n → kTypeOf (clSig Φ) k (listSeg (List.replicate (n + p) ℓ₂)) = kTypeOf (clSig Φ) k (listSeg (List.replicate n ℓ₂))) (i : ℕ) (hi : m₀ + 1 ≤ i) (h2 : 2 ≤ i) : familyTriples (clSig Φ) k (cN t (i + p)) ⊆ familyTriples (clSig Φ) k (cN t i)`
      — `rw [← deleteRun_cN t i p]`; `familyTriples_subset_deleteRun k _ (t + 1) ℓ₂ (i - 1 + p) p m₀ …`
      with containment from `run_subset_middle` at `z₀ = 0` and constancy from `cN_run`.
- [x] Compile; commit.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~160 lines (model A's lines 610–735 re-measured as the template, plus the
two-hop cover). Confirm with `wc -l` on the section.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`
exiting 0 is the complete covering check — single out-of-graph file, no library edit.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` - `W0_le_seam`, `run_lt_W1`, `run_subset_middle`, `deleteRun_cN`, `familyTriples_cN_shrink`

**Verification**:
- `lake env lean …/hit-presented-node.lean` exits 0 with zero `error` lines.
- `#print axioms Probe759.familyTriples_cN_shrink` reads `[propext, Classical.choice, Quot.sound]`.
- `hk` is a used hypothesis of `W0_le_seam` and `run_lt_W1` (no `unusedVariables` warning on
  it): depth is consumed at the keystone, as on model A.

---

### Phase 5: The Truncation Bound and the Exhibited Counts [COMPLETED]

**Goal**: Replace the `m + 1`-fold union by the window `windowN m k = min m (W + 1)`, and state
the counts `card_QN`, `card_QN_le`.

**Tasks**:
- [x] `noncomputable abbrev windowN (m k : ℕ) : ℕ := min m (Nat.card (KType (clSig Φ) k) + 1)`
      with the count disclaimer docstring in `AnchorLayer.lean`'s words as model A's
      `presentationSize` quotes them, binding "depth-`k` types" for "cells"; never `#eval`-ed.
- [x] `abbrev QN (L : ℕ) := Fin (L + 5)`; `theorem card_QN (L) : Fintype.card (QN L) = L + 5`
      (`Fintype.card_fin`); `theorem card_QN_le (m k) : Fintype.card (QN (windowN m k)) ≤ Nat.card (KType (clSig Φ) k) + 6`
      (`card_QN`, `min_le_right`, `omega`); `#guard Fintype.card (QN 2) = 7`.
- [x] `hitCl_eq_truncated_node (t) (m k) (hk : 1 ≤ k) (τ) (hτ : τ.state t = .pre m) : HitCl M τ t Φ k = ⋃ i ∈ Finset.range (windowN m k + 1), familyTriples (clSig Φ) k (cN t i)`
      — obtain `⟨m₀, p, hp, hle, hper⟩ := kTypeOf_listSeg_replicate_eventually_periodic_bounded (clSig Φ) k ℓ₂`;
      `reduce : ∀ i x, x ∈ familyTriples … (cN t i) → ∃ i' ≤ windowN m k, i' ≤ i ∧ x ∈ familyTriples … (cN t i')`
      by `Nat.strong_induction_on`: if `i ≤ windowN m k` done; else `i > min m (W + 1)` — and
      since `i ≤ m` on the left (from `hitCl_pre'`) the case is `i > W + 1 ≥ m₀ + p + 1`, so
      `i - p ≥ m₀ + 1`, `i - p ≥ 2`, and `familyTriples_cN_shrink` applies with `i := i - p`;
      `⊆` from `hitCl_pre'` + `reduce`; `⊇` from `hitCl_pre'` since `windowN m k ≤ m`
      (`min_le_left`). Keep `i' ≤ i` in `reduce` so the `i ≤ m` bound is carried.
- [x] Compile; commit.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~80 lines for the truncation plus ~30 for the counts (model A's lines
735–852 as template). Confirm with `wc -l`.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`
exiting 0 is the complete covering check — single out-of-graph file, no library edit.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` - `windowN`, `QN`, `card_QN`, `card_QN_le`, `hitCl_eq_truncated_node`

**Verification**:
- `lake env lean …/hit-presented-node.lean` exits 0; `#guard Fintype.card (QN 2) = 7` passes.
- `#print axioms Probe759.hitCl_eq_truncated_node` reads `[propext, Classical.choice, Quot.sound]`.
- The statement of `hitCl_eq_truncated_node` contains `windowN m k` and no `∃`.

---

### Phase 6: Presentation Data `labN`/`stepN` and the Labelling Bridge [NOT STARTED]

**Goal**: Define the one-gadget presentation on `QN L` whose anchored runs will trace exactly
`{cN t i : i ≤ L}`, and prove the labelling bridge from `labN` to the four letter vectors.

**Index table (binding)**, on `QN L = Fin (L + 5)`:

| index | name | letter | `now` | successors |
|-------|------|--------|-------|------------|
| 0 | `A` | `ℓ₂` | no | 0, 1, 2 |
| 1 | `N₀` | `ℓ₁` | YES | 3 |
| 2 | `N₊` | `ℓ₂` | YES | every `j` with `5 ≤ j` (none when `L = 0`) |
| 3 | `Z` | `ℓ₀` | no | 4 |
| 4 | `P` | `ℓ₋` | no | 4 |
| `4 + j`, `1 ≤ j < L` | `C_j` | `ℓ₂` | no | `5 + j` |
| `L + 4` (only when `1 ≤ L`) | `C_L` | `ℓ₁` | no | 3 |

Anchored runs (`IsRun`: `now` exactly at `t`): `A^(ω*)·N₀·Z·P^ω` traces `cN t 0`;
`A^(ω*)·N₊·C_j·C_(j+1)·…·C_L·Z·P^ω` (entering at `C_j`, `1 ≤ j ≤ L`) reads `ℓ₂` on
`[t + 1, t + (L - j)]`, `ℓ₁` at `t + (L - j) + 1`, `ℓ₀` next, `ℓ₋` after — i.e. `cN t i` with
`i = L - j + 1 ∈ [1, L]`. No chain state has a self-loop, so a run entering the chain reaches `Z`
within `L` steps; the only predecessor of `N₀`, `N₊` and `A` is `A`.

**Tasks**:
- [ ] `def stepN (L : ℕ) : QN L → QN L → Bool := fun q r => decide ((q.val = 0 ∧ r.val ≤ 2) ∨ (q.val = 1 ∧ r.val = 3) ∨ (q.val = 2 ∧ 5 ≤ r.val) ∨ (5 ≤ q.val ∧ q.val < L + 4 ∧ r.val = q.val + 1) ∨ (5 ≤ q.val ∧ q.val = L + 4 ∧ r.val = 3) ∨ (q.val = 3 ∧ r.val = 4) ∨ (q.val = 4 ∧ r.val = 4))`.
- [ ] `def isNowN (L) (q : QN L) : Bool := decide (q.val = 1 ∨ q.val = 2)`;
      `def vecN (L) (q : QN L) : (clSig Φ).preds → Bool := if q.val = 1 then ℓ₁ else if q.val = 3 then ℓ₀ else if q.val = 4 then ℓ₋ else if 5 ≤ q.val ∧ q.val = L + 4 then ℓ₁ else ℓ₂`
      (order matters: index 4 is `P` before the `L + 4` test, so `L = 0` cannot collide);
      `def labN (L) : QN L → (clSig Φ).preds → Bool := fun q ℓ => if ℓ = clNow Φ then isNowN L q else vecN L q ℓ`.
      All three are `def`, never `noncomputable`; `#eval labN 2 ⟨1, by omega⟩ (clNow Φ)` as a
      live check (`true`).
- [ ] Bridge lemmas: `labN_now (L q) : labN L q (clNow Φ) = true ↔ q.val = 1 ∨ q.val = 2`;
      `labN_letter (L q) (ℓ) (hℓ : ℓ ≠ clNow Φ) : labN L q ℓ = vecN L q ℓ`;
      `vecN_A`, `vecN_N₀`, `vecN_N₊`, `vecN_Z`, `vecN_P`, `vecN_chain (hj : 5 ≤ q.val) (hj' : q.val < L + 4) : vecN L q = ℓ₂`,
      `vecN_last (hL : 1 ≤ L) (h : q.val = L + 4) : vecN L q = ℓ₁`.
- [ ] Step-table read-outs: `stepN_pred_now (h : stepN L q r = true) (hr : r.val = 1 ∨ r.val = 2) : q.val = 0`;
      `stepN_pred_A (h) (hr : r.val = 0) : q.val = 0`; `stepN_N₀ (h) (hq : q.val = 1) : r.val = 3`;
      `stepN_N₊ (h) (hq : q.val = 2) : 5 ≤ r.val`; `stepN_chain (h) (hq : 5 ≤ q.val) : (q.val < L + 4 ∧ r.val = q.val + 1) ∨ (q.val = L + 4 ∧ r.val = 3)`;
      `stepN_Z (h) (hq : q.val = 3) : r.val = 4`; `stepN_P (h) (hq : q.val = 4) : r.val = 4`
      — each by `simp only [stepN, decide_eq_true_eq] at h; omega`.
- [ ] Compile; commit.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~150 lines (model A's two-gadget section 852–1092 is ~240; one gadget
with index-arithmetic conditions is smaller). Confirm with `wc -l`.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`
exiting 0 is the complete covering check — single out-of-graph file, no library edit.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` - `stepN`, `isNowN`, `vecN`, `labN`, bridge and step read-out lemmas

**Verification**:
- `lake env lean …/hit-presented-node.lean` exits 0 with zero `error` lines.
- `#print axioms Probe759.labN` and `#print axioms Probe759.stepN` show no `sorryAx` (expected
  `[propext]` or fewer, as model A's `stepOf`).
- `labN`/`stepN` are `def` (grep `noncomputable def labN` prints nothing).

---

### Phase 7: The Run Characterization [NOT STARTED]

**Goal**: Identify the presentation's anchored runs with exactly `{cN t i : i ≤ L}` — the `⊆`
direction (every anchored run traces some `cN t i`, `i ≤ L`) and the `⊇` direction (every
`cN t i`, `i ≤ L`, is the trace of an anchored run).

**Tasks**:
- [ ] Section docstring: the excluded run shapes and the lemma discharging each (a run never
      leaving `A` — `IsRun`'s `now` clause; a run passing `N₊` when `L = 0` — `stepN_N₊` gives
      `5 ≤ r.val < 5`; a loop inside the chain — `stepN_chain` strictly increases the index).
- [ ] Backward rigidity: `run_bwd_A (L) {ρ} (hρ : IsRun (labN L) (stepN L) (clNow Φ) t ρ) : ∀ z, z < t → (ρ z).val = 0`
      (from `labN_now` at `t`, `stepN_pred_now`, then downward induction with `stepN_pred_A`;
      model A's `inl_bwd_pre`).
- [ ] Forward determinism after `N₀`: `run_after_N₀ (hρ) (h : (ρ t).val = 1) : (ρ (t + 1)).val = 3 ∧ ∀ z, t + 2 ≤ z → (ρ z).val = 4`.
- [ ] Forward chain after `N₊`: `run_after_N₊ (hρ) (h : (ρ t).val = 2) : ∃ j, 5 ≤ j ∧ j ≤ L + 4 ∧ (∀ a : ℕ, j + a ≤ L + 4 → (ρ (t + 1 + a)).val = j + a) ∧ (ρ (t + 1 + ((L + 4 - j : ℕ) : ℤ) + 1)).val = 3 ∧ ∀ z, t + 1 + ((L + 4 - j : ℕ) : ℤ) + 2 ≤ z → (ρ z).val = 4`
      (model A's `inr_fwd_index`/`inr_post_threshold`; `j := (ρ (t + 1)).val` via `stepN_N₊`,
      which also yields `1 ≤ L`).
- [ ] `runTrace_mem_of_isRun (t) (L) (ρ) (hρ : IsRun (labN L) (stepN L) (clNow Φ) t ρ) : ∃ i, i ≤ L ∧ runTrace (labN L) ρ = cN t i`
      — case on `(ρ t).val ∈ {1, 2}` (`labN_now`, `hρ.2 t`); `i := 0` or `i := L - j + 5`
      (so that `i - 1 = L + 4 - j`); `funext ℓ z; propext`; compare `labN L (ρ z) ℓ` against the
      positional read-outs `cN_below`, `cN_seam_zero`/`cN_seam_pos`, `cN_run`, `cN_one`,
      `cN_zero`, `cN_above` by cases on `z`'s position (`omega`).
- [ ] Witness runs: `def runZero (t) (z : ℤ) : QN L` (`A` below `t`, `N₀` at `t`, `Z` at `t + 1`,
      `P` after), `runZero_isRun`, `runTrace_runZero : runTrace (labN L) (runZero t) = cN t 0`;
      `def runPos (L) (t) (i : ℕ) (z : ℤ) : QN L` for `1 ≤ i ≤ L` (`A` below `t`, `N₊` at `t`,
      `C_(L - i + 1 + a)` at `t + 1 + a` for `a < i`, i.e. index `L + 5 - i + a`, `Z` at
      `t + i + 1`, `P` after), `runPos_isRun (hi : 1 ≤ i) (hiL : i ≤ L)`,
      `runTrace_runPos : runTrace (labN L) (runPos L t i) = cN t i`.
- [ ] `exists_isRun_runTrace (t) (L) : ∀ i, i ≤ L → ∃ ρ : ℤ → QN L, IsRun (labN L) (stepN L) (clNow Φ) t ρ ∧ runTrace (labN L) ρ = cN t i`.
- [ ] Compile; commit.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~350 lines (model A's run characterization 1092–1503 is ~410 across two
gadgets). Confirm with `wc -l`; if the section exceeds 450 lines, check for duplicated case
analyses rather than treating it as a defect.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`
exiting 0 is the complete covering check — single out-of-graph file, no library edit.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` - rigidity lemmas, `runTrace_mem_of_isRun`, `runZero`, `runPos`, `exists_isRun_runTrace`

**Verification**:
- `lake env lean …/hit-presented-node.lean` exits 0 with zero `error` lines.
- `#print axioms Probe759.runTrace_mem_of_isRun` and `#print axioms Probe759.exists_isRun_runTrace`
  read `[propext, Classical.choice, Quot.sound]` (no `sorryAx`).

---

### Phase 8: Assembly — Headline, Corollary, `presented_node`, Header Finalization [NOT STARTED]

**Goal**: Compose the headline from `hitCl_eq_truncated_node`, `mem_hitOf_iff` and the run
characterization; state the corollary and the by-product; write the "does NOT say" section and
the OBSERVED axiom record; close the `#print axioms` foot.

**Tasks**:
- [ ] `theorem hitPresented_node (t : ℤ) (m k : ℕ) (hk : 1 ≤ k) (τ : WorldHistory F) (hτ : τ.state t = .pre m) : HitPresented M τ t Φ (labN (windowN m k)) (stepN (windowN m k)) k`
      — `have hL := hitCl_eq_truncated_node t m k hk τ hτ; set L := windowN m k; show HitCl M τ t Φ k = ↑(hitOf (labN L) (stepN L) (clNow Φ) k); rw [hL]; ext x; rw [Finset.mem_coe, mem_hitOf_iff (labN L) (stepN L) (clNow Φ) k t hk x]`;
      `⊆` via `exists_isRun_runTrace`, `⊇` via `runTrace_mem_of_isRun` (model A's assembly
      verbatim in shape; `hk` consumed at `mem_hitOf_iff` and inside the truncation).
- [ ] `theorem hitPresented_node_canon (t : ℤ) (k : ℕ) (hk : 1 ≤ k) : HitPresented M (histOf k (t + 1)) t Φ (labN (windowN k k)) (stepN (windowN k k)) k := hitPresented_node t k k hk _ (seam_state k t)`
      — the dispatch's single-`k` shape, with its docstring saying so.
- [ ] `theorem presented_node (t : ℤ) (m : ℕ) (τ : WorldHistory F) (hτ : τ.state t = .pre m) : Presented M τ t Φ (labN m) (stepN m)`
      — `intro c`; LHS `↔ ∃ i ≤ m, c = cN t i` (`spliced_state`/`exists_splice_eq`, `hτ`,
      `through_pre`/`canon_through`, `clTrace_canon_thread_free`); RHS `↔ ∃ i ≤ m, c = cN t i`
      (`runTrace_mem_of_isRun`, `exists_isRun_runTrace` at `L := m`). Docstring: the by-product
      and the reason the negative headline is unavailable; NOT the headline's route; `Node` does
      not separate `Presented` from `HitPresented`, model A remains the only separation; nothing
      here bears on `Probe735.not_presented`.
- [ ] Section `/-! ### What hitPresented_node does NOT say -/` (model A's bullets adapted):
      the size is a count and nothing else (`card_QN_le`; no complexity bound; no minimality;
      `k` free); one fixture, every pre-seam, one `φ`, nothing about general regular `ℤ`-models
      (H5 is a different task); the seam fibre is finite so the truncation's NECESSITY is not
      tested — a Hit-level falsifier needs an infinite seam fibre; forward-only — nothing about
      `⊡(Pp)`, no backward bridge; `⊡`-letters are not claimed to discriminate between devices;
      `Decidable (PlusValidZTime φ)` not stated in any form; `Probe735.not_presented` untouched.
- [ ] Finalize the header's "Axiom record" paragraph from the OBSERVED foot, and the `#print
      axioms` foot: `through_pre`, `hitCl_pre`, `clTrace_canon_apply`, `run_subset_middle`,
      `deleteRun_cN`, `familyTriples_cN_shrink`, `hitCl_eq_truncated_node`, `labN`, `stepN`,
      `runTrace_mem_of_isRun`, `exists_isRun_runTrace`, `card_QN_le`, `presented_node`,
      `hitPresented_node_canon`, `hitPresented_node`. Remove Phase 1's temporary foot line.
- [ ] Header read-through against Phase 1's checklist; `end Probe759`; compile; commit.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: ~150 lines; whole file 1300–1600 lines (report's estimate against model
A's 1595). Confirm with `wc -l`; a total outside 1100–1800 is a signal to re-check for dropped
or duplicated sections.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`
exiting 0 is the complete covering check — single out-of-graph file, no library edit.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` - `hitPresented_node`, `hitPresented_node_canon`, `presented_node`, "does NOT say" section, axiom record, `#print axioms` foot

**Verification**:
- `lake env lean …/hit-presented-node.lean` exits 0 with zero `error` lines; every `#print
  axioms` line reads `[propext, Classical.choice, Quot.sound]` except `labN`/`stepN`
  (`[propext]` or fewer); no `sorryAx` anywhere.
- `grep -nE "sorry|^axiom |:= (True|Unit|trivial|Trivial)\s*$" …/hit-presented-node.lean`
  prints nothing.
- The nine Goals identifiers appear with exactly the signatures of the `## Lean Challenge
  Statements` block (`bash .claude/scripts/lean-challenge-snapshot.sh --check 759 .` is
  available as an advisory drift check).
- Header read-through: formula order (`Φ`, then `D`, then `⊡Xp`), the "which headline" paragraph,
  the "does and does NOT test" paragraph, guardrails (a)–(e), the axiom record, the compile line.

---

### Phase 9: Wire the Probe, Record It in the README, and Run the Full Gate [NOT STARTED]

**Goal**: Register the probe in `scripts/check-evidence-probes.sh`, record it in the RaySummary
README, and run the complete repository gate set over the finished task.

**Tasks**:
- [ ] `scripts/check-evidence-probes.sh`: add a table row in the `# --- WIRED ---` comment table
      directly after the `seam-gluing-ray-product/node-cell-stabilization` row (the row block
      ends at the line before `WIRED=(`), in the same two-column wrapped format, headed
      `POSITIVE (requirement (C)'s Hit-level hypothesis on a ⊡-bearing alphabet at an infinite-width seam, on the one-region fixture)`
      and stating: `HitPresented` holds on `Limits/NoFiniteWidth.lean`'s `M` at every pre-seam
      `(t, pre m)` for its own witness `Φ` (fallbacks `D`, `⊡Xp` not needed; 28 closure letters
      plus `now`) at every depth `k ≥ 1` (`hitPresented_node`; the dispatch's single-index shape
      `hitPresented_node_canon`), with the size `windowN m k + 5`,
      `windowN m k = min m (Nat.card (KType (clSig Φ) k) + 1)`, EXHIBITED in the statement and
      bounded uniformly over every seam by `card_QN_le` — a count of states and depth-`k` types,
      not a complexity bound; the route (seam classification `through_pre`; four
      relative-position letter classes `clTrace_canon_apply`; containment `run_subset_middle` as
      a fixture fact; the library's periodicity and `familyTriples_subset_deleteRun`; a one-gadget
      presentation `labN`/`stepN` whose anchored runs are exactly the window); the by-product
      `presented_node` and why the negative headline is false here (finite seam fibre); what it
      does NOT say (one fixture; does not test the truncation's necessity — a Hit-level falsifier
      needs an infinite seam fibre; forward-only, nothing about `⊡(Pp)`; no finiteness added; no
      claim that `⊡`-letters discriminate between devices; nothing about `PlusValidZTime` or
      the general row). Axioms `[propext, Classical.choice, Quot.sound]`. No task number.
- [ ] Append `"seam-gluing-ray-product/hit-presented-node"` to the `WIRED=(` array immediately
      after `"seam-gluing-ray-product/node-cell-stabilization"`.
- [ ] `bash -n scripts/check-evidence-probes.sh`; run `bash scripts/check-evidence-probes.sh`
      detached with a bounded waiter (`context/patterns/bounded-build-waiter.md`); commit the
      script edit.
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `## Evidence`: insert ONE
      paragraph directly after the "A tenth wired probe, …" paragraph and before "The permanent
      computability witnesses are …", of the shape: "An eleventh wired probe,
      `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`, is the first Hit-level
      positive on a ⊡-bearing alphabet and on an infinite-width model, gate-compiled: on
      `NoFiniteWidth.M` with its own witness `Φ`, `HitPresented` holds at every pre-seam
      `(t, pre m)` at every depth `k ≥ 1` (`Probe759.hitPresented_node`), for a presentation of
      `windowN m k + 5` states with `windowN m k = min m (Nat.card (KType (clSig Φ) k) + 1)`
      exhibited in the statement and bounded uniformly over every seam (`card_QN_le`) — a count
      of states and of depth-`k` types, not a complexity bound — by the model-A truncation route
      (seam classification in place of rigidity; the fixture's four relative-position letter
      classes; `familyTriples_subset_deleteRun`), every theorem at
      `[propext, Classical.choice, Quot.sound]`, citing the fixture and re-proving nothing. The
      negative headline is false on `Node`: its seam fibres are finite (`m + 1` histories through
      `(t, pre m)`), so trace-level `Presented` holds there too (`presented_node`), and the probe
      therefore does not test the truncation argument's necessity — a Hit-level falsifier for (C)
      needs a seam with infinitely many histories through it. Forward-only; no finiteness added;
      nothing about `⊡(Pp)`, the general row, or `PlusValidZTime`."
- [ ] Two minimal in-place amendments to statements the probe makes false, no new sentences:
      in "The verdict" (C) row, "It is **one fixture**, so the general …" becomes "It is **two
      fixtures** (model A and `Node`, the latter ⊡-bearing and infinite-width — see Evidence), so
      the general …"; in "(W): what landed and what did not" obligation (ii) item 2, "Open
      mathematics with one positive fixture and no general argument" becomes "… with two positive
      fixtures and no general argument", and "`Probe745.hitPresented_modelA` is the only Hit-level
      positive, and no Hit-level negative exists anywhere in the tree" becomes
      "`Probe745.hitPresented_modelA` and `Probe759.hitPresented_node` are the Hit-level
      positives, and no Hit-level negative exists anywhere in the tree (none can on `Node`, whose
      seam fibres are finite)". Durable anchors only; no task number; no record-versioning
      language.
- [ ] Update the README's trailing `*Last verified: YYYY-MM-DD*` line to the implementation date.
- [ ] Run the final gate set (below), detached where the pattern requires, recording each exit
      status; commit the README edit; write the implementation summary per `summary-format.md`.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: At plan time `WIRED` has 27 entries and `WIRED_REPO` 1 (counted with
`awk '/^WIRED=\(/,/^\)/' … | grep -c '^  "'`), so the gate's PASS line should read
`PASS  all 29 wired probe(s) compile` after the edit. Confirm by re-counting both arrays before
and after (exactly +1) and matching the PASS line's number to the sum. The README's `## Evidence`
section currently ends its probe paragraphs at the tenth probe (lines 592–600 at plan time);
confirm the insertion point by reading the section, not by line number.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - one WIRED table row and one `WIRED=(` array entry
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - one Evidence paragraph; two in-place numeral amendments in the (C) row and obligation (ii) item 2; `Last verified` date

**Verification** (the complete gate set — every command's exit status is checked, never only its
output):
- `lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` exits 0
  (re-run after all commits; every `#print axioms` line as Phase 8 records).
- `bash -n scripts/check-evidence-probes.sh` exits 0; `bash scripts/check-evidence-probes.sh`
  exits 0 with `seam-gluing-ray-product/hit-presented-node … PASS` and the final line
  `PASS  all 29 wired probe(s) compile`.
- `bash scripts/check-module-invariants.sh` exits 0 (C9 in particular: zero task-number or
  `specs/NNN_` citations under `FormalSystem/` and `scripts/`); detached with a bounded waiter.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- `bash scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary` exits 0.
- Full `lake build` via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
  detached (`Bash(run_in_background: true)`) per
  `context/project/lean4/operations/long-builds.md`, exits 0 — expected a no-op success since
  the probe is outside the build graph and the README is markdown, but mandatory before
  `implemented`.
- Lean agent Final Verification Stage over the resolved source roots AND the probe file:
  `bash .claude/scripts/lean-sorry-census.sh` count 0 for the probe; vacuous-definition grep
  count 0; `grep -rn "^axiom "` count unchanged from baseline.
- `bash .claude/scripts/verify-deploy.sh` exits 0.
- `git status --short` shows no stray modified files outside the three in `file_scope`.

## Lean Challenge Statements

The definitional bodies of `windowN` and `QN` are part of the contract (guardrail (c): the count
is exhibited, never `∃ L`) and are therefore written out; every other body is `sorry`.

```lean
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth
open FormalSystem.Metalogic.Decidability.RaySummary
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness

namespace Probe759

noncomputable abbrev windowN (m k : ℕ) : ℕ := min m (Nat.card (KType (clSig Φ) k) + 1)

abbrev QN (L : ℕ) := Fin (L + 5)

theorem card_QN (L : ℕ) : Fintype.card (QN L) = L + 5 := sorry

theorem card_QN_le (m k : ℕ) :
    Fintype.card (QN (windowN m k)) ≤ Nat.card (KType (clSig Φ) k) + 6 := sorry

def labN (L : ℕ) : QN L → (clSig Φ).preds → Bool := sorry

def stepN (L : ℕ) : QN L → QN L → Bool := sorry

theorem hitPresented_node (t : ℤ) (m k : ℕ) (hk : 1 ≤ k) (τ : WorldHistory F)
    (hτ : τ.state t = .pre m) :
    HitPresented M τ t Φ (labN (windowN m k)) (stepN (windowN m k)) k := sorry

theorem hitPresented_node_canon (t : ℤ) (k : ℕ) (hk : 1 ≤ k) :
    HitPresented M (histOf k (t + 1)) t Φ (labN (windowN k k)) (stepN (windowN k k)) k := sorry

theorem presented_node (t : ℤ) (m : ℕ) (τ : WorldHistory F) (hτ : τ.state t = .pre m) :
    Presented M τ t Φ (labN m) (stepN m) := sorry

end Probe759
```

## Testing & Validation

- [ ] The probe compiles under the gate's own command (`lake env lean`) with 0 errors; every
      `#print axioms` line reads `[propext, Classical.choice, Quot.sound]` (`labN`/`stepN`:
      `[propext]` or fewer); no `sorryAx`.
- [ ] No `sorry`, `axiom`, or vacuous-definition pattern in the probe (grep count 0).
- [ ] `#guard (plusSubformulaClosure Φ).card = 28` and `#guard Fintype.card (QN 2) = 7` pass.
- [ ] The nine Goals identifiers match the Lean Challenge Statements block exactly
      (`lean-challenge-snapshot.sh --check 759 .` advisory).
- [ ] `check-evidence-probes.sh` reports 29 wired probes, all PASS.
- [ ] `check-module-invariants.sh`, `check-task-references.sh`, `readme-lint.sh`,
      `verify-deploy.sh` and the guarded full `lake build` all exit 0.
- [ ] Header read-through: formula order, "which headline" paragraph, "does and does NOT test"
      paragraph, guardrails (a)–(e), count disclaimer, axiom record, compile line.

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` (new, tracked, wired)
- `scripts/check-evidence-probes.sh` (one table row, one `WIRED` entry)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (one Evidence paragraph, two
  in-place amendments, `Last verified` date)
- `specs/759_node_hit_presented_probe/summaries/01_node-hit-presented-probe-summary.md`

## Rollback/Contingency

- Each phase appends compiled sections to one file and commits per green substep; reverting a
  phase is reverting its commit(s). If Phase 9's gate run fails on the new entry, remove the
  entry and row (the probe file stays, unwired) rather than weakening any statement. A genuine
  rollback of uncommitted work follows `context/contracts/recovery.md`'s rollback rung.
- If a section does not compile, compare against its template — the prototype for Phase 1,
  `node-cell-stabilization.lean` for Phase 2, `hit-presented-model-a.lean` for Phases 3–8 —
  and do not re-derive proofs or substitute a different decomposition (`plan-compliance.md`).
  The Phase 3 fallback (decidable evaluator) changes no statement and is the one sanctioned
  tactic-level substitution.
- The research has exhibited a sorry-free route and the prototype compiles, so a `[BLOCKED]`
  outcome is not expected. Should a statement nonetheless fail to close as written, the task's
  own rule applies: record the goal state in the header as the obstruction, mark the phase
  `[BLOCKED]`, never a `sorry`, axiom, vacuous definition, or finiteness hypothesis — and never
  weaken a recorded Challenge statement.
