# Task 344 — Continuation Handoff (dispatch 2 → dispatch 3)

- **Session**: sess_1783723095_edd5a7_344
- **Status at handoff**: Phase 1 [PARTIAL]. No new code landed this dispatch. Tree is
  byte-identical to HEAD `2c4d87fc9` for `SharedWitness.lean` (green; only pre-existing
  `specs/TODO.md`/`specs/state.json` are dirty, not 344's). Dispatch 2 was a deep interface
  investigation that produced a **material architectural correction** to the dispatch-1 Step A/B
  plan plus a **newly-identified crux** (the forward-conjunct witness-point case) that the report's
  channel table under-specified. Read this before writing any code.

## TL;DR — what changed vs dispatch 1's handoff

1. **The Step A / Step B split (separate "joint extractor" then "gate") is the WRONG factoring.**
   A standalone extractor that exposes "segment form holds on the open zone (x,x1)/(x1,w)/(w,t)"
   is **not a true statement** — see §2. `kvE2_sepGateAtPin_fragL` should instead unfold the body
   `.holds` **inline** (the same way `kvE2_sepDisjunct'_extract` does: `kvE2_sepBody_holds_iff` →
   `wo ∈ kvE2_sepArr'` → `IntervalPattern.holds_eq_succ`) and derive all six conjuncts from the
   raw witness+segment structure. There is no clean intermediate lemma to commit separately.
2. **The FORWARD conjunct needs a bracket trichotomy the report's channel table omits** (§2). The
   report says "consistent zones close via `kvE2_sepSegForm_excludes` contrapositive." That closes
   only **segment-interior** query points. **Witness points** (σ0's own below-witnesses, which are
   bit-TRUE) need a separate argument: 1-type functionality — **resolved via the landed
   `nf_eval_unique` (`NormalForm.lean:245`)**. So there is NO wall; the report's channel table is
   just incomplete on the witness case, now filled. This is the main proof-engineering subtlety.
3. **Key direction discovery**: `kvE2_sepSegForm_eval_of_honest` (`SW:8976`) is the **REVERSE**
   direction (σ already realized → segForm holds). It does NOT help the forward gate conjunct
   (which must go `.holds` → segForm). The `kvE_subBracket2V_reaches_z*` lemmas
   (`SubBracket2V.lean:1087/1106/1125`) serve the **BACKWARD** gate conjunct (bit true → witness),
   at the wrong bracket level (inner depth-1), but are the right *shape* template.

## Verified interface facts (all re-confirmed against HEAD `2c4d87fc9`)

### The closer and the six-conjunct target
- `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1290`) consumes the ∀-anchor `hgate` at
  the single pin `x1` (`:1323`, `obtain ⟨haw,hwt,h_atom,h_off,h_fwd,h_bwd⟩ := hgate x1 …`), then
  runs `rw [nf_eval_depth1_fold_iff]; refine ⟨h_atom, ?_, h_off⟩; intro zs χ;
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩; intro hbit; by_cases zs = kvE_sub2_zXU …` (`:1324-1345`).
  **ALL SIX conjuncts are used** (`h_fwd` at `:1328`, `h_bwd` at `:1345`, `haw` inside the zXU
  branch at `:1336`). The pin-anchored variant `kvE2_sepBundleL_sound_frag` inlines this exact
  continuation with the six conjuncts supplied at `x1` by `kvE2_sepGateAtPin_fragL`.
- `nf_eval_depth1_fold_iff` (`CarrierKv.lean:466`): `nf_eval_nf M 1 n env σ ↔ (h_atom) ∧
  ((∀ zs χ, (∃ v, zoneHolds env zs v ∧ nf_eval M 0 1 (fun _=>v) χ) ↔ σ.2 (nf0_assemble zs χ σ.1)=true)
  ∧ h_off)`. The middle **biconditional**: `.mp` = FORWARD gate conjunct, `.mpr` = BACKWARD.
- Landed assembly to mirror: `kvE2_sepBundleL_sound` (`SW:9673`) → `kvE_subBracket2V_sound_of_parts`;
  `kvE2_sepBundleR_sound` (`SW:9726`, inlines the continuation directly, no `_of_parts` call);
  `kvE2_sepBody_kit_sound` (`SW:9787`, conclusion `SW:9830-9839`); `kvE2_outer_fold` (`SW:9897`,
  `hexcl` is the FINAL hyp `SW:9952-9956`, threaded verbatim; `hbdry` `SW:9946-9951` vacuous
  under `hfrag`).

