# Research Report: Task #90 — bx_le Redefinition Decision

**Task**: Decide between Option A (redefine `bx_le` via Until-witnesses) and Option B (Henkin-closure enrichment) for closing 4 Until/Since truth-lemma sorries in `BXCanonical/Frame.lean`
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates)
**Session**: `sess_res90`

---

## Summary

**Recommendation: Option B**, reframed as *"Burgess–Xu Until-induction on the existing `bx_le := g_content ⊆` ordering using BX5+BX6+BX7+BX9+BX10+BX11+BX12"*.

However, **before committing task 92 to Option B**, execute a cheap diagnostic
prerequisite: attempt to prove `bx_le_linear` (or interval linearity) directly
from BX7+BX11+BX12. Unanimous team finding: **BX11 (`temp_linearity`) is
already present** at `Axioms.lean:240-244`, and **BX12 (`F_until_equiv`) is
present** at `Axioms.lean:258-259`. Prior research (tasks 86, 88, 89) either
assumed these were missing or did not explore their joint implication for
interval linearity. If linearity is derivable, **neither Option A nor Option
B is needed** — standard canonical model techniques close the 4 sorries
directly.

Option A is **rejected** as structurally infeasible regardless of axiom state:
the Until-witness ordering is provably non-equivalent to `g_content ⊆`,
non-transitive in general, and would cascade into ≥9 broken sorry-free
theorems. Task 88 Phase 2 already committed a NO-GO verdict on this approach.

---

## Key Findings

### 1. Critical Premise Correction: BX11 and BX12 Are Already Present (100% confidence)

Teammate C verified directly:

| Axiom | Location | Status |
|-------|----------|--------|
| `BX11` / `temp_linearity` | `Theories/Bimodal/ProofSystem/Axioms.lean:240-244` | **Present** |
| `temp_linearity_past` | `Axioms.lean:249-253` | **Present** |
| `BX12` / `F_until_equiv` | `Axioms.lean:258-263` | **Present** (is exactly `F(φ) → ⊤ U φ`) |

Task 89's Priority 1 recommendation was "re-add `temp_linearity`" — but the
axiom was never actually removed. This invalidates the premise of task 89's
analysis and explains why task 90 was issued to supersede it.

**More importantly**: Task 86 Report 08 Section 7 claimed `F(φ) → ⊤ U φ` was
"almost certainly impossible to derive." **BX12 *is* this implication as a
primitive axiom**. The BX7+BX11+BX12 combination for interval linearity has
**never been explored**. This is a genuine gap in all prior research (tasks
83–89).

### 2. Option A Is Structurally Infeasible (high confidence)

Teammate A's deep dive identified **two independent fatal flaws** with
redefining `bx_le` via Until-witnesses:

**Flaw 1 — Non-equivalence with `g_content ⊆`**: Consider an MCS `w` with
`G(p) ∈ w` but no pending Until formulas. Then `bx_le_uw w v` holds vacuously
for every `v`, but `g_content(w) ⊆ v` requires `p ∈ v`. The two orderings are
provably **not equivalent**. The "equivalence proof via BX10+BX12+BX4+T" that
the task description calls for does not exist.

**Flaw 2 — Transitivity failure**: If `ψ ∈ u` resolves a pending `φ U ψ` at
step `w → u`, there is no mechanism to carry `ψ` forward to `v` at step
`u → v` (since `bx_le_uw` only tracks *pending* Until formulas, not resolved
ones). Transitivity is not derivable from BX axioms alone.

**Cascade cost**: 9 existing sorry-free theorems break under Option A, including
`bx_G_forward`, `bx_G_backward`, `bx_H_forward`, `box_preserved_along_bx_le`,
`bx_modal_equiv_of_bx_le`, `G_iff_mcs`, and `H_iff_mcs`. Estimated rebuild:
1,400–2,500 LOC, 40–80 hours.

**Historical evidence**: Task 88 Phase 2 committed a NO-GO verdict on precisely
this approach (commit `24005ad80`): *"Phase 2 NO-GO: Until-witness chain bx_le
does not solve guard propagation — interval linearity not guaranteed, X-vs-G
mismatch persists under any single global ordering."*

### 3. Option B as "Henkin Enrichment" Is Misframed (medium-high confidence)

