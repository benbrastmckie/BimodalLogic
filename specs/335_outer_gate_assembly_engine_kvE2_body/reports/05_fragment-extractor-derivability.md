# Report 05 — Fragment Extractor Derivability (second blocker-escalation research)

- **Task**: 335 (outer_gate_assembly_engine_kvE2_body)
- **Session**: sess_1783723095_edd5a7_335 (research fork 2)
- **Date**: 2026-07-10
- **Question**: Is a PUBLIC single-positive segment-coverage extractor (`.holds` of
  `kvE2_sepBody` → segment form at zone points, serving the landed fold's `hgateL`/`hgateR`)
  derivable inside SharedWitness.lean?
- **Method**: direct code verification of the landed interfaces (no edits; all citations are
  to current HEAD `cfc7fd5c2`), checked against the O4 CRUX RECORD's machine-checked
  accounting (SharedWitness.lean:6698-6791).

## Verdict table

| Candidate | Verdict | Evidence |
|-----------|---------|----------|
| (P) Proposed extractor serving the **current ∀-anchor fold interface** | **NO-GO — REFUTED** | O4 second obstruction is anchor-binder-level, not cross-σ-level; survives the fragment (§1) |
| (R) Revised **pin-anchored (∃-form) `_frag` fold variant**, additive in SharedWitness.lean | **GO — interface-verified** | O4 residue-vanish accounting closes conjunct-by-conjunct at the extracted pin witness under `hfrag` + provider correctness (§2) |
| (S) Successor carrier re-definition | Not needed for the N2 fragment deliverable | §3 |

## 1. The proposed extractor is REFUTED (not merely hard)

The proposal was: land `.holds → segment form holds at every zone point`, so that 335 can
discharge the landed fold's `hgateL` (SharedWitness.lean:9911-9928). That hypothesis binds

```
∀ a : M.carrier, x < a → a < t →
  (⟨charK (nfk_projFresh σ)⟩).eval_at M atomMap a →
  a < w ∧ … ∧ FORWARD ∧ backward        (SW:9914-9928)
```

i.e. **every** `charK`-anchor realizer in `(x,t)` must sit below `w` and realize σ's full
arity-4 base. The same ∀-anchor form is threaded verbatim through the whole landed chain —
`kvE2_sepBody_kit_sound` (SW:9795-9829, consumed at SW:9840-9848),
`kvE_subBracket2V_sound_of_outer` (SubBracket2V.lean:1497-1511) — and derived nowhere
("Amendment F3 … threaded verbatim", SW:9860, :1479).

**The ∀-anchor statement is FALSE in legal configurations even under the single-positive
fragment.** Machine-grounded countermodel recipe:

1. For a left-interior σ0 (`nf0_zoneSpec σ0.1 = kvE2_sep_zXW3`), the carrier's entire
   content on the open right region `(w,t)` is the depth-0 segment form
   `kvE2_sepSegRForSub … = kvE2_sepSegForm … kvE_sub2_zWT` (SW:1143-1144) — a conjunction of
   `(charBase χ).neg` for bit-false χ only (SW:184-188). The σ-level `charK` exclusions exist
   only at endpoints/exterior: `zAtW3` literals in `kvE2_sepPtW` (SW:1105-1106), `zAtT3`/`zFutT3`
   literals in `kvE2_sepEpR` (SW:1082-1093). **Nothing excludes the `charK` anchor atom on open
   `(w,t)`** — exactly the O4 "second, independent obstruction" (SW:6772-6778), whose cross-σ
   clause vanishes under the fragment but whose binder-level clause does not.
2. `kvE2_sepGate` (SW:1238-1246) forces only falsity off-fiber/inconsistent-zone; `zWT` is the
   7th consistent zone (SW:1227). So a qnf whose `σ.2` marks `(kvE_sub2_zWT, χ0)` for a χ0
   whose 1-type carries the anchor predicate bit is **gate-legal and hfrag-legal**.
3. A model realizing the honest arrangement plus one extra point `a' ∈ (w,t)` of 1-type χ0
   satisfies `.holds` (χ0 is bit-true, so the segment form does not exclude it) while `a'`
   realizes the anchor and `a' > w`. `hgateL` instantiated at `a'` demands `a' < w` — false.

No extractor, public or private, can derive a false statement; file ownership is irrelevant.
This also retro-explains implement-335-v5's wall: `refine_1 (a < w)` and `refine_2` (full base
at an arbitrary anchor) are the binder-level obstruction; `refine_4` (FORWARD at an arbitrary
anchor) additionally suffers zone-shift when `a` differs from the designated slot.

