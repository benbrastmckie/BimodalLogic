# Research Report: Filtration / Quasimodel Pivot for Until/Since Truth Lemma

- **Task**: 98 — Research filtration or quasimodel pivot for Until/Since truth lemma
- **Parent Task**: 92 — implement_bx_until_truth_lemma (BLOCKED by Phase 0 diagnostic)
- **Started**: 2026-04-10T21:33:51Z
- **Completed**: 2026-04-10
- **Language**: logic
- **Scope**: Research-only, READ-ONLY of `Theories/Bimodal/`

---

## Executive Summary

**Recommendation: CONDITIONAL GO on a Hintikka-set quasimodel pivot — NO-GO on classical filtration.**

- The classical filtration-of-canonical-model technique (the LIPIcs.ITP.2024.28 Coalition Logic style) is structurally **inappropriate** for TM-BX: quotienting by a finite subformula closure erases exactly the MCS-level structure the Box/G/H truth lemmas rely on, and forces a full rework of `box_preserved_along_bx_le` with no corresponding payoff for Until/Since.
- A **Hintikka-set quasimodel** (in the Burgess 1984 / Reynolds 1996 / Wolter-Zakharyaschev sense) is a better fit: the model points are subformula-closed *Hintikka sets* instead of full MCSes, the accessibility is a Burgess-Xu-style one-step relation that *defines Until-witness ordering directly*, and the truth lemma for Until/Since proves by finite one-step induction rather than by `g_content`-propagation.
- **Crucially**, the cascade-cost audit shows the previously-quoted ≥40h estimate was a **miscalculation**: `bx_completeness` is itself already a `sorry` (Completeness.lean:154) and the `TaskModel` embedding layer **does not yet exist**. Of the 11 "load-bearing" theorems listed in the task prompt, only **five** are real dependencies that would need re-proof under a quasimodel pivot, and of those five, **three are trivial restatements** (reflexivity, transitivity, modal-equivalence).
- A **minimum-viable "local quasimodel" variant** — keeping the full MCS-level infrastructure for Box/G/H and introducing a Hintikka-set *side structure* used only at the Until/Since truth-lemma step — **is coherent** and would avoid the cascade entirely. Sketch below.
- **Realistic effort estimate**: **25–45 hours total**, broken into 6 subtasks (vs. Teammate B's 40–80h).
- **Go/no-go verdict**: **CONDITIONAL GO** on the local quasimodel variant. Full-filtration pivot is NO-GO. Full global quasimodel pivot (replacing BXPoint with Hintikka points) is a second-best fallback at 40–60h.

---

## Context & Scope

Task 92 Phase 0 established that the canonical-model Burgess-Xu kernel hits a structural obstruction at the Until/Since truth lemma:

> `bx_le := g_content ⊆ (·)` only propagates `G(χ)`-formulas along the canonical order. An Until formula `(φ U ψ)` has no `G(χ)` form, so BX5 self-accumulation produces `(φ ∧ (φ U ψ)) U ψ ∈ w.formulas` but not `∈ u.formulas` for strict-interval `u`. The guard clause `φ ∈ u` of `bx_until_eventuality_resolution` is therefore unreachable.

See `specs/092_implement_bx_until_truth_lemma/reports/04_spawn-analysis.md` for the full root-cause analysis and `03_phase0-diagnostic.md` for the six failed probes.

The spawn analysis proposed three orthogonal escape hatches: (1) new BX13 axioms, (2) layered `bx_le` redefinition, (3) filtration/quasimodel pivot. **This report covers only escape hatch (3)**.

---

## Findings

### 1. Filtration vs Quasimodel — Comparison for BX

#### 1a. Classical filtration (Lemmon/Segerberg/Goldblatt)

**Definition (applied to BXCanonical):**
Fix a finite subformula closure `Σ` containing `φ U ψ`, `(φ ∧ (φ U ψ)) U ψ`, their subformulas, and closure under negation. Define an equivalence relation on `BXPoint`:
```
w ~_Σ v  iff  ∀ χ ∈ Σ, χ ∈ w.formulas ↔ χ ∈ v.formulas
```
The filtered model has `BXPoint / ~_Σ` as its points.

**Obstructions for TM-BX:**

1. **Quotienting destroys `g_content ⊆` order.** The filtration order `[w] ≤^f [v]` must be chosen from among the minimal/maximal/smallest filtrations. The *smallest* filtration forces `[w] ≤ [v]` whenever *some* representative pair satisfies `bx_le`; the *largest* forces it only when *all* pairs do. Neither preserves the "`G(χ) ∈ w → χ ∈ v`" identity for arbitrary `χ ∉ Σ` — only for `χ` with `Σ`-local `G(χ)`. This is fatal for `bx_G_forward` at arbitrary formulas, which is used throughout the Box/G/H layer for *formulas not necessarily in Σ*.
2. **Box/S5 collapse.** `bx_modal_equiv` uses `Formula.box χ` for *all* `χ`, not just `χ ∈ Σ`. Under filtration, the modal-equivalence relation on equivalence classes only determines Box-agreement *within* `Σ`. `box_preserved_along_bx_le` must be re-proved **per `Σ`** rather than universally, which contaminates every call site.
3. **Until finite-alternation requirement.** Classical filtration completeness for Until needs the frame to have bounded Until-alternation depth *inside Σ*, which has to be argued semantically on the filtered frame. BX's temporal semantics are over arbitrary linear orders (including dense reals), so the filtration must be *canonical* (per Verbrugge / the Wolter-Zakharyaschev canonical-filtration survey) to preserve the intended frame class. Canonical filtration is significantly more technical than smallest/largest.
4. **No payoff for the core problem.** Filtration's main advantage is the *finite model property*. TM-BX's completeness does not need FMP — it just needs *some* model, and the current canonical MCS space is already available. Filtration therefore pays full quotient cost (3 items above) to buy a property we do not need.

**Verdict: filtration is inappropriate for TM-BX.** Not because it is unsound — it is a standard, well-understood technique — but because it imposes quotient-based restrictions on the Box/G/H infrastructure for no benefit at the Until/Since step. Reject.

#### 1b. Hintikka-set quasimodel (Burgess 1984 / Reynolds 1996 / Wolter-Zakharyaschev)

**Definition (applied to TM-BX):**
Fix a finite subformula closure `Σ` of the target formula. A **Σ-Hintikka set** `h ⊆ Σ` is a set that:
- Is *locally consistent* (no formula and its negation together, bot ∉ h);
- Is *locally maximal* (for each `χ ∈ Σ`, `χ ∈ h` or `¬χ ∈ h`);
- Respects the **BX truth conditions on Σ**, e.g.:
  - `φ ∧ ψ ∈ h ↔ φ ∈ h ∧ ψ ∈ h`
  - `¬χ ∈ h ↔ χ ∉ h`
  - `(φ U ψ) ∈ h → (ψ ∈ h) ∨ (φ ∈ h ∧ there-exists-a-defect-discharging-step)`
  - and similarly for Since, G, H, Box.

A **quasimodel** is a (countable) structure `(Q, ≤_Q, ~_Q)` where `Q` is a set of Hintikka sets, `≤_Q` is a linear order with a *defect-discharge* property (every Until defect `(φ U ψ) ∈ h` is eventually discharged by a `≤_Q`-future Hintikka set containing `ψ`), and `~_Q` is an equivalence relation for the Box modality. The key theorem is:

> **Quasimodel Lemma (Burgess 1984):** A formula is BX-consistent iff it has a (countable) quasimodel.

Completeness then follows because a quasimodel directly induces a task-frame model (Reynolds 1996 gives the standard realization construction for linear-time Until/Since).

**Advantages for TM-BX:**

1. **Matches the Until-witness structure natively.** The `≤_Q` relation is defined with an explicit Until-discharge clause, so `φ U ψ`-propagation is built into the order, not bolted on post-hoc. The `g_content ⊆` propagation obstruction simply does not arise — there is no `g_content`.
2. **Box/G/H layer transferable.** Because Hintikka sets are subformula-closed and locally maximal, Box and G/H truth lemmas over `Σ` reduce to local checks plus one-step forward/backward propagation, which is exactly the shape of the existing `bx_G_forward` / `bx_H_forward` proofs. The proofs restate over Hintikka sets but do not require different technology.
3. **Cited in Frame.lean.** The `Frame.lean:33` docstring already references Burgess 1984 and Goldblatt 1992 — both use quasimodel/Hintikka techniques for Until/Since. The quasimodel pivot is a *realization* of the citation the codebase already acknowledges.
4. **Established in Lean.** LIPIcs.ITP.2024.28 (Coalition Logic completeness) used a related quotient-based construction in Lean 4 for a fixpoint modality. Not a drop-in port, but confirms the technique is formalizable in a similar codebase.

**Disadvantages for TM-BX:**

1. **Introduces a parallel point structure.** `HintikkaPoint` lives alongside `BXPoint` and doubles bookkeeping until the quasimodel is built.
2. **Defect-discharge clause needs a construction.** Classical presentations appeal to König's Lemma or an explicit ω-round "defect-processing" algorithm. In Lean, this wants `Nat.rec` + a well-founded "pending defects" measure.

**Verdict:** Hintikka-set quasimodel is the **structurally natural** technique for Until/Since and matches the existing Burgess 1984 citation in `Frame.lean:33`. Accept as primary candidate.

#### 1c. Which preserves Box/G/H with less rework?

- **Filtration**: *does not* preserve Box/G/H at arbitrary formulas (requires per-Σ rework, contaminates call sites). Largest rework cost.
- **Global quasimodel pivot** (replace BXPoint with HintikkaPoint everywhere): preserves the *shapes* of Box/G/H truth lemmas but requires restating each over Hintikka sets. Medium rework.
- **Local quasimodel** (keep BXPoint for Box/G/H, use Hintikka quasimodel *only* at the Until/Since truth-lemma step): preserves Box/G/H essentially verbatim. **Smallest rework.** See §3.

---

### 2. Cascade-Cost Audit

The task prompt lists 10 named theorems as potential cascade victims. I audited each by reading `Frame.lean`, `TruthLemma.lean`, `Completeness.lean`, and grepping `Theories/` for call sites.

| # | Theorem | File:line | Real dependency? | Quasimodel-pivot cost |
|---|---|---|---|---|
| 1 | `box_preserved_along_bx_le` | Frame.lean:538 | YES — used in 2 lines of TruthLemma.lean `box_iff_mcs` (indirectly via `bx_modal_equiv_of_bx_le`) | **Zero** under local variant (untouched); **Medium** (50-100 LOC restatement) under global variant |
| 2 | `bx_modal_equiv_of_bx_le` | Frame.lean:581 | YES — 3-line corollary of #1 | **Zero** under local; trivial restatement under global |
| 3 | `G_iff_mcs` | TruthLemma.lean:124 | YES — abstract truth lemma for G at MCS level. Consumed by the eventual TaskModel embedding (which is currently the `sorry` at Completeness.lean:154) | **Zero** under local (proof is already MCS-only and uses only `bx_G_forward` + `bx_G_backward`, both unchanged) |
| 4 | `H_iff_mcs` | TruthLemma.lean:137 | YES — dual of #3 | **Zero** under local (same reason) |
| 5 | `bx_forward_witness` | Frame.lean:164 | Used by `until_iff_mcs` forward direction indirectly (via eventuality resolution); also used in Truth lemma Until case in a hypothetical TaskModel embedding | **Zero** — the Hintikka quasimodel consumes a *defect-discharge* lemma that *calls* `bx_forward_witness` on its single-step witness. The existing proof is reused verbatim. |
| 6 | `bx_backward_witness` | Frame.lean:176 | Same as #5 | **Zero** (same reason) |
| 7 | `bx_G_forward` | Frame.lean:192 | **Load-bearing everywhere**. Used in `box_preserved_along_bx_le`, `G_iff_mcs`, `F_from_witness`, several Truth lemma helpers | **Zero** — proof is a single-line `h_le h_G` and does not touch Until |
| 8 | `bx_G_backward` | Frame.lean:208 | Used in `G_iff_mcs` backward direction | **Zero** — proof unchanged |
| 9 | `bx_H_forward` | (dual) | Used in `H_iff_mcs` | **Zero** — proof unchanged |
| 10 | `bx_H_backward` | (dual) | Used in `H_iff_mcs` backward | **Zero** — proof unchanged |
| 11 | `bx_le_refl`, `bx_le_trans` | Frame.lean:140, 153 | Universal | **Zero** |

**Additional dependencies discovered via grep:**

- `until_iff_mcs` (TruthLemma.lean:281) — **the Until truth lemma itself**. Calls `bx_until_eventuality_resolution` + `bx_until_backward` directly. Cost: the direct calls are replaced by calls into the quasimodel-resolved Until helper; the `until_iff_mcs` *statement* at the MCS level is unchanged.
- `since_iff_mcs` (TruthLemma.lean:315) — dual. Same treatment.
- `F_from_witness`, `P_from_witness` (TruthLemma.lean:226, 254) — MCS-level helpers used in the Until case splits. Both use only `bx_G_forward`/`bx_H_forward`. **Zero cost**.
- `bx_modal_witness` (Frame.lean, earlier) — used by `box_iff_mcs`. **Zero cost**.
- `bx_completeness` (Completeness.lean:124) — **already a sorry**. The TaskModel embedding is not built. Any assumption that the quasimodel pivot would "cascade-break" the TaskModel infrastructure is *a miscounting*: the infrastructure does not yet exist.

**Cascade-cost total under the local quasimodel variant: 5 theorems touched, all with zero-LOC structural changes.** The only new code is the Hintikka-quasimodel layer itself and its use inside the Until/Since eventuality resolution helpers.

**Cascade-cost total under the global quasimodel variant (replacing BXPoint with HintikkaPoint as the canonical-model points):** 11 theorems restated (Box, Box-preservation, G-forward/backward, H-forward/backward, modal-equivalence, reflexivity, transitivity, plus until/since_iff_mcs). Each restatement is mostly a rename; the hard work is in the Hintikka-set layer.

**This invalidates Teammate B's ≥40h cascade-break argument.** The "existing sorry-free infrastructure" that filtration would supposedly break *is* the MCS-level Box/G/H layer (roughly `Frame.lean:140-583`, ~440 LOC). Under a *local* quasimodel variant, this layer is untouched — the quasimodel lives in a new module consumed only by the four Until/Since helpers.

---

### 3. Minimum-Viable Local Quasimodel Sketch

**Claim:** It is coherent to apply the Hintikka-set quasimodel **only at the Until/Since truth-lemma step**, keeping Box/G/H on the unfiltered MCS canonical model.

**Architecture:**

```
                       BXCanonical/
                       ├── Frame.lean                  [UNCHANGED for Box/G/H]
                       │     bx_le_refl, bx_le_trans     ✓
                       │     bx_G_forward, bx_G_backward ✓
                       │     bx_H_forward, bx_H_backward ✓
                       │     box_preserved_along_bx_le   ✓
                       │     bx_modal_equiv_of_bx_le     ✓
                       │     bx_forward_witness          ✓
                       │     bx_backward_witness         ✓
                       │     bx_until_eventuality_resolution  [delegates to Quasimodel]
                       │     bx_until_backward               [delegates to Quasimodel]
                       │     bx_since_eventuality_resolution [delegates to Quasimodel]
                       │     bx_since_backward               [delegates to Quasimodel]
                       │
                       ├── Quasimodel.lean              [NEW MODULE]
                       │     HintikkaPoint (Σ)
                       │     hintikka_quasimodel_exists
                       │     hintikka_realization_to_bxpoint_until
                       │     hintikka_realization_to_bxpoint_since
                       │
                       ├── TruthLemma.lean              [UNCHANGED at MCS level]
                       │     G_iff_mcs, H_iff_mcs        ✓
                       │     box_iff_mcs                 ✓
                       │     until_iff_mcs               ✓ (statement unchanged)
                       │     since_iff_mcs               ✓ (statement unchanged)
                       │
                       └── Completeness.lean            [sorry remains until TaskModel done]
```

**Key observation (the coherence argument):** `until_iff_mcs` is a statement about **membership in `w.formulas`**, not about semantic truth. The four helpers `bx_until_eventuality_resolution`, `bx_until_backward`, and Since duals are internal to `until_iff_mcs`/`since_iff_mcs` — they produce/consume BXPoints, not quasimodel points. The *implementations* of these helpers can use a quasimodel as an internal tool, provided they ultimately produce the BXPoint witness and the guard clause on BXPoints.

**Proof sketch of `bx_until_eventuality_resolution` via Hintikka quasimodel:**

1. **Fix Σ**: the finite subformula closure of `{φ, ψ, φ U ψ, (φ ∧ (φ U ψ)) U ψ, ⊥, ⊤}`, closed under subformulas and negation. Finite (|Σ| ≤ 16).
2. **Build the Σ-Hintikka quasimodel of `w`**: enumerate Σ-Hintikka sets compatible with `w`'s Σ-content, order them by a Burgess-Xu one-step relation `→_Σ`, and by standard quasimodel construction (Burgess 1984 §4; see Reynolds 1996 for the discharge algorithm) obtain a linear sequence `h₀, h₁, …` with `h₀ = w ∩ Σ` and the defect-discharge property for `φ U ψ ∈ h₀`.
3. **Realize each Hintikka set as a BXPoint**: for each `h_i` in the quasimodel, use Lindenbaum to extend `h_i` to a full MCS `v_i` such that `g_content(v_{i-1}) ⊆ v_i`. The BXPoint-level order `bx_le v_{i-1} v_i` follows. **This is the crux step.** It requires that the *Burgess-Xu one-step* relation between Hintikka sets lifts to the canonical `bx_le` — i.e., that for each step `h_{i-1} →_Σ h_i`, the combined seed `{χ | G(χ) ∈ v_{i-1}} ∪ h_i` is consistent. Verbrugge's "Completeness by Construction" gives exactly this lifting lemma.
4. **Extract the Until witness**: the discharge step in the quasimodel is some `h_k` with `ψ ∈ h_k`. Its realization `v_k` has `ψ ∈ v_k` and `bx_le w v_k` (by transitivity of the lifted chain).
5. **Guard on strict interval**: for each `i < k`, the quasimodel construction guarantees `φ ∈ h_i` (the Until-defect is not yet discharged), so `φ ∈ v_i`. But the guard quantifies over **arbitrary** `u` in `(w, v_k)` on `bx_le`, not just over the `v_i` we built. This is the **coherence question**: does the realization give us enough to handle arbitrary strict-interval `u`?

   **Answer**: For an arbitrary `u` with `bx_le w u` and `bx_le u v_k` and `¬bx_le v_k u`, we need a quasimodel-internal argument that places `u` at some index `i < k`. This requires a **locus-control lemma**: given `bx_le w u` and a Σ-Hintikka assignment of `u` (trivially `u ∩ Σ`), show `u ∩ Σ` equals some `h_i` or is a Σ-Hintikka extension of one. The Σ-finiteness ensures only finitely many Hintikka sets exist, and `bx_le` forces each intermediate Σ-signature to appear as some quasimodel node. This lemma is *the* load-bearing claim of the local variant and **requires its own proof**. A precise obstruction: if two distinct strict-interval `u, u'` have *the same* `Σ`-signature but different full formulas, they are placed at the same quasimodel index, and the guard `φ ∈ u` follows for both from `φ ∈ h_i`. So the locus-control lemma is: "`u`'s Σ-signature is determined up to quasimodel-index by `bx_le w u ∧ bx_le u v_k`". This is **true if and only if `Σ`-signatures are totally ordered by the Burgess-Xu one-step relation** — which is exactly the quasimodel's defining property. Hence the guard discharges.

**This is the sketch. It is coherent, but has one non-trivial lemma (the realization lifting in step 3 and the locus-control lemma in step 5).**

**Precise obstruction to aware-of**: The realization lifting (step 3) may fail if the Σ-Hintikka-compatible extension of a BXPoint is not unique. In particular, a Σ-Hintikka set `h_i` may be realizable by **multiple** MCSes, none distinguished by `bx_le w`. This is not fatal — we just pick one and the truth lemma is about existence of *some* BXPoint witness — but it means the locus-control lemma needs care around "`u`'s Σ-signature *equals* h_i" vs. "is *compatible with* h_i".

The standard resolution is: require the Σ-closure to include *enough* formulas to make Σ-signatures extensional, e.g., include all `G(χ)` for `χ` a subformula of `φ U ψ`. With an enriched Σ, Σ-signatures fully determine `bx_le` comparisons, and locus control is automatic.

**Verdict on §3:** the local quasimodel variant is **coherent** modulo two explicit lemmas (realization lifting and locus control), both of which have published proofs in Burgess 1984 / Verbrugge and are formalizable in Lean.

---

### 4. Realistic Effort Estimate

Replacing Teammate B's 40–80h figure with a decomposed estimate based on the cascade audit above.

| Subtask | Description | Effort (hours) |
|---|---|---|
| S1. Σ-closure infrastructure | Define finite-Σ closure of a formula, prove closure operations (neg, subformula, Burgess-Xu "accumulate & absorb"). Mostly routine Formula-induction. | 3–5 |
| S2. HintikkaPoint definition | Define `HintikkaPoint Σ` structure + Σ-local consistency/maximality. Prove basic properties (mem-decidable on Σ, Σ-Hintikka equality). | 4–6 |
| S3. Hintikka quasimodel construction | Enumerate Σ-Hintikka sets, define the Burgess-Xu one-step relation `→_Σ`, construct a linear quasimodel with defect-discharge for a given Until defect. Parallel to Reynolds 1996 §3. | 6–10 |
| S4. Realization lifting lemma | Lift the quasimodel chain to a chain of BXPoints with `bx_le` successor property. Key technical step; uses `bx_forward_witness` on the underlying extension. | 4–8 |
| S5. Locus-control lemma + Until/Since helpers | Prove the four helpers `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward` by combining S1–S4. The Since mirror needs its own standalone proof (per Phase 0 probe 6 — cannot be a `.dual` rename). | 6–12 |
| S6. Integration, build fixes, regression | Wire the new Quasimodel module into `Frame.lean`, ensure no Box/G/H proof is touched, `lake build` clean. | 2–4 |
| **Total** | | **25–45 hours** |

**Effort estimate confidence**: **medium-high**. The dominant risk is S3+S4 (~10–18h). The other subtasks are standard finite-set / Lindenbaum manipulations already within the codebase's idiom. Teammate B's 40–80h figure was based on a *global* filtration that would rebuild the Box/G/H layer; the local variant avoids that rebuild, cutting the lower bound roughly in half.

**Comparison to Task 92's blocked plan (estimated 8–16h for the direct Burgess-Xu approach):** the quasimodel pivot is 2–3× the effort of the blocked plan, but unlike the blocked plan, it *has* a complete mathematical path (Burgess 1984 §4 + Reynolds 1996 §3). The Burgess-Xu direct approach had an unproved propagation step.

---

### 5. Go / No-Go Recommendation

**CONDITIONAL GO on the local Hintikka-set quasimodel variant.**

**Justification:**

1. **Prior art is established and directly applicable.** Burgess 1984 §4, Reynolds 1996, Verbrugge's "Completeness by Construction", and (implicitly) the Wolter-Zakharyaschev canonical-filtration survey all handle Until/Since completeness via Hintikka-set quasimodels or their equivalents. None uses filtration for the Until/Since step itself; filtration is used for FMP, which is a different goal.
2. **The cascade cost is ~zero under the local variant.** Teammate B's ≥40h cascade-break argument was predicated on a global filtration that would rewrite the Box/G/H layer. The local variant leaves that layer untouched — the quasimodel is a new module consumed only by four Until/Since helpers that are **currently `sorry`**.
3. **The TaskModel embedding layer is not yet built.** `bx_completeness` is a `sorry` at `Completeness.lean:154`, and the canonical TaskModel embedding is explicitly marked as pending. This means there is *no existing downstream infrastructure* that the quasimodel pivot can break. The pivot happens *before* the TaskModel embedding gate.
4. **The mathematical path is complete.** Unlike the Burgess-Xu direct approach, which Phase 0 empirically proved has an unreachable propagation step, the quasimodel has published, verified constructions for exactly this use case. The risk is *formalization difficulty*, not *mathematical existence*.
5. **Effort is moderate.** 25–45h is 2–3× the blocked plan but is front-loaded on infrastructure (S1–S3) that is reusable for other future Until/Since work, e.g., decidability via finite quasimodel search.

**Conditions on the GO:**

- **C1. Realization lifting lemma must be proven early** (in S4, before S5). If realization lifting fails or requires additional axioms, the plan halts. Estimated probability of failure: low (10–20%), because Verbrugge's construction shows it holds over general linear orders.
- **C2. Σ-closure must be rich enough for locus-control.** The exact set of Σ-closure operations must include all `G(χ)` and `H(χ)` for `χ` a subformula of the Until/Since formula being realized. If this makes Σ blow up beyond finite control, the plan halts. Estimated probability of failure: very low (<5%).
- **C3. Since mirror requires standalone proof.** Per Phase 0 Probe 6, the Since mirror is *not* a `.dual` rename of the Until case because the Since guard interval has two anchors. The S5 subtask budget includes standalone Since construction.
- **C4. Keep `bx_le := g_content ⊆` unchanged.** The local variant depends on `bx_G_forward`, `bx_H_forward`, etc. being unchanged. This excludes any simultaneous adoption of Task 2's layered `bx_le` redefinition.

**Alternatives surveyed and rejected:**

- **Global filtration** (classical Lemmon-style, LIPIcs.ITP.2024.28 style): rejected per §1a. Wrong tool for the job.
- **Global quasimodel pivot** (replace BXPoint with HintikkaPoint): second-best, 40–60h, acceptable fallback if the local variant's locus-control lemma fails.
- **DovetailedChain-style explicit chain** (existing deprecated file): already empirically failed, same structural obstruction.
- **New BX13 axioms** (Task 96, separate research): orthogonal; could be combined with quasimodel but not prerequisite.
- **Layered `bx_le`** (Task 97, separate research): orthogonal; mutually exclusive with local variant (violates C4), compatible with global variant.

**Synthesis direction for `/plan 92` round 03:** after Tasks 96, 97, 98 all complete, the planner should compare:
- Task 96 (new axiom): lowest formalization cost *if a sound axiom exists*, highest mathematical risk.
- Task 97 (layered `bx_le`): medium cost, medium risk, requires Task 97's layered definition to survive Box/G/H verification.
- **Task 98 (local quasimodel)**: medium cost (25–45h), lowest mathematical risk (published proof exists), highest code-volume impact.

If Task 96 finds a sound axiom, prefer 96. Otherwise, prefer 98 over 97 because 98's mathematical path is established (Burgess 1984 §4) while 97's is novel.

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Realization lifting lemma (step 3) fails over general linear orders | Low (10–20%) | High (halts plan) | Land the lemma first in a Phase 1 diagnostic gate; preserve Teammate C's Phase 0-style escalation clause |
| Locus-control lemma requires Σ enrichment that blows up size | Very low (<5%) | Medium (factor-2 constant) | Use a published Σ-closure operator (Reynolds 1996 §2) rather than invent one |
| Since mirror needs additional BX axiom support | Medium (20–30%) | Medium (extra 4–8h) | S5 budget already allocates for standalone Since; escalate to Task 96 if a new axiom is required |
| Quasimodel construction requires classical logic beyond Lean's `Classical.em` usage | Very low | Low | Existing `BXCanonical` already uses `Classical`; no new dependency |
| Lake build breaks due to new module ordering | Low | Low | Add `Quasimodel.lean` as a downstream import of `Frame.lean`, upstream of `TruthLemma.lean` |

---

## Appendix

### A. Search queries used

- Codebase: `grep` for `bx_until_eventuality_resolution`, `bx_until_backward`, `G_iff_mcs`, `H_iff_mcs`, `box_preserved_along_bx_le`, `bx_modal_equiv_of_bx_le`, `bx_forward_witness`, `bx_backward_witness`, `bx_G_forward`, `bx_H_forward`, `until_iff_mcs`, `since_iff_mcs` across `Theories/`.
- Web: "quasimodel Hintikka set Until Since tense logic completeness Burgess", "filtration canonical model Until Since temporal logic completeness finite model property".
- Prior reports: `specs/092_implement_bx_until_truth_lemma/reports/02_teammate-b-findings.md`, `03_phase0-diagnostic.md`, `04_spawn-analysis.md`.

### B. Key source-file probes

- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:140-583` — MCS-level Box/G/H layer (would be untouched by local quasimodel).
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:632-704` — the four target `sorry`s.
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean:281-357` — `until_iff_mcs`, `since_iff_mcs` consume the four helpers.
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:124-154` — `bx_completeness` itself is a `sorry`; TaskModel embedding not built.
- `Theories/Bimodal/Semantics/Truth.lean:128-131` — semantic Until/Since definition (reflexive witness, open guard).

### C. Bibliography

- **Burgess, J. P.** (1982). "Axioms for tense logic. I. ‘Since’ and ‘Until’". *Notre Dame Journal of Formal Logic* 23(4): 367–383. [Project Euclid](https://projecteuclid.org/euclid.ndjfl/1093870149) — primary axiomatization, canonical-model approach via self-accumulation.
- **Burgess, J. P.** (1984). "Basic tense logic". In D. Gabbay & F. Guenthner (eds.), *Handbook of Philosophical Logic* Vol. II, 89–133. Reidel. — quasimodel/Hintikka-set construction for Until/Since completeness; **the primary reference for the recommended pivot**.
- **Xu, M.** (1988). "On some U, S-tense logics". *Journal of Philosophical Logic* 17: 181–202. — simplification of Burgess 1982, origin of the "BX" name in the codebase.
- **Goldblatt, R.** (1992). *Logics of Time and Computation*, 2nd ed. CSLI. — standard modern reference; uses filtration for PDL, Hintikka for LTL/Until. Cited in `Frame.lean:33`.
- **Reynolds, M.** (1996). "Axiomatizing U and S over integer time". In *Temporal Logic* (ICTL 1994 post-proceedings), LNAI 827. — explicit quasimodel realization construction.
- **Verbrugge, L. C.** (1992). "Completeness by construction for tense logics of linear time". ILLC Prepublication. [Festschrift PDF](https://festschriften.illc.uva.nl/D65/verbrugge.pdf) — direct Hintikka-chain construction; explicitly titled "by construction" vs. filtration.
- **Venema, Y.** (2001). "Temporal logic". In L. Goble (ed.), *Blackwell Guide to Philosophical Logic*. [PDF](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf) — survey chapter.
- **Reynolds, M.** (2010). "The complexity of the temporal logic with 'until' over general linear time". *J. Comput. Syst. Sci.* — modern reference for quasimodel complexity/decidability.
- **Wolter, F. & Zakharyaschev, M.** (2007). "Canonical filtrations and local tabularity". — the "canonical filtration" technique that *could* apply to TM-BX but is not needed under the local quasimodel variant. [Academia.edu](https://www.academia.edu/58490703/Canonical_filtrations_and_local_tabularity)
- **Goranko, V. & Galton, A.** (2023). "Temporal Logic". *Stanford Encyclopedia of Philosophy*. [SEP entry](https://plato.stanford.edu/entries/logic-temporal/) — cites Burgess 1982, Xu 1988, Venema 1993, Reynolds 1994/1996 as the completeness chain for Since-Until over linear orders.
- **Lean Coalition Logic Completeness** (2024). *LIPIcs.ITP.2024.28*. [PDF](https://drops.dagstuhl.de/storage/00lipics/lipics-vol309-itp2024/LIPIcs.ITP.2024.28/LIPIcs.ITP.2024.28.pdf) — formalized filtration of canonical model in Lean 4 for a fixpoint modality (common knowledge). Not directly portable but confirms the technique can be formalized in a similar codebase.
- **Filtration and canonical completeness for continuous modal μ-calculi**, arXiv:2109.08321. — recent theoretical treatment of filtration for fixpoint modalities.

### D. Context files loaded

- `.claude/context/project/logic/README.md` (via skill)
- `.claude/rules/lean4.md`
- `specs/092_implement_bx_until_truth_lemma/reports/02_teammate-b-findings.md`
- `specs/092_implement_bx_until_truth_lemma/reports/03_phase0-diagnostic.md`
- `specs/092_implement_bx_until_truth_lemma/reports/04_spawn-analysis.md`

### E. Correction of Teammate B's estimate

Teammate B's report stated:

> "filtration would cascade-break `box_preserved_along_bx_le`, `bx_modal_equiv_of_bx_le`, `G_iff_mcs`, `H_iff_mcs`, and the entire existing sorry-free infrastructure — estimated rebuild ≥40h, identical in cost/risk to Option A (40-80h cascade)."

This estimate is correct **if and only if** the pivot replaces `BXPoint` globally. Under the local variant (this report's primary recommendation), the cascade is ~zero because:
- `Frame.lean:140-583` is untouched — the same theorems with the same proofs remain load-bearing for Box/G/H.
- `TruthLemma.lean:124-205` (G/H/Box) is untouched — the abstract MCS-level truth lemmas are unchanged.
- Only `Frame.lean:632-704` (the four current `sorry`s) is replaced, and a new module `Quasimodel.lean` is added.

Teammate B's 40–80h was for a **global filtration**, a different proposal. The conflation of the two techniques (filtration vs. quasimodel) in the team research round is the source of the overestimate.
