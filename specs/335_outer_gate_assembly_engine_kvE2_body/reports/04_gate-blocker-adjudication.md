# Research Report: Task 335 — Gate-Blocker Adjudication (Branch (a) vs (b))

- **Task**: 335 - outer_gate_assembly_engine_kvE2_body
- **Status**: [IMPLEMENTING] (partial — Phase 3 landed; Phases 4a/4b/4c blocked)
- **Date**: 2026-07-10
- **Session**: sess_1783723095_edd5a7_335 (blocker-escalation research fork)
- **Type**: lean4 (research only — no source edits)
- **Inputs**: handoffs/01_continuation.md; OuterGate.lean BLOCKER note (:212-250);
  CarrierKv.lean:422 (`bracketEndChar_kv_factors`); SharedWitness.lean:6698-6791 (O4 CRUX
  RECORD), :9897-10036 (`kvE2_outer_fold`); PriorInterface.lean:38-73; KampPrior.lean:347-354;
  specs/309 reports/07 + plans/07; task 321 scope amendment (TODO.md, verdict N2)

## Executive Summary

**Verdict: `b-weaken-fragment`.** Branch (a) as stated (derive the four gate families from
`.holds` inside SharedWitness) is **REFUTED** — semantically, not organizationally: no file
ownership change fixes a statement that is false in a rich model. Branch (b-strengthen)
(higher-arity `charK` provider) is **REFUTED-BY-AUDIT** (the 330 category-error finding) with
prohibitive blast radius. The one viable, already-sanctioned path is the **single-positive-sub
fragment gate**: task 321's decision-gate verdict N2 (scope amendment, 2026-07-07) explicitly
re-scoped the GO/NO-GO deliverable for 309 Phase 13.4 + KampPrior.lean:351 to this fragment, and
the O4 CRUX RECORD states the obstruction residue **vanishes** there. Crucially, the fragment
route needs **no SharedWitness.lean edit**: the fold takes the four families as hypotheses, and
335 discharges them *under a fragment hypothesis on `qnf`* entirely inside its own territory
(OuterGate.lean). `spawn_needed: false` for the current unblock; the multi-positive case remains
the deferred successor task 321-N2 already named (bit-compatibility filtering — a carrier
re-definition).

## Verdict Table

| Branch | Viable? | Evidence |
|--------|---------|----------|
| (a) reshape SW to derive gate from `.holds` | **REFUTED** (general qnf) | Forward clause refutable in a rich model for arbitrary `qnf` (handoffs/01 pt 4; OuterGate.lean:235-236) — `.holds → gate` is FALSE, so no proof exists regardless of ownership. O4 CRUX RECORD channel exhaustion: "no derivation exists, not merely none found" (SW:6742-6752); the only faithful repair is bit-compatibility filtering = carrier re-definition with O1b/O2/O3 knock-on rework (SW:6763-6770) — the deferred successor, not a 335 unblock. `bracketEndChar_kv_factors` (CarrierKv.lean:422) machine-certifies the (zone, projected 1-type) information ceiling. |
| (b-strengthen) higher-arity `charK` | **REFUTED-BY-AUDIT** | 330 audit: joint multi-anchor content is carried by NAVIGATED evaluation position (Prop 3.5/Cor 5.4, PDF pp.5,9), never by richer static atoms; E[Σ] point types are quantifier-free MONADIC (Lemma 5.1, PDF p.7). A joint-content provider literal was already probed and machine-refuted at F4 (single-point t-anchored `P.existF 3 σ`, unpinnable private existential — 309 reports/06). Blast radius: `ExistProviders`/`BracketCarrierCorrectVPrior` are the PROTECTED prior interface (PriorInterface.lean:3-6) consumed by KampPrior's recursion. |
| (b-weaken-fragment) single-positive-sub gate | **VIABLE — SANCTIONED** | Task 321 verdict N2 (authoritative scope amendment): GO/NO-GO for 309 Phase 13.4 + KampPrior:351 is fragment-scoped; multi-positive deferred to successor. O4 CRUX RECORD consequence (SW:6785-6791): "with ONE interior positive there are no cross-σ slots … the residue vanishes; this is exactly the configuration the landed `kvE_subBracket2V_sound_of_outer` (SubBracket2V.lean:1216) + `kvE_sub2V_bounded_anchor_of_outer` (:1182) already serve." Five of six hgate conjuncts already derivable from the landed O4 core (SW:6700-6706). |
| conditional gate (assume a family) | **REFUTED** | Fails 309's unconditional `BracketCarrierCorrectVPrior` requirement (309 reports/07: "a finding to escalate, not absorb"); F4 recurs one level up. |

## Why (a) is a dead end no matter who owns the file

The four families quantify over arbitrary `qnf : NormalForm sig 2 3`. The forward clause
`(∃ v, zoneHolds … zs v ∧ nf_eval χ) → σ.2 (nf0_assemble zs χ σ.1) = true` demands that σ's
quant layer mark every realizable `(zs, χ)`; a rich model realizes pairs an arbitrary `σ.2`
leaves false (OuterGate.lean:235-236). The carrier cannot pin this: its only per-σ channels are
the arity-1 `charK ∘ nfk_projFresh` literals, the segment contrapositive (fires only on
segment-covered points, never at witness points), and σ's own slot enumeration (O4 record,
SW:6742-6752). `bracketEndChar_kv_factors` machine-checks the same ceiling for the kv family.
"Internalizing" the derivation into `kvE2_outer_fold` would just move the unprovable goal across
a file boundary. Task 333 threading the families as hypotheses was not a punt of routine work —
it was the honest record that the faithful carrier does not pin them.