Teammate B analyzed literal Henkin/Burgess-1984 enrichment of the Lindenbaum
construction and found it infeasible as stated: the universal quantifier
`∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas` requires
all BXPoints in the interval to satisfy the guard, but a Henkin-enriched chain
only produces witnesses for its own members. DovetailedChain.lean is direct
prior art: it attempted precisely this strategy at the FMCS/Bundle level and
failed (6 sorries, deprecated).

**However, Teammate D demonstrated this is the wrong framing**. The ROAD_MAP
(rewritten by task 91) describes "Option B" more accurately as **"Burgess–Xu
Until-induction on the existing `bx_le` ordering"** — no new MCS structure is
added. The witnesses are already MCS points (BXPoints) reachable via
`bx_forward_witness` (BX10 → Lindenbaum). The actual proof uses:

1. **BX10** (`φ U ψ → F(ψ)`) — extract F-witness
2. **BX11** (`temp_linearity`) — establish that F-witnesses are linearly ordered
3. **BX5** (`self_accum_until`) — propagate `φ ∧ φ U ψ` to intermediate points
4. **BX6** (`absorb_until`) — anti-deferral
5. **BX9** (`until_elim`) — current-time case
6. **BX4** (`connect_future`) — backward contradiction
7. **BX12** (`F_until_equiv`) — F↔Until bridge (the previously-believed-missing piece)

Reframed this way, Option B:
- Leaves `bx_le := g_content ⊆` unchanged
- Preserves all 30+ existing sorry-free theorems (no regression risk)
- Is described by an explicit 8-step proof sketch in ROAD_MAP's "Burgess-Xu
  Until-Induction Technique" section (added by task 91 as preparation for
  task 92)
- Matches the intended project direction

### 4. Closing the 4 Sorries Does Not Give `bx_completeness` (100% confidence)

Both Teammates C and D noted: ROAD_MAP's active-path sorry inventory lists
**6 sorries**, not 4, blocking `bx_completeness`:

| # | Location | Description | Assigned |
|---|----------|-------------|----------|
| 1 | `Frame.lean:440` | Box modal-witness (S5 closure) | task 93 |
| 2 | `Frame.lean:653` | `bx_until_eventuality_resolution` | **task 92** |
| 3 | `Frame.lean:675` | `bx_until_backward` | **task 92** |
| 4 | `Frame.lean:690` | `bx_since_eventuality_resolution` | **task 92** |
| 5 | `Frame.lean:704` | `bx_since_backward` | **task 92** |
| 6 | `Completeness.lean:154` | TaskModel embedding (non-constant histories) | task 93 |

Tasks 90/92 address at most 4 of 6. Sorry #6 is an *independent* blocker
requiring non-constant-history TaskModel embedding; Options A and B address
neither sorry #6 nor sorry #1. Neither option is a complete solution.

### 5. Project Trajectory Is Healthy, Not a Dead End (high confidence)

Teammate D's 6-month pattern analysis (tasks 83–91, ~55 commits):

- Tasks 83–84: Foundation building (BX axiom system, BXCanonical skeleton)
- Tasks 85–88: Dead-end elimination (WitnessSeed closed, chain approach
  NO-GO, CanonicalEmbedding deleted, constant-history anti-pattern identified)
- Task 91: ROAD_MAP rewrite with accurate axiom inventory

The current state (post-task-91) is **the cleanest the project has ever been**:
one active completeness path (BXCanonical), 6 well-scoped sorries, accurate
documentation, 30+ sorry-free theorems. The 6-month pattern is progressive
narrowing, not dead-ending.

Task 89 was declared stale because it was based on the pre-task-91 mental
model (believing `temp_linearity` was absent). It was never wrong about
specific facts — it was reasoning against an inaccurate axiom inventory.

---

## Synthesis

### Conflicts Resolved

**Conflict 1 — Teammates A and B recommend "re-add `temp_linearity`" as the
highest-ROI action; Teammates C and D show the axiom is already present.**

