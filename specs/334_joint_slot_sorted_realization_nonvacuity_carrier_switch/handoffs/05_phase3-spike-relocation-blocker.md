# Task 334 Handoff 05 — Phase 3 CRUX SPIKE outcome: point channel RELOCATES (does not dissolve)

- **Session**: lean-implementation-agent (orchestrator_mode), sess_1783529677_8c950d
- **Phase**: 3 (make-or-break verification spike) → **BLOCKED**
- **Files touched**: `Theories/.../NfMultiAnchorBridge/SharedWitness.lean` (one additive lemma;
  `SubBracket2.lean` UNCHANGED — the generic zone-forward channel already covers the closed zone).
- **Build**: `lake build …SharedWitness` exit 0. Sorry inventory UNCHANGED (2 scaffold + 2
  pre-existing strategic; 0 new; 0 vacuous defs; 0 new axioms).

## What landed GREEN (Phase 3 deliverables 1 & 2)

1. **No extractor extension needed.** `kvE_subBracket2_complete_extract`'s 3rd conjunct
   (`SubBracket2.lean:614-618`) is a GENERIC zone-forward channel `∀ (zs : ZoneSpec 4) (χ),
   (∃ v, zoneHolds env zs v ∧ nf_eval_nf M 0 1 (fun _ => v) χ) → σ.2 (nf0_assemble zs χ σ.1) = true`.
   It already quantifies over ALL zone specs, including the closed self-zone `kvE2_sep_zAtX1L`.

2. **`kvE2_sepCoincidentAnchor_discharge`** (SharedWitness ~:1161), sorry-free, **axiom-clean**
   (`#print axioms` = `[propext, Classical.choice, Quot.sound]`):
   > `x < x1 < w < t`, σ realized at `[x1,w,x,t]`, χ realized at x1
   > ⇒ `kvE2_sepBits σ kvE2_sep_zAtX1L χ = true`.
   Route: generic channel at `zs = kvE2_sep_zAtX1L`, witness `v = x1`; `zoneHolds env zAtX1L x1` is a
   pure order fact (`kvE_sub2_zoneHolds_cons_iff`). This is the faithful Rabinovich §5 shared-anchor
   meet-type identification (md:168-173): the point genuinely realizes both σ's fresh type and the
   foreign χ (existential `charK`). **Retained** — correct and reusable.

## What FAILED — the dissolution (Phase 3 deliverable 3, the make-or-break)

The discharge produces σ's **CLOSED** self-zone bit `kvE2_sepBits σ kvE2_sep_zAtX1L χ`. The
arrangement validity `kvE2_sepValid` (PRESERVED asset) routes every cross-owner fresh-adjacency
through σ's **OPEN**-zone bits:

- `kvE2_sepCompat_lX1_eq`: `kvE2_sepCompat a (.lX1 σ) = kvE2_sepBits σ kvE_sub2_zXU χ` (BEFORE).
- `kvE2_sepCompat_lX1_after_eq`: `kvE2_sepCompat (.lX1 σ) b = kvE2_sepBits σ kvE_sub2_zUW χ` (AFTER).

`zAtX1L = (false,false)·…`, `zXU = (true,false)·…`, `zUW = (false,true)·…` differ in coordinate 0,
so `nf0_assemble` yields distinct keys and `σ.2` at them are **independent** bits. **Confirmed at
the Lean type-checker** (`lean_multi_attempt`): `exact h` from
`σ.2 (nf0_assemble zAtX1L χ σ.1) = true` to goal `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true`
gives *"Type mismatch"*; `unfold kvE2_sepBits` does not bridge. No lemma connects them, and none can
(σ.2 is unconstrained across distinct keys except via realization, which here forces only zAtX1L).

### Refuting counterexample — `kvE2_sepBody_nonvacuous` is FALSE for the full carrier

Two positive left-interior owners σ, τ:
- σ realized at `[x1_σ,w,x,t]`, x1_σ realizes χ, but NO χ-witness in `(x,x1_σ)` nor `(x1_σ,w)`.
  The extractor's REVERSE channels (`SubBracket2:619-622`) then FORCE `σ.2(zXU χ)=false`,
  `σ.2(zUW χ)=false`; the forward channel forces `σ.2(zAtX1L χ)=true`.
- τ realized at `[x1_τ,w,x,t]`, `x1_σ < x1_τ`, τ realizes χ at exactly `x1_σ` (in τ's `(x,x1_τ)`
  region ⇒ `.lXU τ χ ∈ kvE2_sepSlotsL`).

For this realizable qnf any permutation must order `.lXU τ χ` vs `.lX1 σ`: BEFORE needs
`σ.2(zXU χ)=true` (false); AFTER needs `σ.2(zUW χ)=true` (false). ⇒ `kvE2_sepArrL qnf = []` ⇒
`(kvE2_sepBody …).disjuncts = []` ⇒ non-vacuity is FALSE. The point channel supplies only the
`zAtX1L` disjunct; the preserved open-zone compat cannot consume it.

Plan 02's model-order arrangement DOES discharge every STRICT case (strictly-below foreign witness →
zXU via σ's forward channel; strictly-above → zUW) — real progress over the identity arrangement —
but does NOT extend to the EXACT coincidence, which is model-possible (no density) and fatal.

## Root cause (already on record in this codebase)

Precisely the residual the LANDED task-333 analysis documented at `SharedWitness.lean:1879-1928`:
"the honest-derivable DISJUNCTIVE clause (σ's zXU- OR zAtX1- OR zUW-bit true) cannot select the
disjunct matching the REALIZED arrangement's placement of τ's slot"; "the faithful repair is
BIT-COMPATIBILITY FILTERING ... re-defines `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR` ... outside
this phase's additive scope." Task 333 declined that scope and routed to the N2 single-positive-sub
restriction (`kvE2_sepBody_singleton_*`). Plan 02's point-channel pivot re-encounters the same wall:
the audit (Handoff 04) correctly describes the PAPER's technique (identify the coincident point into
one anchor carrying the meet type), but the CURRENT Lean carrier — a FIXED flatMap slot list
(`kvE2_sepSlotsL = pos.flatMap kvE2_sepSlotsLFor`) validated by an OPEN-zone compat filter — cannot
represent that identification (the foreign slot `.lXU τ χ` is permanently present and cross-compared
through open zones). The audit itself flagged `kvE2_sepSlotsL`'s flatMap as DIVERGENT (its §3 table,
row 3); plan 02 kept it as a preserved asset, and that is where the pivot breaks.

## Unblock options (plan-level decision — NOT more proof in this scope)

- **(A) Faithful carrier redefinition.** Redefine `kvE2_sepValid`/`kvE2_sepCompat` to a DISJUNCTIVE
  (zXU ∨ zAtX1L ∨ zUW) bit-compatibility filter keyed to arrangement placement, then re-establish
  non-vacuity + O2/O3 plumbing under the new filter. Large; breaks the preserved compat leaves; this
  is the "faithful repair" task-333 named. `kvE2_sepCoincidentAnchor_discharge` is a live input to it.
- **(B) N2 restriction (already landed).** Accept the completeness line runs through the
  single-positive-sub fragment (`kvE2_sepBody_singleton_*`), where cross-σ slots — and this crux —
  vanish, and formally close multi-owner non-vacuity as out-of-scope.
- **(C) Density.** A model-density assumption ruling out exact coincidences — likely unfaithful /
  unavailable for arbitrary `OrderedMonadicStructure`.

**Recommendation**: `/revise 334` to choose (A) vs (B) explicitly; do NOT re-dispatch `/implement`
against plan 02 unchanged (Phases 4-8 are built on the refuted premise).
