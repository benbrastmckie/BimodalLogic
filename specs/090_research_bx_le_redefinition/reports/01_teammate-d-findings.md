# Teammate D Findings — Horizons / Strategic Direction

**Task**: 90 — Research Option A vs Option B for Until/Since sorries
**Role**: Horizons and Strategic Direction
**Date**: 2026-04-10
**Artifact**: 01_teammate-d-findings.md

---

## Project Trajectory Context (from roadmap + git history)

### Roadmap state (post task 91)

`specs/ROAD_MAP.md` was rewritten by task 91 and is now accurate. Key facts:

- The project has ONE active completeness path: `BXCanonical/`. The legacy paths
  (`UltrafilterChain`, `FrameConditions/Completeness`, `DovetailedChain`,
  `SuccChainFMCS`) are NOT imported by BXCanonical and are slated for archival in
  task 94 (which will drop ~210 sorries from the count mechanically).
- BXCanonical has exactly 6 active-path sorries: 4 in Frame.lean (U/S eventuality),
  1 Box witness at Frame.lean:440, 1 TaskModel embedding at Completeness.lean:154.
- BX11 (`temp_linearity`) and BX12 (`F_until_equiv`) ARE present in the axiom
  system (Axioms.lean:240-263). The task 89 research finding that these were missing
  was a symptom of reading stale state; task 91 corrected the baseline.
- The recommended task order is: 94 (archive legacy) → 90 (this research) →
  92 (implement) → 93 (Box + TaskModel embedding) → 95 (axiom audit).

### Git history pattern (6-month window, Theories/Bimodal/)

The git log shows ~55 commits spanning tasks 83-91 over what appears to be a
sustained 6+ month effort. The trajectory is:

| Phase | Tasks | Theme |
|-------|-------|-------|
| Architectural redesign | 83 | Switch to reflexive semantics; 37-axiom BX system; BXCanonical skeleton |
| Cleanup and investigation | 84-86 | Until/Since coherence failures; WitnessSeed sorry closure; BX7 linearity investigation |
| Dead-end documentation | 86 | Phase 2 NO-GO verdict for chain-specific eventuality resolution |
| Partial sorry closures | 86-88 | WitnessSeed (2 sorries), FMP fixes (2), F_top/P_top (2); CanonicalEmbedding deleted |
| Roadmap accuracy | 91 | Rewrote ROAD_MAP.md with accurate BX architecture |

The pattern reveals a codebase that has been progressively pruned of dead ends. The
current state (post-task-91) is the cleanest the project has ever been: one active
path, 6 well-scoped sorries, accurate documentation. This is not a sign of a dead
end — it is a sign of having successfully eliminated confusion about what to work on.

---

## Long-Term Alignment: Option A vs Option B

The long-term goal is stated explicitly in the ROAD_MAP:

> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

The representation theorem requires a canonical model construction that:
1. Passes the truth lemma (every formula ∈ w ↔ true at w in canonical model)
2. Embeds into a concrete `TaskModel F` over some `D` (Completeness.lean:154)

**Option A (redefine `bx_le` via Until-witnesses)**:
- Changes the canonical ordering from `g_content ⊆` to something Until-based
- All existing G/H forward/backward proofs depend on `bx_le w v ↔ g_content(w) ⊆ v`
- After redefinition, `bx_le_refl`, `bx_le_trans`, `bx_modal_equiv`, and all G/H
  truth lemma cases must be reproved or adapted
- The equivalence proof (showing new bx_le ≡ old bx_le) is non-trivial: it needs
  BX10 (until_F), BX12 (F_until_equiv: F(φ) → ⊤Uφ), BX4 (connect_future), and BX1
  (temp_t_future). This is a significant proof burden.
- However, if the equivalence holds, the new ordering gives linearity "for free"
  from BX7/BX11.

**Option B (Henkin-enrich MCS closure, keep `bx_le := g_content ⊆`)**:
- Keeps the existing infrastructure intact; no retroactive reproving
- BX11 (`temp_linearity`) and BX12 (`F_until_equiv`) are available and provide the
  linearity/F-bridge needed for the Burgess-Xu Until-induction argument
- The ROAD_MAP's "Burgess-Xu Until-Induction Technique" section (added in task 91)
  describes exactly this path in detail: BX10 → F-witness → BX7+BX11 linearity →
  BX5 guard propagation → BX6 anti-deferral → BX9 current-time case → BX4
  backward contradiction
