# Task 376 — Split-Seam Block-A Certification Audit

**Session**: sess_1784138518_4af6d5 · **Agent**: lean-research-hard-agent (H2/H4) · **Date**: 2026-07-15
**Mode**: lean4 `--hard --lit` · bounded certification probe (Phase-1-style refutation-or-clearance)
**Focus**: certify split-seam Block-A refutation-safety
**Machine artifact**: `specs/376_arity_general_zone_decomposed_char_engine/reports/02_split-seam-probe.lean`
— compiled sorry-free this session (`lake env lean`, exit 0). Two theorems, both axiom-clean
(`#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`).

---

## VERDICT: **REFUTED**

**An UNGUARDED Block A completeness `↔` is NOT refutation-safe.** The Phase-2 split-seam
recommendation — "guard only Block B (soundness), revert Block A (completeness `↔`) to the
original unguarded `hcharFib`" — is **unsound**. The same cross-anchor transport mechanism that
killed the soundness seam re-enters through the completeness seam the moment the guards are
removed. A compiled counterexample is the deliverable.

This is an honest REFUTED found in one bounded dispatch: it prevents Phase 2 from being
re-implemented on a design that cannot be discharged. Both known designs are now eliminated —
guard-BOTH (Phase 2 blocker) and split-seam (this audit).

---

## The compiled refutation

### Theorem 1 — `unguardedBlockA_crossRender_refutation` (probe line ~40, sorry-free)

The original unguarded `hcharFib` (binder **byte-faithful** to `ExteriorGateAssembleK.lean:574-578`)
is **False** at any model with two DISTINCT points `w0 ≠ w'` that both render the SAME `qnf`, for
EVERY `charFib` family and every `atomMap`:

```
hcharFib : ∀ (w : M.carrier),
  nf_eval_nf M (k+2) 3 [w,x,t] qnf →          -- the ONLY guard: a render premise on w
  ∀ (σ : NormalForm sig (k+1) 4) (u : M.carrier),
    temporal_truth M atomMap u (charFib (k+1) σ) ↔
      nf_eval_nf M (k+1) 4 [u,w,x,t] σ
```

**Mechanism** (identical to the Phase-1 soundness refutation, re-entering via completeness): the
LHS `temporal_truth u (charFib σ)` is a Formula truth at a single point `u` — it is **independent
of `w`**. Firing the `↔` at two distinct renders `w0`, `w'` therefore forces
`nf_eval[u,w0,x,t] σ ↔ nf_eval[u,w',x,t] σ` for every `σ, u`. Instantiate with the *diagonal*
fiber `σ* := nf_characteristic[w', w0, x, t]` and shared point `u := w'`:

- Block A at `(w := w0, σ*, u := w')`, `.mpr`: RHS `nf_eval[w',w0,x,t] σ*` is `σ*` at its own
  tuple = TRUE ⟹ `temporal_truth w' (charFib σ*)` = TRUE.
- Block A at `(w := w', σ*, u := w')`, `.mp`: LHS TRUE ⟹ `nf_eval[w',w',x,t] σ*` = TRUE. But
  `σ*`'s order atom `(w' ? w0)` (one of `0<1` / `1<0`, recorded true since `w'≠w0`) evaluates over
  `[w',w',x,t]` to `w' < w'` = FALSE ⟹ atom-layer mismatch ⟹ `nf_eval[w',w',x,t] σ*` = FALSE.
- Contradiction: `temporal_truth w' (charFib σ*)` cannot be both TRUE and FALSE.

**Asymmetry vs. the soundness refutation** (why nobody caught this earlier): `hcharFibSoundP`'s `w`
was render-FREE, so the Phase-1 probe used `w' = 3` freely. `hcharFib`'s `w` carries a render
premise, so BOTH `w0` and `w'` must render `qnf`. Theorem 1 takes both renders as hypotheses.

### Theorem 2 — `unguardedBlockA_refuted_of_char_eq` (probe line ~90, sorry-free)

Reduces the refutation to its **sole remaining assumption**: two distinct points sharing a
characteristic type at the same anchors.

```
hchar_eq : nf_characteristic M (k+2) 3 [w0,x,t] = nf_characteristic M (k+2) 3 [w',x,t]
  ⟹ (unguarded Block A at qnf := char[w0,x,t]) ⟹ False
```

Everything except `hchar_eq` is compiled: the render at `w0` is `nf_characteristic_satisfies`; the
render at `w'` is the same, transported along `hchar_eq`; Theorem 1 closes it.

### Non-vacuity of `hchar_eq` (why Theorem 1 is not vacuous)

