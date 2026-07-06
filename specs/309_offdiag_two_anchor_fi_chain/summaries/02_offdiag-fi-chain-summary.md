# Task 309 Phase 6 Summary — Depth-0 navigated arity-3 endpoint base + interface

- **Task**: 309 — offdiag_two_anchor_fi_chain
- **Phase**: 6 of 9 (plan v2)
- **Status**: implemented (skeleton) — plan's §4.3 strategic-sorry fallback TRIGGERED
- **Session**: sess_1783359214_93fd70

## What was delivered

All in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`
(inserted after `nf_char3_endpoint_tl_correct`, before the Phase 4 section):

- `nf3_locus0 : NormalForm sig 0 3 → NormalForm sig 0 1` — position-0 (navigated witness `w`)
  predicate-locus projection, mirroring `nf2_locus` one arity up. Sorry-free.
- `endChar0 (atomMap) (h_surj) : NormalForm sig 0 3 → TemporalPred` — the depth-0 navigated
  arity-3 endpoint base: the `w`-locus atom characteristic via `nf_depth0_char_formula` on
  `nf3_locus0`. Genuine, non-vacuous formula (not a `True`/placeholder). Sorry-free def.
- `EndCharCarrier (sig) (k) : Type := NormalForm sig k 3 → TemporalPred` — the recursion-carrier
  interface fixed for Phase 8. `endChar0` inhabits `EndCharCarrier sig 0`.
- `endChar0_wlocus_correct` — **sorry-free** leaf: `(endChar0 … qnf).eval_at M atomMap w ↔
  (∀ p, M.interp p w ↔ qnf (.pred p 0) = true)`. Axioms `[propext, Classical.choice, Quot.sound]`.
- `endChar0_correct` — full navigated correctness `.eval_at w ↔ nf_eval_nf M 0 3 (zoneEnv3 w a b)
  qnf`, carrying ONE flagged strategic sorry (line 1066).

## Why the strategic sorry (report 02 §4.3, plan Phase-6 §4.3 FALLBACK)

At depth 0, `nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf` unfolds (NormalForm.lean:201) to the atom layer
over env `(w, a, b)`: predicate literals at the two fixed anchor positions `a` (index 1), `b`
(index 2), plus order relations among `{w, a, b}`. A closed `TemporalPred` (a syntactic `Formula`,
ExistsForallNF:49; `.eval_at = temporal_truth … w`, :53) reads predicates only locally at `w` or at
points reached by temporal navigation — it cannot reference arbitrary carrier anchors `a, b` as free
values. Pinning `a = x`, `b = t` is exactly what the Rabinovich `β_i` non-trivial interior segment
does (report 02 §4.2, G3), and that segment is the deliverable of **Phase 7** (not yet built). So the
standalone depth-0 navigated correctness cannot close in this phase's budget. This is the Medium-risk
base case report 02 §4.3 flagged; the plan's §4.3 fallback authorizes exactly this skeleton so
Phases 7-9 stay dispatchable. NOT an impossibility — the object exists (Rabinovich Cor 5.4).

## Guards

- G1 (no arity-1 collapse): `endChar0` reads the honest arity-3 atom layer's `w`-locus; correctness
  targets arity-3 `nf_eval_nf`.
- G4 (≤2 anchor cap): anchors stay `{a,b} ⊆ {x,t}`; `w` is the navigated bracket witness, never a
  third free anchor.
- Not routed through `nf_char3_deeper_split` (anchor-growing; forbidden per Corrected Anchor-Cap).

## Verification

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge` — GREEN (995 jobs).
- New-material code sorries: exactly ONE (endChar0_correct:1066), tracked strategic with
  follow_up_task. No vacuous defs. No new axioms.
- `endChar0_wlocus_correct` axioms = `[propext, Classical.choice, Quot.sound]`.
- Live-path sorries (`KampPrior.lean:351`/`:354`) UNCHANGED — Phase 6 is off the live path.

## Follow-up

Discharge `endChar0_correct` after Phase 7 lands `seg`/`seg_holds_correct` (fold into Phase 8
base-wiring or a dedicated depth-0 navigated base-case discharge). See sorry_inventory in
`.orchestrator-handoff.json`.

