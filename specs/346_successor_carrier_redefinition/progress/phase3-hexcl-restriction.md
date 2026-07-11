# Phase 3 Record — hexcl boundary-restriction (R1) via hypothesis split

**Session**: sess_1783782450_230288
**Dispatch**: lean-implementation-hard-agent, Phase 3 ONLY
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
**Decl**: `kvE2_outer_fold_frag` (below the SW:10210 341 GATE banner)

## What changed

1. **Signature**: the former single exclusion hypothesis
   `hexcl : ∀ w, x<w → w<t → ptW → ∀ σ, qnf.2 σ = false → ∀ x1, ¬realizes` was **split** into:
   - `hexcl` (cone): `... → ∀ x1, x ≤ x1 → x1 ≤ t → ¬realizes` — the interior+boundary obligation,
     dischargeable by the landed endpoint/witness literals (Phase 4 consumer channel).
   - `hexclExt` (exterior, NEW): `... → ∀ x1, ¬ (x ≤ x1 ∧ x1 ≤ t) → ¬realizes` — the strictly-exterior
     residue, isolated and carried by the caller; deferred to the named Prop-4.3 successor.
2. **Forward branch** (`· rintro ⟨x1, hx1⟩; by_contra hne; ...`): re-threaded via
   `by_cases hcone : x ≤ x1 ∧ x1 ≤ t` → `hexcl` on the cone branch, `hexclExt` on the exterior branch.
3. Backward branch (Phase 4's) left byte-identical — still RED at `rw [hpos]`.

## Why split, not single-binder restriction (deviation cause)

`nf_eval_nf` (NormalForm.lean:206) defines the fresh-variable clause as
`(∃ x : M.carrier, nf_eval_nf ... (Fin.cons x env) sub_nf) ↔ quant_assignment sub_nf = true`.
The existential ranges over the WHOLE carrier. Hence the fold's forward direction
`(∃ x1, realizes σ) → qnf.2 σ = true` must exclude strictly-exterior witnesses as well. A single
cone-restricted `hexcl` cannot: an arbitrary realizing `x1` is not derivably in `[x,t]` (that IS the
deferred exterior-completeness problem, report 07 Refutation 2). The plan's "trivial cone-membership
fill" was therefore unachievable. The split keeps the fold a genuine, sorry-free conditional theorem
whose cone half is independently consumable, and names the exterior residue (`hexclExt`) for the
successor. `hexcl ∧ hexclExt` together = the old full `hexcl` — no logical strength was dropped.

## Build result (scoped: SharedWitness)

RED at exactly the 3 known Phase-4 sites, NO new errors:
- SW:12518 — `kvE2_sepBody_kit_sound_frag` fragL call (Phase 4)
- SW:12520 — `kvE2_sepBody_kit_sound_frag` fragR call (Phase 4)
- SW:12644 — `kvE2_outer_fold_frag` backward branch `rw [hpos]` (Phase 4; was SW:12627 pre-edit)

Forward branch: GREEN. Producers `kvE2_sepGateAtPin_fragL` (SW:10526) / `_fragR` (SW:11553): GREEN.
No decl above the GATE banner touched. No sorry introduced.

## Handoff to Phase 4 / Phase 5

- **Phase 4** (backward branch): unchanged scope — realize boundary positives via endpoint/witness
  literals under the now-available `hexcl` cone admissibility; the 3 RED sites are its surface.
- **Phase 5** (OuterGate): `kvE2_outer_fold_frag` arity increased by one (`hexclExt`). The caller
  `OuterGate.lean:270` and the re-stated `bracketEndChar_kvE2_sound_two_prior_frag` (:245) must now
  thread BOTH `hexcl` (cone) and `hexclExt` (exterior). The exterior hypothesis is where 309 / the
  Prop-4.3 successor carries the deferred obligation.