Resolution: **C and D are correct.** Teammates A and B both replicated task
89's premise error. This does *not* invalidate their analyses of Options A/B
themselves, but it does mean their "what would actually work" recommendations
are unreachable (`temp_linearity` cannot be "re-added" — it's already there).
Their effort estimates (10–20h under `temp_linearity`) may now apply directly
to the current state, which is testable.

**Conflict 2 — Teammate A says Option A is structurally infeasible
(non-equivalence + non-transitivity); the task description claims the
equivalence is provable via BX10+BX12+BX4+T.**

Resolution: **Teammate A is correct on structural grounds.** The
non-equivalence counterexample (MCS with `G(p)` and no pending Until formulas)
is compelling. The task description's equivalence claim is hoped, not proved,
and no concrete proof path exists in the research corpus. Task 88 Phase 2's
NO-GO verdict is independent empirical evidence.

**Conflict 3 — Teammate B says Option B is infeasible without `temp_linearity`
(DovetailedChain precedent); Teammate D says Option B (reframed as Burgess–Xu
Until-induction) is feasible with BX11+BX12 present.**

Resolution: **D is correct, but the reframing is essential.** Literal
Burgess-1984 Henkin enrichment (B's reading) would duplicate DovetailedChain's
failed strategy. The ROAD_MAP's "Burgess-Xu Until-induction" approach (D's
reading) is different: it uses proof-theoretic induction on Until formulas
via the BX axioms, not chain-level MCS enrichment. The terminology "Henkin
closure" in the task description is misleading. Task 92 should use
"Burgess–Xu Until-induction" as the canonical name.

**Conflict 4 — Team member assessments of Option A's viability range from
"structurally infeasible" (A, C) to "cascading cost is high but possible" (D).**

Resolution: Accept Teammate A's structural infeasibility argument. The
non-equivalence flaw is mathematical, not implementation-detail. Option A
cannot produce an ordering that supports both the G/H truth lemma AND the
Until/Since truth lemma.

### Gaps Identified (Unanswered Questions)

**Primary diagnostic gap** (from Teammate C, 90% confidence this is decisive):

> **Can `bx_le_linear : ∀ w v : BXPoint, bx_le w v ∨ bx_le v w` be proved
> from the current axiom set (BX7 + BX11 + BX12)?**

This has never been attempted and is the single highest-ROI next step. It
determines:
- If YES: both Options A and B are moot; standard canonical techniques close
  the 4 sorries in 4–8h.
- If NO: identify the exact step that fails, which distinguishes whether the
  obstruction is structural (reject both A and B, reconsider quasimodel
  approach) or fixable via Option B's proof-theoretic induction.

**Secondary gaps**:

1. **Interval linearity via BX7+BX11+BX12**: Even if global `bx_le` linearity
   is false (as task 86 Report 08 argued informally — no formal countermodel
   exists), *interval* linearity on `[w, v)` where `bx_le w v` may be
   provable. This weaker claim is exactly what the 4 sorries need and has
   not been explored.

2. **Formal countermodel**: Neither global `bx_le` non-linearity nor Option A
   failure has a formal Lean 4 countermodel. Both are informal mathematical
   claims. A determined implementer might find a path missed by tasks 86/88.

3. **Sorry #6 plan**: Completeness.lean:154 (TaskModel embedding,
   non-constant histories) is independent of the A vs B choice. Task 93's
   strategy for this sorry should be researched before task 92 commits
   implementation effort, to confirm task 92's output actually feeds task 93.

### Recommendations

#### Primary Recommendation: Option B (as Burgess–Xu Until-induction)

Adopt **Option B** for task 92, with the following clarifications:

1. **Keep `bx_le := g_content ⊆` unchanged.** Do not redefine.
2. **Do not add new MCS structure** (no Lindenbaum enrichment, no chain
   construction). The witnesses are existing BXPoints reachable via
   `bx_forward_witness`.
3. **Follow ROAD_MAP's "Burgess-Xu Until-Induction Technique" sketch** step
   by step: BX10 → F-witness → BX11 interval linearity → BX5 propagation →
   BX6 anti-deferral → BX9 current-time → BX4 backward contradiction.
4. **Use BX12** as the F↔Until bridge — it was missing in prior analyses but
   is a primitive axiom.
5. **Rename the approach** in task 92's description from "Henkin closure" to
   "Burgess–Xu Until-induction" to avoid replicating task 86/88 confusion
   with chain-based Henkin enrichment.

Estimated effort: **8–16 hours** if diagnostic (below) succeeds; **15–25
hours** if the full proof sketch must be walked through. Confidence: **70%**
(Teammate D: high; Teammate B conditional on reframing; Teammates A and C:
consistent with the reframing but did not endorse it directly).

#### Prerequisite Diagnostic (before task 92 implementation)

**Execute a 2–4 hour diagnostic investigation before task 92 begins:**

```lean
theorem bx_le_linear : ∀ w v : BXPoint, bx_le w v ∨ bx_le v w := by
  -- attempt using BX7 + BX11 + BX12
  sorry
```

