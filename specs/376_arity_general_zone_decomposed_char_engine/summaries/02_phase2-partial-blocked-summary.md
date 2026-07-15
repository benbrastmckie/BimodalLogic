# Task 376 Phase 2 — Re-sign the *Fib sibling chain: PARTIAL / BLOCKED

**Session**: sess_1784138518_4af6d5 · **Agent**: lean-implementation-hard-agent · **Date**: 2026-07-15
**Outcome**: partial (1 green milestone landed) + a genuine design blocker requiring a plan revision.

## Landed (green, sorry-free, committed 3b75fc880)

Re-signed the **render-free endpoint→realizer extraction seams** to the zone-guarded Block B/C form:

- `bracketEndChar_kvFib_realize_futT` / `bracketEndChar_kvFib_realize_pastX`
  (`InteriorGateGeneralK.lean`): replaced the generic `(r, b)` parameters with `qnf`, added the
  bracket anchor order `hxw`/`hwt`, and re-signed the soundness seam binder to the guarded form
  (marked-fiber `qnf.2 τ = true` + `zoneHolds M [w,x,t] (nf0_zoneSpec τ.atom_assgn) x1`). Proof =
  the Phase-1 probe's compiled Block C, with the zone witness discharged structurally from the
  `untl`/`snce` firing.
- `kampPrior_hreal_supply` (`InteriorHrealSupplyK.lean`): re-signed its char-soundness-seam
  hypothesis to the same guarded Block B form and adapted the body — the two extraction calls and
  the three boundary zones (`AtX`/`AtW`/`AtT`), where the `zoneHolds` guards are built with the
  **public** `ext3_zoneHolds_cons_iff` (the arity-3 analog of the file-`private`
  `k1v_zoneHolds_cons_iff`).

Full `lake build` green; KampPrior sorry census **unchanged at exactly 2** (:519/:522); all
FROZEN surfaces byte-identical to HEAD.

## Blocked (escalated for plan revision)

Re-signing `bracketEndChar_kvFib_step_complete`'s `hcharFib` binder to **Block A** — the guarded
completeness `↔` carrying the `qnf.2 σ = true` marked-fiber premise — is **infeasible**. Its body
discharges the FROZEN carrier `bracketEndChar_kvFib`'s segment/endpoint **exclusion** obligations
at **7 sites** (`InteriorGateGeneralK.lean:1932, 1946, 1968, 1984, 2009, 2022, 2046`), each of the
form `(hchar σ u).mp hch` **inside a `cases hb : igFoldBitFib qnf <zone> σ | false =>` branch** —
i.e. applied to a σ that is *not* known marked. Block A's mark guard removes access to that
`temporal_truth u (charFib σ) → nf_eval u σ` direction, and the mark is genuinely unavailable in a
bit-false branch.

**Root cause**: those exclusions rely on exactly the *unguarded soundness transport* that the
report's §Q2.3 / `seamPair_joint_refutation` refuted. The guarded re-sign correctly breaks a proof
that was itself using the refuted claim. The carrier's `igSeg*` predicate demanding `¬charFib σ`
for every bit-false σ is frozen and out of Phase-2 scope, so the obligation cannot be dropped or
routed around by supplying guards.

`step_sound` (Block B, soundness) is by contrast **repairable** — all its seam uses are on marked
σ (from the `S_L`/`S_R` positive-bit filters and the `hreal` forwarding) — but it is coupled through
`step_correct`/`correct_prior`, which cannot fully build while `step_complete` is blocked.

## Recommended fix (for the planner / orchestrator)

**Split-seam design**: guard ONLY **Block B** (the soundness `→`, `hcharFibSoundP` — the actual
refutation lever) and keep **Block A** (the completeness `↔`, `hcharFib`) **unguarded**. Phase 1's
landed `zoneGuard_blocks_seamPair_counterexample` already proved the *soundness* `zoneHolds` guard
ALONE blocks the counterexample, so Block A never needed guarding for refutation-safety. This keeps
`step_complete`'s exclusion proof intact, lets `step_sound` re-sign cleanly, and is consistent with
the already-landed `realize_{futT,pastX}` + `hreal_supply` guarding. A bounded Phase-1-style probe
SHOULD confirm no completeness-side (Block A) refutation exists before adopting (the report only
refuted the soundness seam).

## Verification

- `lake build`: green.
- KampPrior sorry census: 2 (:519, :522) — invariant preserved; no new sorry anywhere.
- Frozen diff: empty (CarrierKv / CarrierK1V / Base / IGGK defeq bridge / KampPrior:941 gate).