`hchar_eq` — "two interior points with equal depth-`(k+2)` characteristic at fixed `[x,t]`" — is
exactly **Gap A / order-homogeneity** (research report `01_...seam-interface.md` §Q2.2). Established
facts pinning it down:

- `nf_eval_nf M k n env nf ⟹ nf = nf_characteristic M k n env` (uniqueness, `nf_eval_unique`, used
  by `nf_fraisse_compression`, `EFGames/StaviCompleteness.lean:2020-2035`). Hence "two renders"
  ⟺ "equal characteristics" — there is no way around homogeneity, and no way around the fact that
  wherever homogeneity holds, Block A is false.
- `hchar_eq` holds in any order-homogeneous `OrderedMonadicStructure`. `(ℚ,<)` is one: an
  order-automorphism fixing `(-∞,t]` pointwise and mapping `w0 ↦ w'` (both `> t`) exists by
  density-homogeneity, and `nf_characteristic` is automorphism-invariant (it is built purely from
  `atom_eval` = order + `interp`, both preserved by an interp-respecting order-iso).
- The `hcharFib` binder in `bracketEndChar_kvExtFib_correct_prior` (EGA:571) and in
  `bracketEndChar_kvFib_step_complete` (IGGK:1747-1756) quantifies `(M : OrderedMonadicStructure
  sig)` with **no rigidity restriction**. Homogeneous structures lie inside that `∀ M`. A
  hypothesis that is false for some `M` in its own quantifier range cannot be uniformly discharged.
  The refutation therefore bites the discharge, not merely a pathological instance.

**Compiled-scope honesty (H4).** The `(ℚ,<)` automorphism-invariance witness is NOT compiled in
this probe (it is a routine EF/automorphism argument, out of scope for a bounded dispatch). It is
the single non-compiled leg. It does not soften the verdict: the seam's `∀ M` range provably
contains a model where `hchar_eq` holds, so the seam is not uniformly dischargeable.

---

## The pincer — why NO guard on Block A works (root-cause, source-verified)

The blocker is not "pick the right guard." It is a genuine pincer between the consumer and the
model class.

**Jaw 1 — the exclusion sites need Block A FULLY unguarded.** `step_complete`'s completeness body
(`InteriorGateGeneralK.lean`) discharges the frozen carrier's 7 segment/endpoint EXCLUSION
obligations (`:1932, 1946, 1968, 1984, 2009, 2022, 2046`) with the identical shape:

```
| false =>                                   -- igFoldBitFib qnf igZ<zone> σ = false  (σ UNMARKED here)
  intro hch                                  -- hch : temporal_truth u (charFib σ)
  have hbit := (hz' igZ<zone> σ).mpr ⟨pt, hz<zone>-witness, (hchar σ pt).mp hch⟩
  rw [hb] at hbit; exact Bool.noConfusion hbit
```

Two source-read facts make this fatal to any guard:
1. `.mp` is applied to `σ` that is **unmarked** (`qnf.2 σ` unknown — this is the `= false` fold
   branch) and **unrealized** (the whole point is to prove it is NOT realized). So the
   **marked-fiber guard `qnf.2 σ = true` is unavailable** (Phase-2 finding, reconfirmed).