- The 4 sorry function signatures already match what this proof would need; no API
  changes required

**Long-term alignment verdict**: Option B is strongly preferred. It leaves the
codebase in a better state by:
1. Preserving all existing sorry-free proofs (no regression risk)
2. Using the axiom system as designed — the BX axioms were precisely chosen to
   make this proof work without auxiliary definitions
3. Matching the ROAD_MAP's intended strategy, which Task 91 documented explicitly
4. Keeping the canonical model conceptually clean: the ordering remains the standard
   "G-content inclusion" definition that every completeness text uses

Option A would technically also work, but it introduces a period of instability
(multiple sorry-free proofs broken simultaneously) with no compensating benefit,
since BX11 + BX12 already enable Option B to close the 4 sorries without a
definitional change.

---

## Adjacent Roadmap Items Served

Closing the 4 Frame.lean sorries (tasks 90→92) unblocks the following:

**Directly enables:**
- Task 93: Close Frame.lean:440 (Box direction) and Completeness.lean:154 (TaskModel
  embedding). The sorry at Completeness.lean:154 is downstream of the truth lemma
  completion; it cannot be tackled usefully until the U/S cases are closed.
- Task 95: `#print axioms` audit on `bx_completeness`. Depends on 93, which depends
  on 92.

**Indirectly enables:**
- Publication of the BXCanonical representation theorem for TM. The ROAD_MAP's
  "Representation Theorem Goal" section describes this as the project's scientific
  contribution. Closing these 4 sorries is the primary remaining proof-theoretic
  obstacle (Frame.lean:440 and Completeness.lean:154 are adjacent but distinct).
- Task 68 (dense completeness via ℚ) and task 82 (FMP truth preservation) are
  independent tracks, but a complete BXCanonical module makes the project more
  credible for reviewers/readers of those independent results.

**Observation**: The "4 sorries → task 92 → task 93 → bx_completeness" chain is
the entire remaining path to the representation theorem. There are no other
sorry-bearing dependencies on the active path (the 6 sorries are well-isolated).
Closing these 4 is extremely high leverage.

---

## Is the A-vs-B Dichotomy the Right Framing?

The dichotomy as posed in task 90's description is appropriate **given that BX11
and BX12 are present**. The original task 89 context posed a different dichotomy
(Option A: redefine bx_le, Option B: quasimodel/filtration) because it was based
on the incorrect premise that `temp_linearity` was missing. Task 91's ROAD_MAP
rewrite resolved that premise error.

The current task 90 framing correctly identifies:
- Option A: redefine `bx_le` via Until-witnesses (complex, requires retroactive work)
- Option B: Henkin-enrich MCS closure (keep `bx_le`, use available axioms directly)

**However, "Option B: Henkin-enrich MCS closure" may be a slight misnomer.** The
classical Henkin/Burgess approach adds explicit witness points to the MCS. In the
BXCanonical architecture, the witnesses are already MCS points (BXPoints), reached
via `bx_forward_witness` (Lindenbaum extension). The actual work is:
1. Extract an F-witness from `φUψ` via BX10 (already implemented as `bx_forward_witness`)
2. Use BX11 (temp_linearity) to establish that F-witnesses are linearly ordered
3. Apply BX5 (self_accum_until) to propagate `φ∧φUψ` to all intermediate points
4. Close the guard using BX9 (until_elim) and BX6 (absorb_until)

This is more precisely "Burgess-Xu Until-induction on the existing bx_le ordering."
The term "Henkin closure" suggests adding new MCS structure, but no new structure is
needed — the axioms themselves provide the required argument.

**Recommendation for framing**: The ROAD_MAP's own section header "Burgess-Xu
Until-Induction Technique" is the right framing for what is effectively Option B.
Task 92's description should use this term rather than "Henkin closure."

---

## 6-Month Pattern Analysis (Tasks 83-89)

| Task | Theme | Outcome | Sorry Delta |
|------|-------|---------|-------------|
| 83 | BX axiom system; BXCanonical skeleton; reflexive semantics | +BX system, +BXCanonical, first 16 theorems | -37 (dead code) |
| 84 | Until/Since coherence investigation; split predicates | Isolated until_since_coherent | 0 (investigative) |
| 85 | X/Y cleanup; BX7 linearity investigation | Confirmed BX7 insufficient alone; cleaned X/Y | -6 |
| 86 | Close BXCanonical sorries via BX10 + chains | WitnessSeed closed; chain approach NO-GO | -2 |
| 88 | Close CanonicalEmbedding sorry | BLOCKED; constant-history anti-pattern identified; file deleted | -2 (2 SuccChainFMCS) |
| 91 | Rewrite ROAD_MAP.md for accuracy | Accurate baseline; clarified BX11/BX12 presence | 0 (doc) |