---

# Task 309 Phase 7 Summary — Non-trivial interior `β_i` segment + holds-correctness

- **Phase**: 7 of 9 (plan v2)
- **Status**: implemented — **sorry-free** (0 new sorries; Phase-6 strategic sorry carried forward)
- **Session**: sess_1783359214_93fd70
- **Commit**: `901484b9c task 309 phase 7: non-trivial interior segment builder`

## What was delivered

All in `NfMultiAnchorBridge.lean`, inserted after `endChar0_correct`:

- `seg {sig k} (endChar : EndCharCarrier sig k) (qnf : NormalForm sig k 3) : BracketFormula 0`
  := `BracketFormula.trivial (endChar qnf)` — the Rabinovich `β_i` non-trivial interior segment
  (md:154-157). Interval type is the genuine Phase-6/8 interface predicate `endChar qnf`, NOT
  `TemporalPred.top` (G3). Parametric on the `EndCharCarrier` interface Phase 8 recurses on.
- `seg_holds_correct` — **sorry-free**: `(seg endChar qnf).holds M atomMap x t ↔
  ∀ y, x < y → y < t → (endChar qnf).eval_at M atomMap y`, via `BracketFormula.trivial_holds`.
  Axioms exactly `[propext, Classical.choice, Quot.sound]`.
- `seg_holds_coupled` — **sorry-free**: under the per-point hook `h_endChar : ∀ y,
  (endChar qnf).eval_at y ↔ nf_eval_nf M k 3 (zoneEnv3 y x t) qnf`, yields
  `(seg …).holds x t ↔ ∀ y, x < y → y < t → nf_eval_nf M k 3 (zoneEnv3 y x t) qnf`. The
  `nf_eval_nf`-coupled interior form named in the deliverable; the `(x,t)` coupling is a hook
  (deferred to Phase 8 via `endChar_correct`, exactly as Phases 4/5 defer `h_quant`), NOT a sorry.
  Axioms exactly `[propext, Classical.choice, Quot.sound]`.

## Design note / deviation (altered)

A witness-free `BracketFormula 0` `.holds` is **definitionally a universal**
`∀ y ∈ (x,t), segType y` (`IntervalPattern.holds` at `n=0`, ExistsForallNF:110-112), NOT the
existential `∃ w, x<w<t ∧ nf_eval_nf …` literally named in the plan's `seg_holds_correct`
deliverable. That existential is **definitionally unrepresentable** by a `BracketFormula 0`; it is
supplied by the enclosing `bracketBuildLeft` witness in the Phase-8 assembly (the witness is laid by
the bracket, the `β_i` rides between bracket endpoints). So the deliverable is delivered as the
split `seg_holds_correct` (universal `β_i`) + `seg_holds_coupled` (`nf_eval_nf` coupling via a
deferred hook). This matches Rabinovich's `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`: `β_i` is the
universal-over-interval segment; the `Until` witness is the existential.

## Guards

- G3: `seg`'s interval type is the real `endChar qnf`, non-`⊤`; interior rides the non-trivial segment.
- G4: anchors `{x,t}=2`; `y` is a bracket witness; `endChar : NormalForm sig k 3 → TemporalPred`
  keeps arity ≤ 3. No third anchor introduced (verified in the def's type).
- G5: `holds` reduction via `BracketFormula.trivial_holds`; coupling bridge is manual
  `constructor`/`intro`; no `simp`/`omega`/`aesop` chain-step shortcut. Cites md:154-157.

## Verification

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge` — GREEN (995 jobs).
- 0 new code sorries; module sorry count 1 (the carried Phase-6 `endChar0_correct`:1066). No vacuous
  defs (grep: 0). No new axioms.
- Both new `_correct` lemmas verified axioms `[propext, Classical.choice, Quot.sound]` (`lean_verify`).

## Follow-up

Phase 8: assemble `endChar` by recursion on `k` (base `endChar0`, step brick-flatten + `seg`
interior + endpoints), prove `endChar_correct`, and discharge `seg_holds_coupled`'s `h_endChar` hook
+ the carried Phase-6 `endChar0_correct` strategic sorry via anchor pinning `a=x, b=t` through the
enclosing bracket witnesses.