2. The zone witness supplied is `hzXW u hxu huw : zoneHolds M [w,x,t] igZXW u` — the **FIXED zone
   constant** `igZXW` (the point `u`'s own zone), read off `IGGK:1755-1762` / the `hz'` RHS
   (`IGGK:1809`). It is **not** `zoneHolds M [w,x,t] (nf0_zoneSpec σ.atom_assgn) u`. So a
   **zoneHolds-on-σ's-own-zone guard is ALSO unavailable** (deriving σ's zone would require knowing
   σ is realized at `u`, which is exactly what the exclusion denies).

⟹ Only the FULLY unguarded Block A discharges these sites. (Neither the marked-fiber guard nor a
σ-zone guard can be supplied.)

**Jaw 2 — the fully unguarded Block A is refuted** (Theorem 1/2, above) in the homogeneous models
inside the seam's `∀ M` range.

The two jaws close: the design cannot simultaneously satisfy the exclusion sites (Jaw 1 forces
unguarded) and keep Block A true (Jaw 2 forbids unguarded).

**Deeper diagnosis for re-research.** `step_complete`'s body is internally **single-`w`** — it uses
`hchar := hcharFib w hw` at ONE render witness (`IGGK:1799`). The `.mp` transport at the exclusion
sites is fine *at that single `w`*. The refutation needs TWO `w`. So the contradiction lives
entirely in the seam's `∀ w` **signature promise**, which the discharge cannot honor (homogeneity),
NOT in `step_complete`'s internal logic. That relocates the fix (see below).

---

## Consequence for the plan — the design is back to research

Per the audit contract, downstream phase-3-9 sizing is produced **only on CLEARED**. Verdict is
REFUTED, so that sizing is withheld; instead, here is what the re-planner/re-researcher needs.

**Both eliminated designs:**
| Design | Where it dies |
|--------|---------------|
| Guard BOTH A and B (original Phase-2 plan) | Block A guard breaks the 7 exclusion sites (Phase-2 blocker) |
| Split-seam: guard B, unguard A (this audit) | Unguarded Block A refuted by cross-render (Theorem 1/2) |

**Landed assets that SURVIVE (do not rebuild).** The refutation is confined to Block A
(completeness). The Phase-2 green milestone (commit `3b75fc880`) is untouched by it:
- Guarded soundness **Block B** was CLEARED by Phase 1 (`ZoneSeamCrossContextProbe.lean`,
  `crossContext_wGate_blocks_attack`) — unaffected.
- `bracketEndChar_kvFib_realize_{futT,pastX}` (zone-guarded, IGGK) and `kampPrior_hreal_supply`
  (InteriorHrealSupplyK, via public `ext3_zoneHolds_cons_iff`) are consistent with the guarded
  soundness seam and remain valid regardless of how Block A is redesigned. KampPrior census stays
  at exactly 2 sorries (`:519`, `:522`).

**Candidate re-research directions** (unverified — for the next research/plan dispatch, NOT part of
the verdict):
1. **Existential-`w` / single-`w` seam.** Weaken the completeness seam so the `↔` is asserted only
   at the *bound* render witness `w` (the `∃ w` of `correct_prior`'s RHS), not `∀ w`. `step_complete`
   already only uses one `w`, so this may re-thread with no body change; the discharge then only has
   to satisfy the iff at that single witness (dischargeable — no cross-`w` promise). This is the
   least-invasive candidate and should be probed first.
2. **Anchor-indexed `charFib`.** Give `charFib` the anchor context (`charFib w σ`, or an
   anchor-data parameter) so each `w` gets its own formula and cross-`w` transport is
   ill-typed by construction. More invasive (touches the `charFib` interface threaded through the
   `*Fib` chain and the engine).
3. **Rework the exclusion argument** so the `| false =>` branches do not route through the
   unguarded `truth → nf_eval` (`.mp`) transport — but the obligation originates in the FROZEN
   `igSeg*/igEp*/igPtW*` carrier predicates, so this likely needs a frozen-surface change and is
   the least attractive.

**Recommended next action:** a bounded Phase-1-style probe of candidate (1) — does an
existential-`w` (single-witness) completeness seam both (a) re-thread `step_complete`'s exclusion
sites and (b) escape the cross-render refutation? — before any re-plan of Phase 2.

---

## Reference grounding (Tier 1)

| Source | Location | Lean identifier | Type / fact | Status |
|--------|----------|-----------------|-------------|--------|
| Original completeness seam | `ExteriorGateAssembleK.lean:574-578` | `hcharFib` binder | `∀ w, render → ∀ σ u, truth ↔ nf_eval` (render-guarded only) | source-read, byte-mirrored into probe |
| Completeness consumer | `InteriorGateGeneralK.lean:1747-1756` | `bracketEndChar_kvFib_step_complete` (`hcharFib` binder) | same shape at depth `k+1` | source-read |
| Exclusion sites | `IGGK:1932,1946,1968,1984,2009,2022,2046` | `hsegL/hsegR/hepL/hepR/hptW` `\| false =>` | `(hchar σ pt).mp hch` on unmarked σ, fixed-zone witness | source-read |
| Render uniqueness | `EFGames/StaviCompleteness.lean:2020-2035` | `nf_fraisse_compression` / `nf_eval_unique` | two renders ⟺ equal characteristics | source-read |
| nf semantics | `NormalForm.lean:198-227` | `nf_eval_nf`, `nf_characteristic`, `nf_characteristic_satisfies` | recursive atom+existential match | source-read + used in probe |
| Gap A (homogeneity) | research report `01` §Q2.2 | — | shift/order-homogeneous models break fixed-formula truth-set pinning | corroborated |
| Phase-1 CLEARED (soundness) | `ZoneSeamCrossContextProbe.lean` | `crossContext_wGate_blocks_attack` | guarded soundness Block B is safe | prior compiled artifact |

---

## Adversarial Self-Verification

Attacking the REFUTED verdict hardest (per H4 — the risk here is a FALSE refutation, since a
plausible seam was already refuted once and a plausible split-seam is now under audit).

| Claim | Source/Counterexample |
|-------|------------------------|
| Unguarded Block A ⟹ False given two distinct renders | `unguardedBlockA_crossRender_refutation`, probe compiled `lake env lean` exit 0, `#print axioms` = `[propext, Classical.choice, Quot.sound]` (no `sorryAx`) |
| The `hcharFib` binder in the probe is byte-faithful to the production seam | direct source read `ExteriorGateAssembleK.lean:574-578` and `InteriorGateGeneralK.lean:1747-1756`; both quantify `∀ w` with only the render premise |
| Theorem 1 is NOT vacuous (two renders are realizable) | `unguardedBlockA_refuted_of_char_eq` isolates the sole assumption `hchar_eq`; `hchar_eq` holds in `(ℚ,<)` (homogeneity) which lies in the seam's `∀ M : OrderedMonadicStructure sig` range (binder read at EGA:571, IGGK step_complete) |
| "Two renders" is unavoidable, not an artifact | `nf_eval_unique` / `nf_fraisse_compression` (`StaviCompleteness.lean:2020-2035`): `nf_eval env nf ⟹ nf = char[env]`, so two renders ⟺ equal characteristics |
| σ*'s order bit genuinely fails over `[w',w',x,t]` | compiled: `nf_eval_nf_atom_layer` gives atom `(w'?w0)` true from `hne` via `lt_or_gt_of_ne`; over the diagonal env it demands `w' < w'`, closed by `lt_irrefl` (probe, both rcases arms) |
| No guard on Block A can be supplied at exclusion sites (Jaw 1) | source read `IGGK:1809-1946`: `.mp` applied to unmarked σ (`= false` fold branch), witness `hzXW u : zoneHolds … igZXW u` is the FIXED zone constant, not `nf0_zoneSpec σ.atom_assgn` |
| Guard-BOTH is independently dead (so REFUTED here does not leave guard-both as an escape) | Phase-2 handoff `.orchestrator-handoff.json` blocker + `IGGK` exclusion sites: marked-fiber guard removes the `.mp` direction the exclusions need |
| Landed Block B / realize / hreal assets survive the refutation | refutation is confined to Block A (completeness); Phase-1 `crossContext_wGate_blocks_attack` CLEARED guarded soundness; commit `3b75fc880` green, census 2 |

**Contradiction Log.**
1. **Phase-2 recommendation ("split-seam is refutation-safe because Phase-1 blocked the counterexample
   with the soundness guard alone") vs. this audit (REFUTED).** RESOLVED against the Phase-2
   recommendation (precedence: compiled probe > prior recommendation). Phase-1 only refuted the
   SOUNDNESS transport; it never fired the COMPLETENESS seam at two `w`. The split-seam reasoning
   silently assumed Block A had no independent refutation — Theorem 1 exhibits one. The Phase-2
   handoff itself flagged this gap ("the report only refuted the soundness seam; RECOMMEND a bounded
   probe confirming no completeness-side refutation exists before adopting") — this dispatch IS that
   probe, and it returns REFUTED.

**Residual (non-compiled) leg, disclosed:** the `(ℚ,<)` automorphism-invariance of
`nf_characteristic` that witnesses `hchar_eq` concretely is argued, not compiled (routine EF-level
fact; a full compile needs an EF game or an explicit ℚ order-iso, out of scope for a bounded
dispatch). It is the ONLY non-compiled step and does not affect the verdict, because the seam's
`∀ M` range demonstrably contains a homogeneous model. If the re-planner wants this leg compiled
before acting, that is a ~1-phase EF/automorphism probe — but it is not required to conclude REFUTED.

---

## References

- `specs/376_.../reports/02_split-seam-probe.lean` — this session's compiled artifact (Theorems 1, 2)
- `specs/376_.../reports/01_zone-decomposed-seam-interface.md` §Q2.1-Q2.3 (Gap A/B, guarded pair)
- `.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean:574-581` (`hcharFib`/`hcharFibSoundP` binders)
- `.../NfMultiAnchorBridge/InteriorGateGeneralK.lean:1733-2050` (`step_complete`, exclusion sites)
- `.../NfMultiAnchorBridge/SeamPairRefutationProbe.lean` (Phase-1 joint soundness refutation)
- `.../NfMultiAnchorBridge/ZoneSeamCrossContextProbe.lean` (Phase-1 guarded-pair CLEARED)
- `.../WeakCanonical/NormalForm.lean:198-227` (`nf_eval_nf`, `nf_characteristic`)
- `.../WeakCanonical/EFGames/StaviCompleteness.lean:2020-2035` (`nf_fraisse_compression`, `nf_eval_unique`)