**Pattern analysis**: The 6-month arc shows disciplined dead-end elimination:
- Tasks 83-84: Foundation building (net positive)
- Tasks 85-88: Narrowing the problem space (progressive sorries closed; approaches
  that cannot work documented and deprecated)
- Task 91: Clarification that unlocked awareness of BX11/BX12 presence

The pattern does NOT indicate that BXCanonical is a dead end. It indicates that the
team was working with an inaccurate mental model of the axiom system (believing
`temp_linearity` was absent). Task 91's correction is the key state change.

**Interpretation**: Task 89 was declared stale because it was based on the old
frame (missing axioms). Task 90 is correctly positioned as the first research task
in the new frame (accurate axiom inventory, correct ROAD_MAP). The 6 months were not
wasted — they built the infrastructure (BXCanonical Frame, TruthLemma skeleton,
Completeness structure) that makes task 92 tractable once task 90 chooses an approach.

**Pivoting to a different canonical construction is not indicated.** The BXCanonical
module has clean infrastructure, 30+ sorry-free theorems, and well-scoped remaining
gaps. The reasons previous attempts failed (wrong axiom inventory, chain mismatch,
constant-history anti-pattern) are all documented and avoided.

---

## Unconventional Alternatives

1. **Axiomatize `bx_le` linearity directly as a canonical-model-only postulate**

   One could add `bx_le_linear : ∀ w v : BXPoint, bx_le w v ∨ bx_le v w` as an
   assumption to the 4 sorry'd definitions, deriving it from BX11 + BX12 later.
   This is a staged approach: close the sorries conditionally, then close the
   linearity lemma separately.

   Assessment: This adds technical debt (introduces an unproved hypothesis into
   the proof tree). The ROAD_MAP's zero-debt policy is explicit. Only viable as a
   very short-term staging strategy if the linearity lemma proof turns out to
   require more work than expected. Not recommended as a final approach.

2. **Use a non-standard canonical model (omega-saturated / Hintikka sets)**

   Omega-saturated models saturate every consistent type. Hintikka sets are maximal
   consistent sets with explicit witness conditions. Both would avoid the bx_le
   interval linearity problem by construction (every eventuality is witnessed in
   the model by definition).

   Assessment: This is the quasimodel approach from task 89 research (GHR 1994),
   with estimated 50-60% confidence, 15-25h effort, ~2000 LOC. Now that BX11 + BX12
   are available and Option B is tractable (8-16h per task 89 research), the
   quasimodel approach is dominated by Option B on both effort and confidence. Not
   recommended unless Option B fails.

3. **Construct TaskFrame directly from proof-theoretic data without going through
   canonical MCS**

   Instead of building a canonical model and then embedding it into a TaskFrame,
   one could define a proof-theoretic TaskFrame where worlds ARE derivation contexts
   and the temporal ordering is derivability-based.

   Assessment: This bypasses the canonical model entirely and would constitute a
   fundamentally different proof architecture. The ROAD_MAP explicitly notes that
   the representation theorem's value is the canonical model correspondence (MCS ↔
   worlds, truth lemma ↔ structural correspondence). A proof-theoretic TaskFrame
   construction would give completeness as a bare fact but not the representation
   theorem. Explicitly excluded per ROAD_MAP's "Representation Theorem Goal" section.

4. **Use Mathlib's lattice/order theory to abstract away the mismatch**

   The Set.Ici / Set.Icc / interval machinery in Mathlib might enable abstract
   lemmas about well-founded linear orders that could be instantiated to BXPoints
   with the BX11-derived linearity. In particular, Mathlib has `LinearOrder.min`,
   `Set.IsWF`, and `WellFoundedRelation` infrastructure.

   Assessment: Viable as a proof strategy technique within Option B. Rather than
   hand-crafting the minimum-witness argument, one could instantiate Mathlib's
   well-founded minimum lemmas on the `bx_le` ordering (after proving linearity and
   well-foundedness from BX11 + BX7). This could significantly shorten the proof.
   Worth exploring in task 92, but not a separate approach — it augments Option B.

