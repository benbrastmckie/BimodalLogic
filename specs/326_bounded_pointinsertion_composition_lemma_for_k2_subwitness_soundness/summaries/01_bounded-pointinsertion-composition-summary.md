# Task 326 — Bounded Point-Insertion Composition Lemma for k=2 Sub-Witness Soundness — Summary

**Status:** COMPLETED (implemented) — all 8 phases green, axiom-clean, purely additive.
**Session:** sess_1783452940_63339e

## What was delivered

Task 326 supplies the missing forward composition that lets task 321 Phase 10 discharge k=2
sub-witness soundness WITHOUT the documented-unprovable reverse Cor 5.4 direction. This dispatch
executed the final two phases (5 and 6) that close the task.

### Phase 5 — bundle the deliverable and feed the consumer

Three additive declarations appended to `NfMultiAnchorBridge.lean` (after
`kvE_subBracket2V_sound_of_parts` :7719, before the Task-325-v2 non-vacuity block):

1. `bracketFromLists_flatMap_subchain_below_pin` (private helper, ~:7789) — generalizes Phase 1's
   single-head `bracketFromLists_flatMap_block_extract` (`head b :: tail b`) to the actual k=2
   outer block shape `subChain b ++ pins b` (a MULTI-element sub-chain list ++ pins), exactly
   `kvE2_body`'s `slotsFor lL = lL.flatMap (fun σ => kvE_subChain2V charBase charK σ ++ pinSlots σ)`
   (:8502-8506). Given any chosen pin `p0 ∈ pins a`, it produces `q` realizing `p0` and shows
   EVERY `fcp ∈ subChain a` is realized strictly below `q` — because the whole sub-chain segment
   PRECEDES the pins segment in the contiguous monotone witness block, so every sub-chain witness
   carries a smaller monotone index than any pin witness. This DISCHARGES the flagged `hreal`
   obligation. LITMUS-clean: the `< q` bound rides the `ws` monotonicity (`k1v_bracket_extract_mono`),
   never an `x1<e_i`/`u<e_i` formula literal.

2. `kvE_sub2V_bounded_anchor_of_outer` (public deliverable, ~:7906) — the task's named terminus.
   From the outer bracket's soundness-side `.holds` on `(x, t)` and the anchor pin
   `p0 = ⟨charK (nfk_projFresh σ)⟩ ∈ pins σ`, assembles the bounded-anchor bundle
   `(q, x<q, q<t, hanchor, hbelow)`: applies the multi-element helper to get `q` + `hreal`, then
   feeds `hreal` to Phase 4.2's `kvE_subChain2V_hbelow_of_realized` to obtain `hbelow`.

3. `kvE_subBracket2V_sound_of_outer` (public composition, ~:7962) — chains the deliverable (at
   the standard `charBase = nf_depth0_char_formula atomMap h_surj`) directly into
   `kvE_subBracket2V_sound_of_parts`, PROVING BY CONSTRUCTION that the bundle instantiates the
   consumer's `(x1, hxx1, hx1t, hanchor, hbelow, hgate)` argument types EXACTLY (anchor
   `⟨charK (nfk_projFresh σ)⟩` and below-anchor `⟨nf_depth0_char_formula atomMap h_surj χ⟩`
   witnesses unify with no coercion). The consumer was NOT edited.

### Phase 6 — verification and axiom-clean sweep

- Three-module scoped build green (1005 jobs); FULL project build green (1709 jobs).
- Axiom sweep (via `lean_verify`) on every task-326 additive lemma:
  `[propext, Classical.choice, Quot.sound]` (Phase 4.1 `exists_permutation_cons_head` uses the
  subset `[propext, Quot.sound]`). No `sorryAx` anywhere.
- Zero live-path `sorry` in the task-326 additive region. The only `sorry` tactics in scope are the
  two pre-existing EANegation baseline sorries (declarations :834/:1129, tactics :1090/:1249), off
  the completeness live path, untouched.
- DO-NOT-EDIT assets byte-identical: the NfMultiAnchorBridge diff is purely additive (178 lines
  inserted, zero deletions/modifications); EANegationClosure/EANegation untouched. Zero vacuous
  definitions; zero new axioms.

## Deliverable signature (for task 321 Phase 10 re-point)

```lean
theorem kvE_sub2V_bounded_anchor_of_outer {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (l : List (NormalForm sig 1 4)) (pins : NormalForm sig 1 4 → List TemporalPred)
    (ptW segL segR : TemporalPred) (lR : List TemporalPred)
    (x t : M.carrier) (hσl : σ ∈ l)
    (p0 : TemporalPred) (hp0 : p0 ∈ pins σ)
    (hp0eq : p0 = (⟨charK (nfk_projFresh σ)⟩ : TemporalPred))
    (h : (bracketFromLists (l.flatMap (fun b => kvE_subChain2V charBase charK b ++ pins b))
          ptW lR segL segR).holds M atomMap x t) :
    ∃ q : M.carrier, x < q ∧ q < t ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap q ∧
      (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ u : M.carrier, x < u ∧ u < q ∧ (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u)
```

The companion `kvE_subBracket2V_sound_of_outer` bundles this with
`kvE_subBracket2V_sound_of_parts` for a single end-to-end entry point.

## Literature fidelity

Rabinovich 2014 Lemma 5.1 (pin bound, md:169-171), Lemma 5.3 (arrangement coverage, md:137-152),
Cor 5.4 forward bounded interior placement (md:154-157). Cor 5.4's reverse direction is
deliberately sidestepped (documented unprovable at EANegation :1217-1234 / report 18 §10.3).

## Follow-on

Task 321 resumes: `/revise 321` (v5) re-pointing Phase 10 at
`kvE_sub2V_bounded_anchor_of_outer` + `kvE_subBracket2V_sound_of_parts` (or the single
`kvE_subBracket2V_sound_of_outer`), then `/orchestrate 321`.

## Artifacts

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (additive: three new decls)
- `specs/326_.../plans/01_bounded-pointinsertion-composition.md` (Phases 5, 6 marked COMPLETED)
- `specs/326_.../summaries/01_bounded-pointinsertion-composition-summary.md` (this file)