**Strengthening `hfrag` cannot dodge this**: the offending marks are order-theoretically
honest (an honest model may genuinely realize an anchor-bit-true 1-type above `w`), and the
anchor predicate `p* = atomMap (charK (nfk_projFresh σ))` is not qnf-syntactic, so a qnf-only
predicate cannot name it. Excluding all such marks would break honest completeness/non-vacuity
(FM-vac, prohibited — same reasoning as O4's rejected conjunctive clause, SW:6755-6759).

## 2. The GO path: pin-anchored `_frag` variants (additive, SharedWitness territory)

The ∃-side of the chain already extracts the **designated pin witness**:
`kvE_sub2V_bounded_anchor_of_outer` (SubBracket2V.lean:1447-1470) produces `q` with
`x < q < w` realizing the pin `⟨charK (nfk_projFresh σ)⟩` — the `.lX1 σ` slot's own
realizer, whose slot type is `kvE2_sepPtX1L` = charK anchor ∧ **biconditional** `zAtX1L`
literals (SW:294-303, 316-326). At THIS q (not an arbitrary anchor), the six `hgate`
conjuncts close under the fragment from `.holds` content:

| Conjunct | Channel at the pin (all landed, cited) |
|----------|----------------------------------------|
| `q < w`, `w < t` | delivered by the pin extraction itself (SubBracket2V:1465-1468) |
| full base at `[q,w,x,t]` | χ0* at q from **provider correctness at the pin** (see below); w/x/t coordinate types from `kvE2_sepPtW`/`EpL`/`EpR` head conjuncts via `nfPred_correct` (the fold already does this, SW:9963-9977); order bits from `x<q<w<t` |
| off-fiber | `kvE2_sepHgate_offFiber` (SW:6660-6662, public) |
| FORWARD, consistent zones | segments `(x,q)`/`(q,w)`/`(w,t)` keyed `zXU`/`zUW`/`zWT` — under single-positive, q IS the only slot, so segment zone keys align with `[q,w,x,t]`-zones; exclusion via `kvE2_sepSegForm_excludes` contrapositive (SW:6683-6696, public); self-zone `zAtX1L` via the biconditional-literal argument (a marked-false type at q contradicts q realizing its own type); `zAtW`/`zAtX`/`zAtT`/exterior via `kvE2_sepPtW`/`EpL`/`EpR` literal blocks (O4: "covering the six at/exterior inner zones in BOTH directions", SW:6702-6704) |
| FORWARD, inconsistent zones | vacuous via `kvE_sub2V_zone_consistent` contrapositive + `kvE2_sepHgate_innerNine` (SW:6669-6675) |
| backward | σ's own slot channel — `kvE2_sepS`-enumerated bit-true types realized at its `lXU`/`lUW`/`lWT` slots (O4, SW:6704-6705) + literals |

This is precisely the configuration the O4 record certifies: *"with ONE interior positive
there are no cross-σ slots — every left-list witness is σ's own bit-true 1-type or the
literal-covered self-zones — so the residue vanishes; this is exactly the configuration the
landed `kvE_subBracket2V_sound_of_outer` + `kvE_sub2V_bounded_anchor_of_outer` already
serve"* (SW:6785-6791) — now lifted from a routing verdict to a derivation plan whose every
channel is an existing landed public lemma.

**The one extra input: provider correctness at the pin.** The full-base conjunct needs
`charK`-anchor truth at q to yield σ's fresh atom type χ0* at q. That is exactly the
`ExistProviders.correct` step the fold's own documentation already assigns to 335:
*"whose typing into arity-4 depth-1 evaluations is exactly the `ExistProviders.correct` step
(c) … discharged downstream at the provider instantiation `charK := P.existF 0` (task 335),
never assumed here"* (SW:9862-9867). It enters the `_frag` lemmas as an explicit hypothesis
`hcorrK`, dischargeable by 335 at instantiation — NOT a smuggled family on the final gate
(same A1 pattern as `hexcl`). Without it, incoherent qnf (σ.2 marking a wrong type at the
self-zone) make `.holds` unsatisfiable only THROUGH `hcorrK`, so it is genuinely needed.

### Exact lemma shapes (statement sketches)

```lean
/-- Pin-anchored gate derivation, LEFT geometry (RIGHT is the zWX1-mirrored clone). -/
theorem kvE2_sepGateAtPin_fragL {sig} (atomMap …) (h_surj …) (charK …)
    (qnf) (hfrag : kvE2_sepFragment qnf)
    (hcorrK : ∀ (σ : NormalForm sig 1 4) (a : M.carrier),
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 1 1 (fun _ => a) (nfk_projFresh σ))
    (M x t) (h : (kvE2_sepBody … charK qnf).holds M atomMap x t)
    (σ) (hσ : σ ∈ kvE2_sepPos qnf) (hz : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    ∃ w q : M.carrier, x < q ∧ q < w ∧ w < t ∧
      (kvE2_sepPtW … qnf).eval_at M atomMap w ∧
      nf_eval_nf M 0 4 (Fin.cons q (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ zs χ, (∃ v, zoneHolds M [q,w,x,t] zs v ∧ nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ zs χ, zs ≠ kvE_sub2_zXU → σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v, zoneHolds M [q,w,x,t] zs v ∧ nf_eval_nf M 0 1 (fun _ => v) χ)

/-- Fragment kit: kit_sound's conclusion from hfrag + hcorrK (no ∀-anchor hgate). -/
theorem kvE2_sepBody_kit_sound_frag … (hfrag) (hcorrK) (h) :
    <verbatim conclusion of kvE2_sepBody_kit_sound (SW:9830-9839)>

/-- Fragment fold: kvE2_outer_fold with hgateL/hgateR/hbdry replaced by hfrag + hcorrK.
    hbdry is vacuous under hfrag (kvE2_sepPos qnf = [σ0], σ0 interior).
    hexcl remains threaded verbatim (A1 provider-conditional, unchanged). -/
theorem kvE2_outer_fold_frag … (hfrag) (hcorrK) (h) (hexcl : …) :
    ∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

A public segment-realization extractor IS part of this work (the original gap: segments are
discarded by `kvE2_sepBody_extract`, SW:8410) — but serving the pin-anchored interface, not
the refuted ∀-anchor one. It must live in SharedWitness.lean (the segment/arrangement
internals it unfolds are file-private; 82 `private` decls, e.g. the extraction plumbing), so
the work is **SharedWitness.lean, ADDITIVE-ONLY** (new decls; zero existing decls modified;
`kvE2_sepFragment` is imported from OuterGate — or restated locally to avoid an import cycle,
implementer's choice). 341's plan Phase 3 GATE re-diffs SharedWitness.lean before code moves,
so additive lemmas are absorbed by the existing gate machinery.

## 3. Sizing, risks, and what plan v6 (or the spawned task) should contain

- **Sizing**: 2-3 bounded dispatches. (i) `kvE2_sepGateAtPin_fragL` + segment/pin extraction
  plumbing (~300-500 lines; the heavy dispatch); (ii) the `_fragR` mirror + `kit_sound_frag` +
  `outer_fold_frag` (~200-350 lines); (iii) 335-side consumption: instantiate `hcorrK` from
  `ExistProviders.correct`, discharge `hexcl` probe, assemble `bracketEndChar_kvE2_correct_two_prior_frag`
  (OuterGate.lean, 335 territory — v5 Phases C/D reshaped).
- **Residual risks**: (1) `hexcl` is still threaded and still unprobed — v5's Phase-C GO/NO-GO
  probe survives unchanged as the make-or-break of the 335-side dispatch; (2) the
  single-positive arrangement-shape reduction (`kvE2_sepArr'` under hfrag reduces to the
  two-slot bracket) is mechanical plumbing but unlanded; (3) the exact output shape of the
  pin extraction (`bracketFromLists_flatMap_subchain_below_pin`) must be checked to deliver
  the segment context jointly with q — if not, the extraction lemma is where the additive
  work starts.
- **Spawn recommendation**: YES — a SharedWitness-territory task (additive-only) for the
  `_frag` chain, consumed by 335. Title: "Pin-anchored fragment fold: kvE2_outer_fold_frag +
  gate-at-pin derivation (SharedWitness additive)". 335 keeps OuterGate.lean; territory
  conflict with 341 is absorbed by 341's existing GATE-phase re-diff.

## 4. Adversarial check on the GO path (what could still kill it)

Attempted refutation of the pin-anchored form: the §1 countermodel adds a spurious anchor
realizer `a' ∈ (w,t)` — harmless now, since the `_frag` lemmas never instantiate at `a'`.
A spurious realizer strictly between two designated segment boundaries in the LEFT region
(`a'' ∈ (x,q)` with anchor bit true) is likewise harmless: FORWARD at `[q,w,x,t]` only asks
that `a''`'s (zone, 1-type) pair be marked, which the `zXU` segment form supplies. The
self-zone coherence hole (σ.2 marking a wrong type at `zAtX1L`) is closed by `hcorrK` making
`.holds` contradictory at the pin. No refutation found; the failure modes are exactly the
three residual risks above, all bounded-checkable in the first dispatch.