## The recommended path: fragment-restricted gate (concrete shape)

**Statement surgery (OuterGate.lean, 335 territory — no SharedWitness edits):**

1. Fragment predicate (plan v5 Phase 1 fixes the exact form; minimum sanctioned by O4):
   ```
   def kvE2_sepFragment (qnf : NormalForm sig 2 3) : Prop :=
     ∃! σ, σ ∈ kvE2_sepPos qnf   -- exactly one positive sub, interior
     -- + zone side-condition (nf0_zoneSpec σ.1 interior) per O4's "ONE interior positive"
   ```
   Design freedom: choose the weakest restriction making all four families derivable; O4
   guarantees residue-vanish for "one interior positive, no other positives".

2. Fragment gate theorems (new, alongside the landed completeness half):
   ```
   theorem bracketEndChar_kvE2_sound_two_prior_frag …
     (hfrag : kvE2_sepFragment qnf) : (…).holds M atomMap x t → ∃ w, nf_eval_nf M 2 3 [w,x,t] qnf
   theorem bracketEndChar_kvE2_correct_two_prior_frag … (hfrag : …) : (…).holds ↔ ∃ w, …
   ```
   Provider-shape unconditional (six order bits + UZ/SZ + x t only — 309's requirement);
   the fragment hypothesis is a qnf-domain restriction, the narrowing 321-N2 sanctions.

3. Family discharge under `hfrag` (all inside 335's Phase-4c `refine`):
   - `hgateL`/`hgateR`: the sole positive σ0 has no cross-σ slot points; consume
     `kvE_subBracket2V_sound_of_outer` (SubBracket2V.lean:1216) +
     `kvE_sub2V_bounded_anchor_of_outer` (:1182) + the O4 derivable core
     (`kvE2_sep_zone4_consistent`, `kvE2_sepHgate_offFiber`, `kvE2_sepHgate_innerNine`,
     `kvE2_sepSegForm_excludes`, biconditional endpoint/witness literals SW:6700-6706).
   - `hbdry`: in the one-interior-positive fragment the non-interior positive class is empty
     (or trivially bounded) — verify at plan time; if the chosen fragment admits non-interior
     positives, this family needs its own probe.
   - `hexcl`: negative-sub exclusion in the fragment — **the genuine open risk** (see below).

**GO/NO-GO discipline:** `hexcl`-under-`hfrag` gets ONE dedicated probe dispatch (the O4/F4
evidence pattern: captured goal + failed-closer list if NO-GO). The O4 record adjudicates the
*interior gate* residue only; exclusion content rides `kvE2_sepSegForm_excludes` + the landed
Prop 4.2 negation closure (`neg_2var_vec_ea`, EANegationClosure:722) and is *plausible but not
pre-certified* in the fragment. If the probe fails, the fragment route is NO-GO and the only
remaining path is the successor carrier re-definition — escalate to user, do not thrash.

## Impact assessment

- **309**: consumes the fragment gate; its v8 revision (already required — plan v7 targets the
  retired `kvE'`) re-points Phase 13.4/14 to `bracketEndChar_kvE2_correct_two_prior_frag` and
  fragment-scopes the KampPrior:351 discharge exactly as 321-N2 already declared. The
  "unconditional" requirement (309 reports/07) is met in the provider sense; the qnf-domain
  fragment restriction is the sanctioned scope. Multi-positive → successor task.
- **341**: UNAFFECTED and improved — the fragment route touches OuterGate.lean only, so
  SharedWitness.lean stays frozen from HEAD (ff54d45c5 lineage); 341's Phase-3 gate condition
  ("335 COMPLETED + SharedWitness frozen") becomes easier to certify.
- **Successor (multi-positive)**: bit-compatibility filtering of the interleaving enumeration —
  carrier re-definition with O1b/O2/O3 rework (O4 record SW:6763-6770). Create as a NEW task
  when 335 lands; do NOT fold into 335 or 341.

## What plan v5 for 335 should contain

1. **Phase 1** — fragment predicate design + statement surgery (`_frag` theorem shells,
   `sorry`-free by stating only; ~100-200 lines). Decision recorded: exact fragment form.
2. **Phase 2** — `hgateL`/`hgateR` discharge under `hfrag` (SubBracket2V:1216/:1182 + O4 core;
   ~200-400 lines; the main derivation work).
3. **Phase 3** — `hbdry` + `hexcl` probe under `hfrag` (GO/NO-GO, one dispatch, F4 evidence
   style on failure).
4. **Phase 4** — assemble `bracketEndChar_kvE2_correct_two_prior_frag`, docstring with
   Rabinovich PDF-page citations, axiom check, handoff note for 309 v8.
- Constraints carried forward: axiom-clean {propext, Classical.choice, Quot.sound}; no sorries
  on live paths; H7 territory OuterGate.lean only; no conditional gate; no family assumed.
- Sizing: 2-4 implementation dispatches.

## Open Questions

1. Exact fragment predicate: "exactly one positive sub, interior-zoned" (strongest residue-vanish
   guarantee) vs "at most one interior positive + non-interior positives allowed" (needs hbdry
   probe). Plan v5 Phase 1 decides; default to the former.
2. `hexcl` in the fragment: plausible (segment exclusions + Prop 4.2 closure) but unprobed —
   hence the mandatory Phase 3 GO/NO-GO.
3. Whether 309's ∀k lift (KampPrior `Nat.rec`) composes with a fragment-scoped k=2 rung without
   further statement surgery — flag for 309's v8 reviser, not 335's concern.