### The FORWARD-conjunct channels (per zone, at pin x1, env [x1,w,x,t], LEFT owner σ0)
- **off-fiber** (`h_off`): `kvE2_sepHgate_offFiber` (`SW:6658`) `= hg.2.2.1 σ hσ`. Needs
  `hg : kvE2_sepGate qnf` (get from `kvE2_sepBody_holds_iff`'s gate branch) + `hσ : qnf.2 σ = true`.
- **full base at [x1,w,x,t]** (`h_atom`): `χ0*` at x1 from `hcorrK`; w/x/t coord types from
  `kvE2_sepPtW`/`EpL`/`EpR` head conjuncts via `nfPred_correct` (`NfToVecEA:69`) — copy the
  `SW:9963-9977` pattern; order bits from `x<x1<w<t` via `atom_eval` + `iff_of_true/false`
  (copy `SW:9982-9991`). Note this is arity-4 base (`nf_eval_nf M 0 4`), a different `match` from
  the outer arity-3; the coordinate reads are analogous.
- **FORWARD, consistent open zones (zXU/zUW/zWT)**: contrapositive of `kvE2_sepSegForm_excludes`
  (`SW:6683`) — BUT see §2, only valid at segment-interior points; witness points need 1-type
  functionality.
- **FORWARD, at/exterior zones (zAtX1L/zAtWL/zAtX4/zAtT4/zPastX4/zFutT4)**: the biconditional
  literals in `kvE2_sepPtX1L` (`SW:297`, self-zone at x1), `kvE2_sepPtW`/`EpL`/`EpR`. A query point
  in these zones IS the coordinate x1/w/x/t (by the zone def), whose type is pinned by the literal.
- **FORWARD, inconsistent zones (the other ~7 of 16)**: vacuous — `kvE_sub2V_zone_consistent`
  (`SubBracket2V.lean:1535`, private) contrapositive: no model point sits in an inconsistent zone
  relative to `x<x1<w<t`. Template usage at `SubBracket2V.lean:1677-1681`
  (`kvE_subBracket2V_gate_holds_of_honest`).
- **BACKWARD** (`h_bwd`): σ0's own slot channel — `kvE_subBracket2V_reaches_z*` SHAPE
  (`SubBracket2V.lean:1087-1139`) but re-derived at the SharedWitness bracket level from the
  bundle's below/above witnesses, + literals at at-zones. The bundle
  (`kvE2_sepBundleL`, `SW:5322`) supplies the zXU below-witnesses directly; zUW/zWT need the
  extractor's above-witnesses (the `hUW`/`hWT` that `kvE2_sepDisjunct'_extract` currently drops —
  it keeps only `hbelow` for zXU via the bundle).

### Zone alignment under hfrag (confirmed clean)
`hfrag` ⇒ `kvE2_sepPos qnf = [σ0]`. LEFT-region bracket segments (`kvE2_sepSegLForSub`, `SW:1127`)
for σ0 are `kvE2_sepSegForm σ0 kvE_sub2_zXU` before the pin and `… kvE_sub2_zUW` after the pin
(`SW:1130-1134`); RIGHT-region segment is `… kvE_sub2_zWT` (`SW:1143-1144`). Relative to env
[x1,w,x,t] these align 1:1 with zones zXU=(x,x1), zUW=(x1,w), zWT=(w,t). The O4 cross-σ residue
(`SW:6698-6791`) genuinely vanishes: every left-list witness is σ0's own slot.

## §2 — The newly-identified crux (READ CAREFULLY)

`kvE2_sepSegForm charBase σ0 zs` at a point `u` (`SW:184`) is
`formula_conjList (univ.map fun χ => if kvE2_sepBits σ0 zs χ then ⊤ else (charBase χ).neg)`.
So it **only excludes bit-FALSE χ**; for bit-TRUE χ it is `⊤` (no constraint). Two consequences:

1. **"segForm holds on all of (x,x1)" is FALSE.** The bracket asserts segForm only on the OPEN
   intervals strictly between consecutive witnesses (`IntervalPattern.holds_eq_succ` components
   4/5/6, `ExistsForallNF.lean:197-203`). At a below-witness point the segment does not apply.
   Hence no standalone extractor can deliver "∀ v ∈ (x,x1), segForm at v" — the gate must case-split.

2. **The FORWARD conjunct's witness case.** Query: `v ∈ zXU`, `nf_eval M 0 1 (fun _=>v) χ`, goal
   `kvE2_sepBits σ0 zXU χ = true`. Contrapositive: assume bit=false. Trichotomy on v vs the bracket
   witnesses `ws` (from `holds_eq_succ`):
   - v strictly inside an open sub-interval ⇒ its beta segment is `kvE2_sepSegForm σ0 zXU`
     (fragment alignment) ⇒ `kvE2_sepSegForm_excludes` gives `¬ χ at v` — contradiction. ✔ (report's channel)
   - v = a below-witness `ws i` (a bit-TRUE slot for some χ_i) ⇒ need `χ = χ_i` to contradict
     bit=false. **This needs 1-type functionality** — and it is **LANDED**:
     **`nf_eval_unique` (`NormalForm.lean:245`)**: `nf_eval_nf M k n env nf1 → nf_eval_nf M k n env nf2
     → nf1 = nf2`. At `k=0, n=1, env = fun _=>v` this gives `χ = χ_i` from both realized at v.
     **No wall here** — the witness-point case closes via `nf_eval_unique`. (The witness's bit-TRUE
     type χ_i is read from `hpt`/the slot enumeration in the `kvE2_sepDisjunct'_extract` preamble.)

## Recommended dispatch-3 plan (supersedes dispatch-1 Step A/B)

1. **1-type functionality is already landed** — `nf_eval_unique` (`NormalForm.lean:245`), see §2.2.
   No probe needed; every forward-conjunct channel now has a landed lemma. **No wall remains** —
   the remaining Phase-1 work is length only (one large gate lemma + the bundle_sound_frag wrapper).
2. Write `kvE2_sepGateAtPin_fragL` as ONE lemma unfolding `.holds` inline:
   - `by_cases hg : kvE2_sepGate qnf` (fail branch: `kvE2_sepBody_gate_fail` → `.holds` is False,
     `simp [VVecEA2.holds]`; copy `kvE2_sepBody_extract` `SW:8425-8430`).
   - `rw [kvE2_sepBody_holds_iff … hg] at h; obtain ⟨wo, hwo, hd⟩ := h`.
   - unfold `hd` via the `kvE2_sepDisjunct'_extract` preamble (`SW:8249-8282`) to get `ws`,
     `hmono`, `hrange`, `hpt`, AND (do NOT discard) the three seg components `hseg0/hsegMid/hsegLast`.
   - x1 := the pin = `ws ⟨|gL_map|-block-for-lX1⟩` — reuse `SW:8295-8310` to locate σ0's lX1 slot
     witness (this is exactly the bundle's x1); the bundle below-witnesses come from `SW:8311-8340`.
   - Derive the six conjuncts at x1 with the channels above; forward uses the trichotomy (§2.2).
   - hcorrK supplies χ0* at x1 for h_atom.
3. `kvE2_sepBundleL_sound_frag`: inline `kvE_subBracket2V_sound_of_parts`'s continuation
   (`:1324-1345`) with the six pin-conjuncts.
4. Then Phase 2 (fragR mirror via `kvE2_sepBundleR_sound` shape + `kvE2_sepBody_kit_sound_frag`) and
   Phase 3 (`kvE2_outer_fold_frag`) as dispatch-1 handoff §§Phase 2/3 describe (unchanged; those
   are byte-mirrors of `SW:9787-9848` and `SW:9897-10035` with hgateL/hgateR/hbdry → hfrag+hcorrK).

## Guards (unchanged, hard)
- NEVER the ∀-anchor extractor (report §1 REFUTED). Every conjunct AT the pin x1, never `∀ a`.
- `hcorrK`/`hexcl` stay explicit hypotheses; never discharged in 344.
- Additive-only below the banner (`SW:10037`). `#print axioms` via `lake env lean` (NOT
  `lean_verify`) = `{propext, Classical.choice, Quot.sound}` on every landed lemma.
- No `sorry`/`admit`/vacuous close on live paths at any commit.
