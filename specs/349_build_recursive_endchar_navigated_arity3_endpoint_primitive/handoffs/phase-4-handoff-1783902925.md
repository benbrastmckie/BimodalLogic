# Task 349 — Phase 3-4 Handoff (session sess_1783902925_24bf86)

**Status:** partial — Phases 3-4 GREEN + committed; Phases 5-7-8 open. Resume at Phase 5.

## What landed this dispatch (green, sorry-free, axiom-clean, committed)

NEW module `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracketAssembleK.lean`
(imports `ExteriorConverterK` + `ExteriorConverterPastK` + `ExteriorBracketK`):

- **Phase 3 (D1/D2, commit `ae593996e`)** — the depth-`k` exterior bracket builders + soundness:
  - `kvE_extBracketFut` / `kvE_extBracketPast` : `(P : ExistProviders sig atomMap k) → (qnf : NormalForm sig (k+2) 3) → Formula`.
    Conjunction over ADMISSIBLE subs `σ : NormalForm sig (k+1) 4` (filtered by `kvE_futAdmissible` /
    `kvE_pastAdmissible`) of `if qnf.2 σ then kvE_futPos P σ else kvE_extNegFut P σ`.
  - `kvE_extBracketFut_iff` / `kvE_extBracketPast_iff` (unfold to per-σ clause conjunction).
  - `kvE_extBracketFut_sound` / `kvE_extBracketPast_sound` (D1/D2) — mirror ExteriorBracket.lean:432/456,
    consuming `kvE_futRealizer_admissible` (352) + `kvE_extNegFut_sound` (352). CLEAN (no F2 residue).
- **Phase 4 (D3/D4, commit `45c9b37ce`)** — the completeness half:
  - `kvE_extBracketFut_complete` / `kvE_extBracketPast_complete` (D3/D4) — mirror ExteriorBracket.lean:547/583,
    carrying `hpos`/`hneg` (as k=2) PLUS `hreal`/`hsat` threaded VERBATIM from the 354 converter
    signatures (`kvE_extNegFut_complete` ExteriorConverterK.lean:126-134) and fed straight to it.
    The `hreal`/`hsat` are a DISCHARGED interface (discharged in Phase 6 via `kvE_futBundle_of_realizer`
    / `kvE_pastBundle_of_realizer`, 354), NOT debt. No discharge here.

`lean_verify` on all four D1-D4 lemmas (+ both `_sound`) = exactly `[propext, Classical.choice, Quot.sound]`.
Frozen files byte-identical; delivered 352/354 clause modules unedited; FORBIDDEN grep clean.

## Index conventions pinned (use these when resuming)
- `NormalForm sig (k+1) n = (AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)`.
- Bracket wrapper: `qnf : NormalForm sig (k+2) 3` ⇒ `qnf.2 : NormalForm sig (k+1) 4 → Bool` ⇒ subs
  `σ : NormalForm sig (k+1) 4`; each σ's own subs `s : NormalForm sig k 5`.
- Delivered clause layer keys on `P : ExistProviders sig atomMap k`, Prior guards `h_UZ`/`h_SZ`,
  `σ : NormalForm sig (k+1) 4`.

## The open frontier — Phase 5 (why it is NOT mere consumption)
The recursion carrier is `endInterval : (k) → BracketEndCharCarrierV sig k = NormalForm sig k 3 → VVecEA2`
(CarrierK1V.lean:2159); the step `endIntervalStep` (CarrierK1V.lean:2144) is the sanctioned `⟨[]⟩` hole
(LEFT untouched — not faked). Filling it requires the INTERIOR content at general `k`:
- The k=2 template `bracketEndChar_kvE2Ext` (ExteriorBracket.lean:661) = interior gate
  `bracketEndChar_kvE2` (OuterGate.lean:70) `.enrichEndpoints` the two brackets. Its correctness
  `bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069) consumes
  `bracketEndChar_kvE2_sound_two_prior_frag` / `_complete_two_prior` + pins
  (`kvE2_extGate_henv` :721, `kvE2_extGate_anyBit_iff`, `kvE2_sepBody_extract`) — ALL hardwired to
  depth-1 subs / `nf_depth0_char_formula`.
- The depth-`k` carrier `bracketEndChar_kv` (CarrierKv.lean:238) exists but `bracketEndChar_kv_correct`
  is delivered ONLY at k=0/k=1 (`_correct_zero` :367 / `_correct_one` :395). **General-`k` interior
  correctness is undelivered open construction** — the heart of the recursive Kamp characterization,
  ~700-1300 new lines across Phases 5-7. Now that Phases 3-4 supply the exterior bracket layer, the
  Phase-6 correctness `⇒` uses D1/D2 `_sound` for the exterior residue and the `⇐` uses D3/D4
  `_complete` with `hreal`/`hsat` discharged via the 354 bundle templates from the reconstructed
  realizer.

## Immediate next action
Dispatch Phase 5 (build the depth-`k` interior gate + `EndIntervalCorrectPrior` statement) — likely
needs its own sub-plan / `--hard` per-phase dispatch because it is open construction, not consumption.
Consider `/spawn 349` for the depth-`k` interior-gate correctness (`bracketEndChar_kv_correct` general)
if it proves to be a large standalone deliverable.