5. **Weaken the goal: prove weak completeness instead of strong completeness**

   Weak completeness: `valid φ → provable φ`. Strong completeness: every consistent
   set has a model. The representation theorem goal is strong completeness (the
   canonical model embeds the entire proof structure). Weak completeness is weaker
   and might be provable via FMP (task 82).

   Assessment: The ROAD_MAP explicitly rejects this: "Decidability-based completeness
   is explicitly excluded as a path to the representation theorem." Weak completeness
   via FMP has independent interest (task 82) but does not serve task 90's goal.
   Not recommended.

6. **Use the ROAD_MAP's proof sketch as a formal specification**

   The ROAD_MAP (section "Burgess-Xu Until-Induction Technique") gives an 8-step
   numbered proof sketch with exact BX axiom references. This sketch could be used
   as a formal specification for task 92 — essentially converting ROAD_MAP's
   informal sketch into Lean 4 tactics step by step. This is not an "alternative"
   so much as a direct execution strategy.

   Assessment: This is the correct approach for task 92. The ROAD_MAP sketch was
   written by task 91 as preparation for task 92's implementation. Task 90's role
   is to confirm that sketch is the right one (Option B direction) and provide any
   additional detail task 92 needs.

---

## Recommendation: A, B, Reframe, or Pivot?

**Recommendation: Option B — Burgess-Xu Until-Induction on existing `bx_le`.**

**Rationale**:

1. **No axioms need to be added.** BX11 (`temp_linearity`) and BX12
   (`F_until_equiv`) are present in `Axioms.lean`. This was the primary obstacle
   identified in task 89 research. It no longer exists.

2. **Option B preserves all existing sorry-free infrastructure.** The 30+ sorry-free
   theorems in Frame.lean and TruthLemma.lean depend on `bx_le := g_content ⊆`.
   Option A would require retroactively reproving these.

3. **The ROAD_MAP provides a complete proof sketch for Option B.** The
   "Burgess-Xu Until-Induction Technique" section lists 8 axioms and their exact
   roles. No equivalent sketch exists for Option A. This is not an accident — it
   reflects that the project already chose Option B direction when writing task 91.

4. **`bx_forward_witness` already implements the key step.** The F-witness
   extraction (BX10 → Lindenbaum extension → `bx_le`-successor with ψ) is already
   sorry-free. Option B builds on this. Option A would need to redefine what a
   "witness" means in terms of `bx_le`.

5. **Effort is lower with Option B.** Task 89 research estimated 8-16h for
   Option B with BX11 present; 25-35h for Option A (with cascading reproofs).
   Given task 92's estimate of 8-20h, Option B fits the planned scope.

**Framing note**: The dichotomy A vs B is correct, but "Option B: Henkin-enrich MCS
closure" is slightly misleading. The more accurate name is "Option B: Burgess-Xu
Until-induction on existing `bx_le` ordering using BX5+BX6+BX7+BX9+BX10+BX11+BX12."
The witnesses are not Henkin-style additions but rather MCS points already reachable
via `bx_forward_witness`.

---

## 6-Month Vision

In 6 months (October 2026), the project should have:

1. A sorry-free `bx_completeness` theorem (tasks 90 → 92 → 93 → 95).
2. Legacy code archived (task 94), dramatically reducing apparent sorry count.
3. A clean codebase with 0 active-path sorries.
4. Optionally: a publication draft for "Lean 4 Formalization of Completeness of
   Bimodal TM" — the first Lean 4 formalization of tense logic completeness.

The task 90 decision directly serves this vision. Choosing Option B now means task 92
can proceed immediately with a clear implementation target (the ROAD_MAP proof sketch)
and a realistic 8-20h estimate. Choosing Option A would push task 92 into the
25-35h range and introduce regression risk, delaying the 6-month goal.

**Task 90 helps this vision** by providing the decision boundary that prevents task 92
from re-discovering the Option A / Option B question mid-implementation.

---

## Confidence: high

- BX11 and BX12 are present in Axioms.lean (verified directly)
- ROAD_MAP proof sketch for Option B is explicit and consistent
- Option A's cascade cost is documented (task 88, Phase 2 NO-GO analysis)
- Option B's tractability with BX11 present was forecast at 90% confidence in
  task 89 research (teammate A and D both)
- No evidence of architectural instability in BXCanonical; the module is stable and
  growing
