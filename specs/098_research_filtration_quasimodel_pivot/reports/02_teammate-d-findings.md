# Teammate D Findings: Strategic Horizons for the bx_le Non-Totality Blocker

- **Task**: 98 — Research filtration/quasimodel pivot for Until/Since truth lemma
- **Teammate**: D (Horizons — strategic analysis)
- **Artifact**: 02
- **Date**: 2026-04-10
- **Scope**: Strategic roadmap analysis only; no Lean file editing

---

## Key Findings

### 1. The Root Cause is Architectural, Not Tactical

The four Until/Since sorries (`Frame.lean:653, 675, 690, 704`) share a single
root cause documented conclusively in `specs/092.../reports/04_spawn-analysis.md`:

> `bx_le := g_content ⊆ (·)` propagates only `G(χ)`-formulas along the
> canonical order. Until formulas `(φ U ψ)` are not of shape `G(χ)`, so BX5
> self-accumulation produces `(φ ∧ (φ U ψ)) U ψ ∈ w.formulas` but cannot
> transport it to a strict-interval `u` where `bx_le w u` and `bx_le u v`.

This is not a proof-tactics gap. All six Phase 0 probes were exhausted, and
the spawn analysis ruled out BX4, BX4', BX7, BX11, and Since-via-dual as
rescue strategies. The Burgess-Xu direct approach — which task 90 recommended
and task 92's Phase 0 tested — lacks a complete mathematical path because it
relies on the MCS order already being linear, which it is not under
`g_content ⊆`.

### 2. Tasks 96 and 97 Were Abandoned: What Was Lost

- **Task 96** (BX13 axiom candidates): Abandoned. This was the lowest-effort
  path (~6-10h) if a sound axiom existed, but research concluded that all
  natural candidates for an Until-propagation axiom are unsound over the
  intended frame class (general linear orders with reflexive semantics). No
  axiom of the form `(φ U ψ) → G(...)` that would close Gap U5 passes a
  Kripke countermodel check. Nothing from this task is salvageable.

- **Task 97** (layered bx_le redefinition): Abandoned. The layered approach
  would redefine `bx_le` to include Until-witness ordering directly (equivalent
  to Option A from task 90 research). Research found this approach has medium
  cost and medium risk: the Box/G/H layer (`Frame.lean:140-583`, ~440 LOC)
  needs to be re-verified against the new ordering, reflexivity and transitivity
  proofs become more complex, and there is no published canonical reference for
  this combination of reflexive Until semantics + BX axiom set. The core
  mathematical challenge is showing the layered order is still a preorder
  compatible with the S5 modal equivalence.

  The key question from this task: can `bx_le` be redefined as
  `g_content w ⊆ v ∨ (∃ φ ψ, (φ U ψ) ∈ w ∧ bx_until_witness_order w v)`
  while keeping transitivity and the Box/G/H layer intact? Research found
  this definition requires additional lemmas about interaction of Until-witness
  order with modal equivalence that are not available in BX1-BX12. Abandoned.

### 3. Task 98 is the Sole Viable Path: Quasimodel Pivot

With tasks 96 and 97 abandoned, task 98's CONDITIONAL GO recommendation (from
report `01_filtration-quasimodel-pivot.md`) becomes the de facto sole path
forward. The TODO.md confirms: task 92 lists `98 is sole viable path`.

The quasimodel pivot offers a **local variant** that preserves the entire
Box/G/H layer intact:

- `Frame.lean:140-583` (Box preservation, G/H forward/backward, modal equiv,
  reflexivity, transitivity) — **zero rework** under local variant
- `TruthLemma.lean:124-205` (G/H/Box truth lemmas at MCS level) — **zero rework**
- Only `Frame.lean:632-704` (the four current sorries) is replaced
- A new `Quasimodel.lean` module (~200-350 LOC) is added

**This is coherent because** the four sorry-laden helpers are internal to
`until_iff_mcs`/`since_iff_mcs`. Their implementations can use a Hintikka
quasimodel as an internal tool while their *statements* remain unchanged
(they produce and consume BXPoints, not quasimodel points).

### 4. The bx_le Definition Is Not Wrong — It Is Incomplete

The analysis of whether `g_content ⊆` is "fundamentally wrong" requires care:

- **It is correct for Box/G/H**: `bx_le w v ↔ g_content w ⊆ v` is exactly
  the right definition for the G-operator truth lemma (it directly encodes
  `G(φ) ∈ w → φ ∈ v`). Reflexivity and transitivity follow from BX1 and
  `temp_4` respectively. The definition is not wrong for these operators.

- **It is incomplete for Until/Since**: The definition does not encode
  Until-witness order. Burgess 1982 and Xu 1988's published proofs assumed the
  canonical MCS order is already a linear order — their proof strategy works
  because completeness for Since-Until over all linear orders means the
  canonical frame is linear. But in TM-BX, the `g_content ⊆` order is only a
  preorder; no axiom in BX1-BX12 forces full linearity at the MCS level.

- **The fix is not to change the definition** (task 97 found this path harder
  than the quasimodel approach). The fix is to introduce a parallel Hintikka
  structure that carries the Until-witness order natively, use it to build
  the eventuality witnesses, and then *realize* those witnesses back into
  BXPoints via the existing Lindenbaum infrastructure. This is exactly the
  local quasimodel variant.

**Bottom line**: `g_content ⊆` should remain as `bx_le`. Changing it cascades
across 440 LOC of verified infrastructure for no benefit. The quasimodel
lives alongside, not instead of, this infrastructure.

### 5. Comparison with LIPIcs.ITP.2024.28 and Other Lean Formalizations

The LIPIcs.ITP.2024.28 paper (Coalition Logic completeness in Lean 4) used
**classical filtration of a canonical model** for a fixpoint modality (common
knowledge). As report 01 documents, classical filtration is inappropriate for
TM-BX: it destroys the `g_content ⊆` order for arbitrary formulas, requires
per-`Σ` reconstruction of Box preservation, and buys only FMP (which TM-BX
does not need for the representation theorem goal).

The relevant comparison is instead to **Verbrugge's "Completeness by
Construction" (1992)** and **Reynolds 1996** for Since-Until over linear time.
These use Hintikka-set quasimodels, not filtration. The key differences from
LIPIcs.ITP.2024.28:

| Property | Coalition Logic (LIPIcs) | TM-BX (this project) |
|----------|--------------------------|----------------------|
| Goal | FMP + decidability | Canonical-model representation theorem |
| Modality | Fixpoint (common knowledge) | Until/Since over linear time |
| Technique | Classical filtration | Hintikka quasimodel (Burgess 1984) |
| Lean 4 | Yes | Yes (target) |
| Portability | Low (fixpoint-specific) | References confirm applicability |

The Verbrugge and Reynolds constructions are the directly applicable references.
They have been used in pen-and-paper completeness proofs for 30+ years and
are specifically designed for the Burgess-Xu axiom system. The formalization
challenge is not mathematical existence but Lean encoding of:
- Finite Σ-closure with decidable membership
- Hintikka-set enumeration (finite set, decidable)
- Defect-discharge sequence construction (countable induction)
- Realization lifting from Hintikka to BXPoint via Lindenbaum extension

All of these have precedents in the existing codebase (Lindenbaum extension
is already in `BXCanonical/Frame.lean`; finite sets and decidable membership
are standard Mathlib infrastructure).

### 6. Alternative Completeness Strategies: Should the Project Pivot More Broadly?

The roadmap explicitly rejects several alternative strategies:

**Algebraic completeness** (via STSA, task 992): RESEARCHED but not on the
critical path. Algebraic completeness would establish `valid φ → provable φ`
via algebraic duality/Stone representation, but the roadmap states:
"Decidability-based completeness is explicitly excluded as a path to the
representation theorem." The scientific contribution requires a canonical
model construction that gives a structural correspondence, not a bare
decision procedure.

**Henkin-style witness closure** (Option B from task 90): Still technically
available. This approach explicitly enriches the BXPoint set with witness MCS
points for each Until/Since formula. It is essentially equivalent to the
Hintikka quasimodel in construction cost but framed differently. The local
quasimodel is a cleaner presentation of the same mathematical content.

**Cut-elimination / proof-theoretic completeness**: Not explored. Would
require a sequent calculus reformulation of BX and a cut-elimination theorem.
Estimated 100+ hours — not viable given the existing canonical-model
infrastructure.

**Dense completeness via ℚ** (task 68): Independent path, already researched.
Gives a separate completeness result for the dense linear order subclass.
Does not help with the general case.

