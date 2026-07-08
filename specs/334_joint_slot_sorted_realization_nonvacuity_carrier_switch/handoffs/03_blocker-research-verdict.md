# Task 334 Handoff 03 — Blocker Research Verdict (GO/NO-GO)

- **Session**: sess_1783529677_8c950d (orchestrator blocker escalation 1/2, research fork)
- **Question**: Can the joint slot-sorted realization be salvaged within the current
  single-point mergeSort carrier, or does it need an architecture pivot?
- **Verdict**: **NO-GO within the current carrier.** Recommend the ROADMAP's pre-authorized
  Option B carrier pivot. This is a user-level decision.

## Grounding (verified in code, not names)

- `zoneHolds` (`NfEFold.lean:60`) is **strict**: `∀ i, (x < env i ↔ (zs i).1=true) ∧ (env i < x ↔ (zs i).2=true)`.
- `kvE_subBracket2_complete_extract` (`SubBracket2.lean:606`) — its three interior channels
  (`zXU`/`zUW`/`zWT`, lines 619-624) and its forward channel (614-618) **all** fire only through
  `zoneHolds`. With env `[x1,w,x,t]`: `zXU` coord 0 = `(true,false)` requires `v < x1`; `zUW` coord 0
  = `(false,true)` requires `x1 < v`. At a tie `v = x1_σ` **both fail** — the point is in no zone.
- `charK = P.existF 0` (`NavigatedSpine.lean:411`) is **existential**: a point may realize both σ's
  depth-1 fresh type and a foreign owner's depth-0 base χ. So the coincidence `pt a = x1_σ` is
  genuinely possible; there is no discriminator.

## Candidate verdicts

- **A. Tie-tolerant / non-strict channel — REFUTED.** The extractor is strict-only by construction
  (`zoneHolds` strict; all channels gate on it). A tie point satisfies neither before- nor
  after-fresh zone, so no compat path — strict or otherwise — discharges Case A/B at the tie.
  Coincident distinct-owner witnesses cannot "share a slot": they are different slot types
  (foreign base-χ vs σ's `.lX1`) and the foreign bit still needs σ-relative zone membership.
- **B. Secondary-key / stable tie-break — REFUTED.** The obligation is a property of `pt a`'s zone
  membership relative to `x1_σ`, **invariant under list order**. A secondary key reorders equal-`pt`
  elements but cannot move `pt a` off `x1_σ`. The research's rejection stands.
- **C. Global fold-bit disjointness — REFUTED.** Would require `pt a ≠ x1_σ` semantically, i.e. the
  coincidence is impossible. But `charK` is existential (above), distinct owners' witnesses are
  independent `Classical.choose`, and nothing in the qnf structure forbids a foreign owner's
  χ-witness from being σ's anchor. No such disjointness lemma exists in `WeakCanonical/`. This is
  exactly the retrospective's **root obstruction**: *a property relating two independently-chosen
  points cannot be asserted by a single-point formula* (322/reports/02, H4-verified).
- **D. Non-mergeSort joint arrangement — = ARCHITECTURE PIVOT.** Any arrangement that does not route
  strictness through the fresh-anchor boundary must abandon the single-point-per-slot order. But the
  current carrier (`kvE2_body`, NavigatedSpine:411ff) architecturally requires **one** bracket
  splicing all owners' slots (`slotsFor`), which is what forces the joint single-point order. Not
  routing strictness through the anchor ⟹ redesigning the carrier ⟹ Option B.

## Overall

**NO-GO.** The single-point joint sort is genuinely invalid: two owners' witnesses can coincide at a
fresh anchor and the coincidence is neither preventable (C) nor tolerable (A/B). This is the **fourth
attempt in the same gate/correctness class** the retrospective anticipated (Rec-1 "no fifth
carrier"): 321 Phase 8, 324 Phase 6, 325 v1, now 334's joint-sort carrier — all instances of the
two-independent-points-via-single-point-formula root obstruction.

**Recommended next action (pre-authorized fallback, ROADMAP:36):** **Option B — interval-typed
EA-formula rebuild with witness-count induction** (~700-1050 lines, scoped in
`specs/305_*/reports/37 §4.4`). This types witnesses by interval rather than single point, so
coincident-point ties are structurally impossible instead of needing an (unprovable) inequality.

**Preserved assets (survive the pivot):** Phase 1's arrangement-aware filter switch and the reduced,
axiom-clean `kvE2_sepFreshAnchor_ne_baseChiPoint` (`χ ≠ nf0_projFresh σ.1 → p ≠ x1_σ`) remain
correct and reusable by any resolution that can supply a base-type inequality (e.g. Option B's
interval typing supplies exactly this by construction). Task 333's four compat leaves and
`kvE2_sepHonestBundleL` are untouched.

**Escalation:** This is an architecture-level decision (carrier pivot vs. continued single-point
attempts against Rec-1). Surface to the user; do not autonomously churn a fifth single-point carrier.
