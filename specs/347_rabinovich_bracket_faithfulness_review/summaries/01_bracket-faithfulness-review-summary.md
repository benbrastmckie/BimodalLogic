# Task 347 — Rabinovich Bracket Faithfulness Review + R1 Revision — Execution Summary

- **Task**: 347 — rabinovich_bracket_faithfulness_review (lean4)
- **Session**: sess_1783792054_45a555
- **Date**: 2026-07-11
- **Plan**: `specs/347_rabinovich_bracket_faithfulness_review/plans/01_bracket-faithfulness-revision.md`
- **Report**: `specs/347_rabinovich_bracket_faithfulness_review/reports/01_bracket-faithfulness-adjudication.md`
- **Ground truth**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md` (§5, pp.7–11)
- **Outcome**: all 4 phases COMPLETED; full build green + axiom-clean; empty sorry inventory on 347 live paths.

---

## Verdict (from research report 01, H4-verified)

**(b) SUBSTANTIVE — with a sharpening that changes the successor's method.** The task-346 `hexclExt`
gate did **not** drop per-witness ordering content (the `.order` atoms are present and
`nf0_zoneSpec` is a lossless bijective projection of them). What it dropped is Rabinovich's **bound
on the OUTER existential** (`(∃z)^{<z1}_{>z0}`, Cor 5.4): `nf_eval_nf` (`NormalForm.lean:203–207`)
quantifies the fresh witness over **all of `M.carrier`** (unbounded), so the characterized `qnf`
globalizes over **exterior-arrangement** subs that Rabinovich's `(z0,z1)`-bracket never
characterizes. `hexclExt` is the residue of that globalization — a **phantom obligation with no §5
counterpart**. The faithful fix is Rabinovich's **Prop 4.3 re-flatten** (adjacency composition of a
separate exterior bracket), NOT an exterior-exclusion proof on the interior `(x,t)` bracket.

---

## Phases Executed

### Phase 1 — Interior-slice order-atom discharge lemma [COMPLETED] (commit `d370d438e`)

Proved, in isolation (below the SW:10210 341 GATE banner), that a strictly-exterior `x1` falsifies
an interior-marked σ directly from the depth-0 atom clause:
`(nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3) → ¬(x ≤ x1 ∧ x1 ≤ t) →
¬ nf_eval_nf M 1 4 (Fin.cons x1 …) σ`. Proof routes through the falsified strict `.order` atom
(literature-fidelity policy: no blanket `simp`/`decide` over `nf_eval_nf`). Scoped
`SharedWitness` build green; `#print axioms` = `{propext, Classical.choice, Quot.sound}`, no
`sorryAx`.

### Phase 2 — Narrow `hexclExt` to exterior-marked σ; re-thread fold + OuterGate [COMPLETED] (commit `3b8aee3c4`)

Consumed the Phase-1 lemma so the deferred `hexclExt` binder ranges only over exterior-marked σ.
Landed narrowed binder shape (verbatim, `OuterGate.lean:280`, mirrored `SharedWitness.lean:12665`
`kvE2_outer_fold_frag`):

```
(hexclExt : ∀ w, x < w → w < t → (…).eval_at M atomMap w →
   ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
     ¬ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) →   -- NEW: exterior-marked only
     ∀ x1, ¬ (x ≤ x1 ∧ x1 ≤ t) →
       ¬ nf_eval_nf M 1 4 (Fin.cons x1 …) σ)
```

The discharge site does `by_cases` on the interior-zone predicate: interior-marked branch closes via
the Phase-1 lemma (no residue), exterior-marked branch closes via the narrowed `hexclExt`. Both
theorem sites (`kvE2_outer_fold_frag`, `bracketEndChar_kvE2_sound_two_prior_frag`) re-threaded. Full
`lake build` green; the three key theorems axiom-clean; sorry-inventory delta = 0 on live paths (the
pre-existing `BXCanonical.completeness*` `sorryAx` is task-155 residue, NOT a 347 regression).

**Net effect**: the deferred obligation shrank from "all `qnf`-false σ" to "exterior-arrangement σ
only" — the report's "phantom obligation" characterization is now machine-visible.

### Phase 3 — Retire-and-replace the successor spec [COMPLETED] (commit `3d024cf16`)

In `specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md`:
marked the `prop43_exterior_completeness` framing **RETIRED** (phantom completeness theorem, no §5
counterpart) and replaced it with **`prop43_exterior_reflatten`**: restore interval-bounding
faithfulness by re-flattening the exterior witness arrangement (Rabinovich Prop 4.3 p.6 + Lemma 7.6
p.13 adjacency) into a **separate** exterior bracket composed with the interior `(x,t)` bracket; R1
landed first. Dependency graph (346/335/309), 330/335 grounding, and the `Prop43.lean:120–159`
entry point preserved. Reconciliation recorded: 346's *pointer* ("Prop-4.3 successor") is correct;
its *mechanism* ("exterior exclusion on this gate") is wrong; 347 adjudicates for 330/335's
re-flatten mechanism.

### Phase 4 — Record adjudication for consumers [COMPLETED] (this dispatch)

Three consumer records, each citing report 01 + the post-R1 narrowed binder shape:

1. **prop43 successor decision** — recorded here and in the 346 summary (Phase 3, commit
   `3d024cf16`): RETIRE "prove exterior completeness"; REPLACE with `prop43_exterior_reflatten`
   (Prop 4.3 re-flatten); R1 landed first.
2. **Task 309 Phases 13.4/14 (+ `KampPrior.lean:351`)** — adjudication note appended to
   `specs/309_offdiag_two_anchor_fi_chain/plans/07_offdiag-fi-chain-plan.md`: consume an
   interior+boundary gate **+ adjacent exterior bracket**, seam at anchors `x,t`; do NOT expect a
   single all-arrangement `(x,t)` gate. Exterior arrangements `x1<x` / `x1>t` belong to the adjacent
   intervals `(−∞,x)` / `(t,∞)` (Prop 4.3 / Lemma 7.6 re-flatten). `KampPrior.lean:351` stays
   DEFERRED to the successor — **recorded only, no Lean edit** (plan Phase 4 does not direct a
   KampPrior comment annotation; keeping Lean files untouched guarantees the build is unaffected).
3. **Task 335 Phase D** — adjudication note appended to
   `specs/335_outer_gate_assembly_engine_kvE2_body/plans/05_fragment-gate-v5.md`: re-shape the
   provider obligation to **bounded interior + jointly-ordered** witnesses (Cor 5.4 ⇐), routed
   through `kvE2_sepPosI` (`SharedWitness.lean:211–214`), NOT the global `kvE2_sepPos`. The landed
   `hreal` (over global `kvE2_sepPos`, decoupled/unbounded) is accidentally adequate for the n=1
   interior singleton but does not generalize to `On` (n≥2).

---

## Verification Results

- **Build**: full `lake build` green as of Phase 2 landing (`3b8aee3c4`); Phases 3/4 touch only
  markdown → no build impact. No Lean file edited in Phase 4.
- **Axioms**: `kvE2_outer_fold_frag`, `bracketEndChar_kvE2_sound_two_prior_frag`,
  `kvE2_sepBody_kit_sound_frag` = `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- **Sorry inventory (347 live paths)**: EMPTY. Pre-existing out-of-scope sorries (`KampPrior.lean:351`
  n=1/n≥2, `BXCanonical.completeness*`) are NOT 347 regressions and were not touched.
- **Preserved assets**: all task-346 landings (fold interface, soundness half, kit, non-vacuity
  witness, interior index lemmas) intact; nothing above the SW:10210 341 GATE banner edited.

---

## Files Changed (this task, all phases)

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — Phase 1
  interior-slice lemma + Phase 2 narrowed `hexclExt` binder + re-threaded discharge.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — Phase 2
  narrowed soundness-half binder + call.
- `specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md` —
  Phase 3 retired-and-replaced successor spec.
- `specs/347_rabinovich_bracket_faithfulness_review/plans/01_bracket-faithfulness-revision.md` —
  phase status markers.
- `specs/309_offdiag_two_anchor_fi_chain/plans/07_offdiag-fi-chain-plan.md` — Phase 4 consumer note.
- `specs/335_outer_gate_assembly_engine_kvE2_body/plans/05_fragment-gate-v5.md` — Phase 4 consumer note.
- `specs/347_rabinovich_bracket_faithfulness_review/summaries/01_bracket-faithfulness-review-summary.md` —
  this summary.

---

## Follow-up Task Instantiation (gaps for the USER — no tasks created by this dispatch)

Task 347 delivered R1 (the smallest faithfulness-restoring revision) and recorded the adjudication.
The following remain **uninstantiated** and require the user to invoke `/task`, `/spawn`, or
`/revise` — this dispatch deliberately did NOT create or renumber any task:

1. **`prop43_exterior_reflatten` successor — NOT yet instantiated as a task.** The spec is fully
   written and `/task`/`/spawn`-createable verbatim from
   `specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md`
   (section "prop43_exterior_reflatten"). It needs a `/task` (new task) or `/spawn 309` invocation to
   become a live task. Scope: re-flatten the exterior arrangement via Prop 4.3 + Lemma 7.6 adjacency
   (a separate exterior bracket), consuming the landed R1 residue narrowing. This is the R2 route.
2. **Task 309 v8 re-point — needs `/revise 309`.** Plan 07 now carries the Phase 4 consumer note, but
   the plan body (Phases 13.4/14) has not been re-pointed to the interior+boundary + adjacent-exterior
   model. A `/revise 309` should fold the consumer note into the phase specs and fragment-scope the
   `KampPrior.lean:351` discharge.
3. **Task 335 Phase D re-shape — needs `/revise 335`.** Plan 05 now carries the Phase 4 consumer note
   re-shaping the provider obligation to bounded-interior + jointly-ordered (`kvE2_sepPosI`, Cor 5.4
   ⇐). Since 335 is [BLOCKED] on Phase C (`hexcl` NO-GO), a `/revise 335` should re-express Phase D's
   provider obligation against `kvE2_sepPosI` and route the residual exterior slice to the
   `prop43_exterior_reflatten` successor rather than an in-335 discharge.

No Lean-code follow-up is required to keep the current build green — R1 is self-contained and landed.