Or the weaker, target-relevant version:

```lean
theorem bx_le_interval_linear (w v : BXPoint) (h : bx_le w v) :
  ∀ u₁ u₂ : BXPoint, bx_le w u₁ → bx_le u₁ v →
                     bx_le w u₂ → bx_le u₂ v →
                     bx_le u₁ u₂ ∨ bx_le u₂ u₁ := by
  sorry
```

Use `lean_multi_attempt` and `lean_hammer_premise` to probe the axiom
combination. Outcomes:

- **Success**: task 92 reduces to 4–8h (both Options A and B bypassed).
- **Close but stuck on a specific lemma**: identify the lemma; it becomes
  task 92's focal sub-goal.
- **Provable non-linearity**: formalize the countermodel; reject Option B
  as stated and escalate to Option C (quasimodels / Hintikka sets / task 94
  archival pivot).

This diagnostic costs 2–4h and dominates both Options A and B on expected
value.

#### Rejected: Option A

Reject Option A. Structural non-equivalence with `g_content ⊆` and
non-derivable transitivity make it infeasible. Task 88 Phase 2 already
committed a NO-GO. Pursuing it would cost 40–80h with high regression risk.

#### Scope Awareness

Remind task 92 and subsequent planning that closing these 4 sorries does
**not** deliver `bx_completeness`. Sorries at `Frame.lean:440` (Box
direction) and `Completeness.lean:154` (TaskModel embedding) remain
independent blockers (task 93). Task 92's output is a *necessary* step, not
a *sufficient* one.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary (Option A deep dive) | completed | low on A | Non-equivalence counterexample; 9-theorem cascade analysis |
| B | Alternative (Option B deep dive) | completed | low on B-as-Henkin | DovetailedChain precedent; universal-guard vs chain-guard distinction |
| C | Critic | completed | high on premise verification | **BX11 and BX12 verified present**; the `bx_le_linear` diagnostic question |
| D | Horizons | completed | high | ROAD_MAP reframing of Option B as Burgess–Xu induction; 6-month trajectory analysis |

**Coverage gap**: No teammate directly attempted to prove `bx_le_linear` from
the current axiom set. This is the natural task 91.5 / task 92 phase-0 step.

---

## References

### Codebase

- `Theories/Bimodal/ProofSystem/Axioms.lean:240-244` — BX11 `temp_linearity`
- `Theories/Bimodal/ProofSystem/Axioms.lean:249-253` — `temp_linearity_past`
- `Theories/Bimodal/ProofSystem/Axioms.lean:258-263` — BX12 `F_until_equiv`
- `Theories/Bimodal/ProofSystem/Axioms.lean:180` — BX7 `linear_until`
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:61-62` — `bx_le` definition (unchanged)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:653, 675, 690, 704` — the 4 sorries
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:440` — Box modal-witness sorry (#5, task 93)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:164` — `bx_forward_witness` (existing, sorry-free)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:154` — TaskModel embedding sorry (#6, task 93)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean:124` — `G_iff_mcs` (would break under Option A)
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` — deprecated Henkin attempt (6 sorries)
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean:291` — `set_lindenbaum`
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — parameterized Until/Since infrastructure (reusable)

### Prior Research

- `specs/ROAD_MAP.md` — active-path architecture (task 91 rewrite), Burgess-Xu Until-Induction Technique section
- `specs/archive/086_close_bxcanonical_completeness_sorries/reports/08_bxle-linearity-research.md` — bx_le linearity informal analysis (task 86 Report 08)
- `specs/089_close_frame_lean_eventuality_sorries/reports/01_team-research.md` — task 89 synthesis (stale premise)
- Commit `24005ad80` — task 88 Phase 2 NO-GO verdict on Until-witness chain bx_le
- Commit `12d4e2bde` — CanonicalEmbedding.lean deletion (task 88)
- Commit `68deabd2e` — ROAD_MAP.md rewrite (task 91)

### Teammate Findings Files

- `specs/090_research_bx_le_redefinition/reports/01_teammate-a-findings.md`
- `specs/090_research_bx_le_redefinition/reports/01_teammate-b-findings.md`
- `specs/090_research_bx_le_redefinition/reports/01_teammate-c-findings.md`
- `specs/090_research_bx_le_redefinition/reports/01_teammate-d-findings.md`