**Conclusion**: No alternative strategy offers a better cost-risk profile than
the local quasimodel pivot. The algebraic and Henkin paths are either excluded
by design (algebraic), technically equivalent at the same cost (Henkin), or
uncompetitive in effort (cut-elimination). The project should proceed with the
local quasimodel.

### 7. The TaskModel Embedding (Completeness.lean:154) Is Still Pending

An important strategic observation from the cascade audit: `bx_completeness`
is itself a `sorry` at `Completeness.lean:154`. The TaskModel embedding — step
4 of the completeness proof flow — has not been built. This means:

- **There is no downstream infrastructure to break.** The quasimodel pivot
  targets sorries at `Frame.lean:632-704` which are consumed by `TruthLemma.lean`.
  The TaskModel embedding is one level above and is not yet constructed.
- **Task 93 becomes the next critical-path task** after task 92 completes.
  Task 93 must close the Box sorry (`Frame.lean:440`) and build the TaskModel
  embedding using non-constant histories that visit multiple BXPoints over a
  linear domain `D` (e.g., `Int` or `ℕ`). The constant-history anti-pattern
  (task 88 documented failure) must be avoided.
- **The quasimodel pivot does not affect task 93's scope.** The TaskModel
  embedding operates at the level of BXPoints (not Hintikka points), so the
  local variant leaves task 93's work entirely unchanged.

---

## Recommended Approach

**Proceed with the local Hintikka-set quasimodel pivot as the implementation
plan for task 92 (re-plan round 03).**

The recommended 6-phase implementation plan:

1. **Phase 1** (S1: ~3-5h): Define finite Σ-closure infrastructure — subformula
   closure, BX accumulation/absorption closure, decidable membership. Gate:
   `Σ_closure_finite` lemma compiles without sorry.

2. **Phase 2** (S2: ~4-6h): Define `HintikkaPoint Σ` structure — locally
   consistent, locally maximal over Σ, respects BX one-step truth conditions.
   Prove enumeration lemma (finitely many Hintikka sets for finite Σ).

3. **Phase 3** (S3: ~6-10h): Construct the Burgess-Xu one-step relation
   `→_Σ` and build a linear quasimodel sequence with defect-discharge for a
   given `φ U ψ ∈ h₀`. This is the hardest single phase. Gate: the quasimodel
   construction terminates (well-founded on pending-defect count).

4. **Phase 4** (S4: ~4-8h): Prove the realization lifting lemma — for each
   Hintikka step `h_{i-1} →_Σ h_i`, the seed `{χ | G(χ) ∈ v_{i-1}} ∪ h_i`
   is consistent, so it extends to a BXPoint `v_i` with `bx_le v_{i-1} v_i`.
   **This is the go/no-go gate for the entire approach.** If realization
   lifting fails (estimated 10-20% probability), escalate immediately.

5. **Phase 5** (S5: ~6-12h): Use S1-S4 to implement the four sorry helpers.
   Until and Since are standalone (not mirrors). Includes locus-control lemma.

6. **Phase 6** (S6: ~2-4h): Integration, `lake build`, regression verification.

**Conditions that would cause abandonment of this plan:**
- Phase 4 realization lifting fails and cannot be repaired within 8h of
  additional investigation.
- Phase 3 quasimodel construction requires classical logic features not
  available in Lean's `Classical` namespace (very unlikely — `Classical.em`
  and `Classical.choice` are already used in `BXCanonical`).

**If the plan is abandoned**: fall back to the global quasimodel variant
(40-60h), which replaces BXPoint with HintikkaPoint throughout. This has a
larger cascade but a complete mathematical path. Do not reopen tasks 96 or 97
— both were thoroughly researched and found to be dead ends.

---

## Evidence and Examples

### Evidence 1: bx_le partial order vs. the published Burgess proof assumption

`specs/092.../reports/04_spawn-analysis.md` §"Why the Burgess-Xu approach as
published does not apply here":

> Burgess 1982 and Xu 1988 prove canonical-model completeness for tense logics
> of linear time. Their proofs implicitly assume that the canonical accessibility
> relation on MCSes **is already a linear order**... In the BX refactoring,
> `bx_le := g_content ⊆` was deliberately chosen to keep the Box/G/H truth
> lemmas tractable — but this definition is a partial order, not a linear one,
> and no axiom in BX1-BX12 forces it to be linear at the MCS level.

This is the definitive statement of why the definition mismatch occurred and
why fixing it at the definition level is harder than the quasimodel approach.

### Evidence 2: Cascade cost under local variant is near-zero

From report 01 §2, cascade audit summary:

> Cascade-cost total under the local quasimodel variant: 5 theorems touched,
> all with zero-LOC structural changes. The only new code is the
> Hintikka-quasimodel layer itself and its use inside the Until/Since
> eventuality resolution helpers.

The 11 named theorems at risk under global filtration are all zero-cost under
the local variant because `Frame.lean:140-583` remains untouched.

### Evidence 3: The quasimodel technique is the historically correct method

From the Burgess 1984 / Reynolds 1996 references (report 01 §1b):

> Burgess (1984) §4 gives the quasimodel/Hintikka-set construction for
> Until/Since completeness; Reynolds (1996) gives the standard realization
> construction for linear-time Until/Since.

The filtration technique (LIPIcs.ITP.2024.28 style) is used for FMP, not for
canonical-model completeness over all linear orders. The Verbrugge 1992
"Completeness by Construction" directly implements the Hintikka chain approach
that the local variant formalizes.

### Evidence 4: Project goal explicitly requires canonical-model approach

From `specs/ROAD_MAP.md` §"Representation Theorem Goal":

> "TM is complete with respect to TaskFrames over totally ordered abelian
> groups."
>
> Only the algebraic/canonical model approach is pursued for completeness.
> Decidability-based completeness is explicitly excluded as a path to the
> representation theorem.

This rules out any completeness-via-FMP or decidability shortcut and confirms
the quasimodel must build a structure that realizes into a TaskFrame model.

---

## Confidence Level

**Overall confidence in local quasimodel recommendation: HIGH (85-90%).**

Decomposed by component:

| Component | Confidence | Basis |
|-----------|-----------|-------|
| Filtration is wrong tool | Very high (95%) | Multiple structural obstructions documented in report 01 §1a |
| Local variant cascade cost is near-zero | High (90%) | Complete dependency audit performed; `Frame.lean:140-583` verified intact |
| Realization lifting lemma holds | Medium-high (80-90%) | Verbrugge 1992 gives the construction; Lean formalization is non-trivial but standard |
| 25-45h effort estimate is accurate | Medium (70%) | Dominant uncertainty in S3+S4 (quasimodel construction and realization) |
| Tasks 96 and 97 are genuinely abandoned | High (90%) | Spawn analysis and TODO.md confirmed; no artifacts to recover |
| Task 93 (TaskModel embedding) is unaffected | Very high (95%) | Embedding operates at BXPoint level; local variant leaves BXPoints intact |

**The only genuine risk below 80% is the Phase 4 realization lifting lemma**
(20% failure probability). This risk is mitigated by placing it as an early
gate (Phase 4 before Phase 5), so failure is detected before the major
implementation effort.

**No alternative completeness strategy offers a better overall profile.** The
project is on the correct path; the only question is formalization difficulty
of the quasimodel construction.

---

## Appendix: Strategic Context Timeline

```
Task 89 (RESEARCHED, superseded)
  → identified Until/Since gap against stale strict-semantics

Task 90 (COMPLETED)
  → recommended Burgess-Xu Until-induction; found g_content ⊆ non-linear

Task 91 (NOT STARTED)
  → roadmap update; prerequisite for accurate research context

Task 92 (BLOCKED)
  → Phase 0 exhausted all rescue probes for direct Burgess-Xu approach
  → spawned 96, 97, 98 as three orthogonal escape hatches

Task 96 (ABANDONED)
  → BX13 axiom candidates all unsound over intended frame class

Task 97 (ABANDONED)
  → Layered bx_le requires Box/G/H re-verification; no published proof
  → Mutually exclusive with local quasimodel variant

Task 98 (RESEARCHED, PARTIAL → now complete with this report)
  → Local quasimodel variant: CONDITIONAL GO
  → 25-45h, 6 phases, mathematical path established (Burgess 1984, Reynolds 1996)
  → Sole viable path given 96 and 97 abandonment

Next: /plan 92 round 03
  → Should adopt local quasimodel plan from task 98
  → Phase 1-6 as outlined above
  → Phase 4 (realization lifting) is go/no-go gate

After task 92:
  Task 93 → Box sorry (Frame.lean:440) + TaskModel embedding (Completeness.lean:154)
  Task 95 → Verification audit (#print axioms, sorry classification)
  Task 94 → Archive legacy strict-semantics code (~210 sorry drop)
```
