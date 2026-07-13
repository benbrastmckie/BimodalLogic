# Past Admissibility Conjunct-4 Repair — Task 360 (second machine-refuted blocker)

**Task**: 360 — restate_exterior_hbr_pinned_converse (Phase 4 [BLOCKED] escalation)
**Agent**: lean-research-hard-agent · **Mode**: --hard --lit (H3 Tier 1, H4 active)
**Date**: 2026-07-13 · **Session**: sess_1783950096_9d2925
**Inputs**: handoffs/phase-4-handoff-20260714T050000Z.md (canonical defect record),
reports/02_faithful-pinned-converse-repair.md (slice repair + Def 7.13 discipline),
ExteriorNegationK.lean / ExteriorNegationPastK.lean / ExteriorPinnedConverseK.lean /
ExteriorPinnedConversePastK.lean / ExteriorConverterPastK.lean / ExteriorBracketK.lean /
ExteriorBracketAssembleK.lean / ExteriorGateAssembleK.lean / EndIntervalConsumerK.lean /
KampPrior.lean / frozen ExteriorNegationPast.lean (all read this dispatch),
Rabinovich 2014 chunks 0015/0022 (read verbatim this dispatch).
**Scope**: research only — no production `.lean` edit. One `lean_run_code` feasibility probe
(machine evidence, §3.1), zero diagnostics.

---

## TL;DR

- **Q1 (faithfulness)**: The 4-vs-3 asymmetry is an **in-tree omission by task 352, not a
  paper asymmetry.** Rabinovich's Cor 5.4(2) "is the mirror image of (1) and is proved
  similarly" (chunk_0015:44, read verbatim); Def 7.7's canonical expansion makes each point's
  type a single complete pinned datum (chunk_0022:5) — the segment endpoint carries exactly
  one fresh profile on BOTH sides. The frozen k=2 formalization was symmetric: 
  `kvE2_pastAdmissible` **had condition 4** (ExteriorNegationPast.lean:341–342, read this
  dispatch). Task 352's depth-k reformulation kept a weakened form on the Future side
  (at-most-one profile, ExteriorNegationK.lean:95–98) but dropped it on the Past side with the
  "subsumed by the full-fiber content channel downstream" rationale (ExteriorNegationPastK.lean
  header :45–51) — now machine-refuted: downstream reads self marks only through the
  `kvE_fiberPosOnShift` EXISTENTIAL (ExteriorFiberK.lean:365–372), which cannot enforce per-σ
  uniqueness.
- **Q2 (producer feasibility — DECISIVE)**: **YES, machine-verified this dispatch.** A
  standalone `lean_run_code` probe proved the mirrored conjunct 4 from a Past realizer with
  **zero diagnostics** (§3.1). The proof is a byte-level mirror of the Future branch
  (ExteriorNegationK.lean:170–199) and consumes **no order-direction hypotheses at all** —
  only the side-neutral `kvE_subBit_iff` (ExteriorBracketK.lean:314, arbitrary `env`), the
  `(false,false)` self-zone head coupling (identical on both sides: `kvE_pastSelfZone`,
  ExteriorNegationPastK.lean:213), and `nf_eval_unique`. Option (a) does NOT relocate the
  blocker: the only semantic producer is `kvE_pastRealizer_admissible`, and it can supply the
  conjunct.
- **Recommendation**: **Option (a)** — add conjunct 4 to `kvE_pastAdmissible` (exact signature
  §4) + mechanical re-threading of exactly 3 reader sites (§5). Option (b) is structurally
  dead (§3.3): strengthening the `hslicePast` guard leaves the counterexample σ′ INSIDE the
  bracket's admissibility-filtered conjunction range, where it receives a false negative
  clause — bracket completeness itself becomes unprovable at honest qnf. Only the
  admissibility filter can exclude multi-self-profile types, which is exactly how the
  already-GREEN Future side works.
- **m = 0 sufficiency**: YES (§6). With conjunct 4 restored, `kvE_pastSliceId_of_end_zero`'s
  SELF/true case mirrors the Future case verbatim (the previously-failing third
  `Bool.and_eq_true` rewrite succeeds by construction), and `kvE_hslicePast_supply_zero`
  mirrors the Future supply route. The honest-τ⊕extra-self-mark counterexample is
  **annihilated, not dodged**: it becomes inadmissible (§7, H4 row V2).

---

## 1. Q1 — Rabinovich faithfulness adjudication

### 1.1 The paper is symmetric

- Cor 5.4(2) (chunk_0015:44, verbatim): *"(2) is the mirror image of (1) and is proved
  similarly."* Every structural fact about the Future segment device transfers to the Past
  device under time reversal; there is no Past-side weakening anywhere in §5 or §7.
- Def 7.7 (chunk_0022:5): the canonical TL(Until/Since) expansion interprets each definable
  predicate as the exact truth set — a point's type is a **complete pinned datum**. The
  segment endpoint (the self zone: fresh point = the anchor x1 itself) therefore carries
  **exactly one** fresh profile. This is direction-independent.
- Lemma 7.8 (chunk_0022:9–13) states the negation device for BOTH expansions
  (TL(Since, K+) and TL(Until, K−)) with identical structure.

### 1.2 The in-tree history of the drop

- Frozen k=2: **both** sides carried condition 4. `kvE2_pastAdmissible`
  (ExteriorNegationPast.lean:332–342) conjunct 4: `kvE2_pastSelfBit σ χ = decide (χ =
  nf0_projFresh σ.1)` — "self-zone bits carve out exactly the fresh profile" (docstring :328).
  Symmetric with `kvE2_futAdmissible`.
- Depth-k (task 352): the frozen exactly-the-profile form is F2-dead at depth k (the profile
  is fiber-borne, not a σ.1 marginal). The **Future** side solved this with a weakened, purely
  syntactic conjunct — *at most one* self-zone fresh profile via `kvE_subBit`
  (ExteriorNegationK.lean:95–98, docstring :79–82: "the depth-k faithful replacement for the
  frozen 'self-zone carves exactly the fresh profile'"). The **Past** side dropped the
  condition entirely, claiming (header :45–51) it "is a CONTENT-pinning condition with no
  σ-syntactic depth-k target … its content is carried by the full-fiber channel …
  downstream."
- **The rationale is refuted**: the Future side IS the σ-syntactic depth-k target (uniqueness,
  not content-pinning), and the downstream channel reads self marks only through the
  `kvE_fiberPosOnShift` existential — Phase 4's machine counterexample (honest τ ⊕ one extra
  self-zone mark) satisfies every downstream read while breaking per-σ uniqueness.

**Q1 answer**: genuine paper symmetry; the 4-vs-3 split is an in-tree omission. Task 352's
"subsumed downstream" claim was unfaithful. The faithful Past predicate mirrors the Future's
weakened at-most-one conjunct (NOT the frozen exactly-the-profile form).

## 2. Producer anatomy (where each side establishes conjunct 4)

The Future producer `kvE_futRealizer_admissible` (ExteriorNegationK.lean:124–199) establishes
conjunct 4 at :170–199 by:
1. `kvE_subBit_iff M env σ hnf kvE_futSelfZone χ/χ'` → realizing witnesses v, v' with
   `zoneHolds M env kvE_futSelfZone v` — **side-neutral** (ExteriorBracketK.lean:314–321 takes
   arbitrary `env : Fin 4 → M.carrier`, no order hypotheses);
2. self-zone head coupling `(false,false)` at index 0 (`hzv 0`) forces `¬(v < x1) ∧ ¬(x1 < v)`
   → `v = x1` via `le_antisymm` (same for v');
3. `nf_eval_unique M k 1 (fun _ => x1) χ χ'` → `χ = χ'`.

**No step uses `hxw`/`hwt`/`htx1`.** The Past self zone has the identical head coupling:
`kvE_pastSelfZone : ZoneSpec 4 := Fin.cons (false, false) kvE2_sep_zPastX3`
(ExteriorNegationPastK.lean:213); env index 0 is x1 in both producers. The mirror is verbatim.

## 3. Q2 — producer feasibility (machine evidence) and adjudication

### 3.1 Machine probe (this dispatch, `lean_run_code`, zero diagnostics)

The following standalone snippet **compiled clean** against green HEAD (`lake` module cache),
proving the Past realizer forces the mirrored conjunct 4 — with the order hypotheses present
in the signature but **unused**, exactly like the Future branch:

```lean
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNegationPastK

namespace Bimodal.Metalogic.WeakCanonical.Kamp
open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

theorem probe_past_conjunct4 {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (σ : NormalForm sig (k + 1) 4)
    (x1 w x t : M.carrier)
    (hnf : nf_eval_nf M (k + 1) 4
      (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ((Finset.univ.toList (α := NormalForm sig k 1)).all fun χ =>
      (Finset.univ.toList (α := NormalForm sig k 1)).all fun χ' =>
        !(kvE_subBit σ kvE_pastSelfZone χ) || !(kvE_subBit σ kvE_pastSelfZone χ') ||
          decide (χ = χ')) = true := by
  rw [List.all_eq_true]
  intro χ _
  rw [List.all_eq_true]
  intro χ' _
  by_cases hbχ : kvE_subBit σ kvE_pastSelfZone χ = true
  · by_cases hbχ' : kvE_subBit σ kvE_pastSelfZone χ' = true
    · obtain ⟨v, hzv, hvχ⟩ := (kvE_subBit_iff M _ σ hnf kvE_pastSelfZone χ).mp hbχ
      obtain ⟨v', hzv', hv'χ'⟩ := (kvE_subBit_iff M _ σ hnf kvE_pastSelfZone χ').mp hbχ'
      have hvx1 : v = x1 := by
        have h0 := hzv 0
        have hn1 : ¬ v < x1 := fun hlt => absurd (h0.1.mp hlt) Bool.false_ne_true
        have hn2 : ¬ x1 < v := fun hlt => absurd (h0.2.mp hlt) Bool.false_ne_true
        exact le_antisymm (not_lt.mp hn2) (not_lt.mp hn1)
      have hv'x1 : v' = x1 := by
        have h0 := hzv' 0
        have hn1 : ¬ v' < x1 := fun hlt => absurd (h0.1.mp hlt) Bool.false_ne_true
        have hn2 : ¬ x1 < v' := fun hlt => absurd (h0.2.mp hlt) Bool.false_ne_true
        exact le_antisymm (not_lt.mp hn2) (not_lt.mp hn1)
      rw [hvx1] at hvχ
      rw [hv'x1] at hv'χ'
      have hχχ' : χ = χ' := nf_eval_unique M k 1 (fun _ => x1) χ χ' hvχ hv'χ'
      rw [hbχ, hbχ', hχχ']
      simp
    · rw [Bool.not_eq_true] at hbχ'
      rw [hbχ']
      simp
  · rw [Bool.not_eq_true] at hbχ
    rw [hbχ]
    simp

end Bimodal.Metalogic.WeakCanonical.Kamp
```

Result: `{"success": true, "diagnostics": []}`. `kvE_subBit` is in ExteriorNegationPastK's
import closure (ExteriorFiberK imports ExteriorBracketK). The upstream obligation the
delegation feared does not exist: the producer's input (`hnf`, a Past realizer) already
determines the conjunct, with the same proof budget as the Future side (~30 lines).

### 3.2 Producer census — no other supply site

Complete `kvE_pastAdmissible = true`-producing sites in the tree (exhaustive grep):
- `kvE_pastRealizer_admissible` (ExteriorNegationPastK.lean:149) — the ONLY semantic
  producer. Gains the machine-verified 4th branch (§3.1).
- All other `hadm` introductions route through it: ExteriorNegationPastK:553
  (`kvE_extNegPast_sound`), ExteriorBracketAssembleK:181 (`kvE_extBracketPast_sound`),
  ExteriorGateAssembleK:204 (gate D-case), or arrive as hypotheses/filter membership
  (bracket range :97, binder guards). Zero synthetic (non-realizer) producers exist.

### 3.3 Option (b) is structurally dead — the adjudication

(b) = strengthen the `hslicePast` binder guard (e.g., add self-profile-uniqueness of σ as an
antecedent at EndIntervalConsumerK:139–144 / GateAssembleK / KampPrior). This makes the m=0
SUPPLY theorem provable (σ′ fails the guard), but **relocates the falsity into bracket
completeness**: under 3-conjunct admissibility, σ′ REMAINS in `kvE_extBracketPast`'s
conjunction range (the range filters by `kvE_pastAdmissible` only,
ExteriorBracketAssembleK:97). σ′ is slice-UNMARKED (its self-zone list `[χ_τ, χ']` differs
from every realizable type's singleton list, so no marked mate is `kvE_pastSliceEq` to it) —
the re-keyed bracket asserts the NEGATIVE clause `¬ kvE_pastPos P σ′`. But `kvE_pastPos P σ′`
FIRES at x for the honest configuration (its gap/ray lists are τ's honest lists; its endpoint
self conjunct is the `kvE_fiberPosOnShift` existential, satisfied by χ_τ's honest witness —
the same machine-evidenced facts as the Phase-4 counterexample). So
`kvE_extBracketPast_complete` at honest qnf would have to prove a false conjunct — unprovable
regardless of any binder guard. **The only place σ′ can be excluded is the admissibility
filter itself** — option (a). This is confirmed by existence proof: the Future side has
conjunct 4 in its filter and its entire re-threaded chain is GREEN (full build, 1736 jobs).

## 4. The exact repair (option (a))

**Append as conjunct 4 to `kvE_pastAdmissible`** (ExteriorNegationPastK.lean:134–140),
mirroring the Future's associativity `((c1 && c2) && c3) && c4`:

```lean
  ((Finset.univ.toList (α := NormalForm sig k 1)).all fun χ =>
    (Finset.univ.toList (α := NormalForm sig k 1)).all fun χ' =>
      !(kvE_subBit σ kvE_pastSelfZone χ) || !(kvE_subBit σ kvE_pastSelfZone χ') ||
        decide (χ = χ'))
```

(Requires no new imports; `kvE_subBit` reaches the file via ExteriorFiberK → ExteriorBracketK.
Note the Future's conjunct 3 uses the `kvE_subBit` marginal form while the Past's conjunct 3
uses the direct full-fiber form — that difference is benign; conjunct 4 must use the
`kvE_subBit` form because the SELF/true consumer (the slice-id mirror of
ExteriorPinnedConverseK.lean:1050–1067) assembles `kvE_subBit` witnesses from fiber elements.)

**Producer** `kvE_pastRealizer_admissible` (:149–...): change `refine ⟨⟨?_, ?_⟩, ?_⟩` to
`refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩` and append the §3.1 probe body as the 4th branch (drop the
`rw [List.all_eq_true]`-goal adaptation as needed; the probe proved the exact conjunct shape).

**Docstring corrections** (required for H3 hygiene): ExteriorNegationPastK.lean header
:45–51 and the def docstring :125–133 ("content-pinning … subsumed downstream" — refuted;
replace with the Future's :79–82 uniqueness rationale). Also the memory-candidate note in
`.return-meta.json` already records the refutation.

## 5. Territory (complete file list)

Decomposition census is exhaustive (grep over `unfold/rw/simp/show kvE_pastAdmissible`,
Theories/ + Tests/): exactly 1 producer + 3 readers decompose the predicate. Tests: zero hits.

| # | File | Change | Nature |
|---|------|--------|--------|
| 1 | `Theories/.../NfMultiAnchorBridge/ExteriorNegationPastK.lean` | def :134–140 (+conjunct 4); producer :149+ (+branch, §3.1 machine-verified); header :45–51 + def docstring :125–133 corrections | Substantive (the repair) |
| 2 | `Theories/.../NfMultiAnchorBridge/ExteriorConverterPastK.lean` | `kvE_pastAdmissible_fiber_dichotomy` :33–46: `unfold` decomposition gains one projection (`hadm'.1.…`) | Mechanical (+1 projection) |
| 3 | `Theories/.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean` | :233–234: `hh.1.1` → `hh.1.1.1` after the extra `Bool.and_eq_true` | Mechanical (one token) |
| 4 | `Theories/.../NfMultiAnchorBridge/ExteriorPinnedConversePastK.lean` | `kvE_pastAdmissible_zoneMark` :130–140: 2 → 3 `Bool.and_eq_true` rewrites + projection; then the UNBLOCKED Phase-4 targets: `kvE_pastSliceId_of_end_zero` (SELF/true case now mirrors ExteriorPinnedConverseK:1041–1082 verbatim — the failing third rewrite succeeds by construction) + `kvE_pastGapItem_pinned_zero` / `kvE_pastRayItem_pinned_zero` | Mechanical + the Phase-4 completion |

Recompile-only (statements reference `kvE_pastAdmissible` opaquely; **no edits**):
`ExteriorBracketAssembleK.lean` (:97 filter, :127/:181/:245–250), `EndIntervalConsumerK.lean`
(:139–157 binders), `KampPrior.lean` (:856–869 binders, :1500–1524/:1614–1638 opaque readers
via `kvE_pastAdmissible_onFiber`/`_offFiber`), `ExteriorNegationPastK`'s own
`kvE_pastPos`/`kvE_extNegPast_sound`/`_complete` (:459 if-condition, :553 producer call).

Frozen layer untouched: `kvE2_pastAdmissible` is a distinct decl; no frozen file edited.

If the Past slice-id proof needs a mark-erasure lemma (the Future refutation used
`kvE_futAdmissible_of_subMarking`, ExteriorPinnedConverseK:397): conjunct 4 is ANTITONE in the
marking (`kvE_subBit_mono` is zone-generic; sub-markings shrink the marked set), and the
Future lemma's conjunct-4 branch (:441–…) is the exact reusable pattern. Not expected to be
needed for the m=0 targets (the Future m=0 slice-id does not consume it), but in-territory
(file 4) if it is.

## 6. m = 0 sufficiency for task 358's `:361` Past arm

With conjunct 4 restored:
1. `kvE_pastSliceId_of_end_zero` SELF/true case: `hc4 := hadm'.2` after THREE
   `Bool.and_eq_true` rewrites (the machine-diagnosed failure point) → `kvE_subBit` witnesses
   for `nfk_projFresh s` / `nfk_projFresh s0` → profile equality → `nf0_split_assemble`
   identification `s = s0` — verbatim mirror of ExteriorPinnedConverseK:1041–1082. All other
   cases (gap/ray, SELF/false) were reported unobstructed by the Phase-4 handoff, and their
   suppliers (`kvE_pastSliceUnique_zero`, `kvE_pastAtomPinned_zero`,
   `kvE_pastSelfZone_coincide`, the private zone lemmas) LANDED GREEN in commit `4e5a3bd73`.
2. `kvE_hslicePast_supply_zero` (Phase 5): mirrors the Future route — destruct
   `kvE_pastPos` (KampPrior:1614–1645 destructor pattern) → endpoint x1 < x with
   `hend`/`hgap`/`hocc` → slice-id → marked slice-mate. The binder guard
   `kvE_pastAdmissible σ = true` (EndIntervalConsumerK:139–144) now carries conjunct 4, which
   is exactly what the slice-id consumes.
3. The other three Phase-5 supply theorems are unaffected (handoff: `hexclSlicePast` route
   consumes only uniqueness + `hreal` + the zone-marking reader — all landed; the reader gets
   the mechanical +1 rewrite).
4. Consumers of the strengthened predicate only ever ESTABLISH it via the realizer route
   (machine-verified) or receive it as hypothesis; the strengthened `hslicePast` conclusion
   (`σ'` admissible-4) is supplied at m=0 by a REALIZED σ' (realizer → all 4 conjuncts).

## 7. H4 — Adversarial Self-Verification

Mandated refutation attempt: the Phase-4 counterexample σ′ := honest τ ⊕ extra self mark
`s' = nf0_assemble kvE_pastSelfZone χ' τ.1` re-run against every repaired statement.

- τ (honest endpoint characteristic at x1) marks its self element (self zone holds at v = x1:
  head coupling `(false,false)` vacuous at x1; tail couplings = `kvE2_sep_zPastX3`, true since
  x1 < x < w < t), with profile χ_τ. If χ' = χ_τ, then `s'` IS the honest element
  (`nf0_split_assemble`) and σ′ = τ — no counterexample. If χ' ≠ χ_τ, then
  `kvE_subBit σ′ kvE_pastSelfZone` is true at BOTH χ_τ and χ' → conjunct 4 = false →
  **σ′ inadmissible** → excluded from the slice-id's `hadm`, from the `hslicePast` guard, and
  from the bracket's conjunction range. The counterexample family is annihilated with no
  residue.

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|------------------------|----------------------|------------|
| V1. Past producer can establish conjunct 4, using no order hypotheses | §3.1 probe | `lean_run_code` GREEN this dispatch (zero diagnostics) | High |
| V2. σ′ (honest τ ⊕ extra self mark, χ' ≠ χ_τ) fails restored conjunct 4; χ' = χ_τ degenerates to σ′ = τ | direct evaluation of `kvE_subBit` at the two marks + `nf0_split_assemble` | reasoning over machine-read defs (kvE_subBit :302–307, nf0_assemble coordinates); shape identical to the Future SELF/true case's machine-proven identification | High |
| V3. `kvE_subBit_iff` is side-neutral (arbitrary env, no order side conditions) | ExteriorBracketK.lean:314–321 | Read of full statement + proof this dispatch | High |
| V4. Frozen k=2 Past predicate HAD condition 4 (task 352 dropped it) | ExteriorNegationPast.lean:328, :341–342 | Read this dispatch | High |
| V5. Paper symmetry: Cor 5.4(2) mirror; Def 7.7 one-complete-type-per-point | chunk_0015:44 ("mirror image … proved similarly"), chunk_0022:5 | direct literature read this dispatch | High |
| V6. Decomposition census complete: 1 producer + 3 readers, no test refs | grep `unfold/rw/simp/show kvE_pastAdmissible` over Theories/ + Tests/ | exhaustive grep this dispatch (4 hits total) | High |
| V7. No synthetic producer exists (nothing proves admissibility except the realizer lemma / hypotheses / filter membership) | grep census §3.2 | Read of all 4 non-reader `hadm` sites | High |
| V8. Option (b) leaves bracket completeness false at honest qnf (σ′ in range, slice-unmarked, positive form fires) | §3.3 | reasoning chained from Phase-4 machine evidence (σ′ satisfies all downstream reads) + Read of bracket range :97 and `kvE_pastSliceEq` self-list comparison | High |
| V9. Strengthened `hslicePast` conclusion suppliable at m=0 (σ' realized ⇒ admissible-4) | producer probe V1 | corollary of V1 | High |
| V10. Landed Phase-4 mirrors survive re-threading (zoneMark +1 rewrite; others via opaque readers) | §5 table | Read of each landed proof's decomposition depth | High |
| V11. SELF/true case of the Past slice-id closes with conjunct 4 (mirror of Future :1041–1082) | the previously-failing 3rd `Bool.and_eq_true` rewrite | Read of the Future case + the machine-diagnosed failure mode (missing pattern occurrence, now present by construction); composite NOT machine-run — flagged as the plan revision's Phase-4 re-dispatch probe | Medium |

**Contradiction log**: task 352's "condition 4 subsumed by the full-fiber content channel
downstream" (ExteriorNegationPastK header :45–51) vs the Phase-4 machine counterexample.
Resolution per precedence: machine-checked refutation > docstring reasoning — the docstring
claim is superseded and must be corrected in file 1 (§4). No unresolved contradictions.

Residual risk is confined to V11 (Medium): the slice-id composite was not machine-run
end-to-end (it requires the production edit). Mitigation: the failure mode was a REWRITE
pattern absence, cured definitionally by the added conjunct; every other step of the case is
byte-mirrored from a GREEN Future proof; and the re-dispatch instruction (§8) makes the
SELF/true case the first verification target.

## 8. Plan-revision deltas (for /revise)

1. **New Phase 4a (repair, before re-dispatching Phase 4's blocked theorem)**: files 1–3 of
   §5 — add conjunct 4 + producer branch (§3.1 body), re-thread the 3 readers, correct the
   two docstrings. Verification: scoped `lake build` of ExteriorGateAssembleK (transitively
   rebuilds 1–3) then full build.
2. **Phase 4 re-dispatch (file 4)**: `kvE_pastAdmissible_zoneMark` +1 rewrite; then
   `kvE_pastSliceId_of_end_zero` (SELF/true first — V11 gate), then
   `kvE_pastGapItem_pinned_zero`/`kvE_pastRayItem_pinned_zero`.
3. **Phase 5 unchanged in scope**: all four supply theorems now dischargeable;
   `kvE_hslicePast_supply_zero` via destructor + slice-id (§6 route).
4. **No interface change** to EndIntervalConsumerK/KampPrior/GateAssembleK binder STATEMENTS
   (they reference the predicate opaquely) — the Phase-3b seam survives as-is.
5. **Memory candidate** (carried from Phase-4 handoff, confirmed here): admissibility
   predicates that gate clause-family ranges must carry per-σ uniqueness conditions
   syntactically; existential downstream reads can never subsume them.

## Appendix — evidence anchors

- Machine (all read this dispatch):
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNegationK.lean`
  (:70 self zone, :86–98 def, :124–199 producer incl. conjunct-4 branch :170–199);
  `ExteriorNegationPastK.lean` (:45–51 drop rationale, :134–140 def, :149+ producer, :213
  self zone, :459 `kvE_pastPos`, :553 `_sound`); `ExteriorBracketK.lean` (:302–307
  `kvE_subBit`, :314–321 `kvE_subBit_iff` — side-neutral); `ExteriorPinnedConverseK.lean`
  (:397–455 `of_subMarking` incl. conjunct-4-under-erasure, :1041–1094 SELF case);
  `ExteriorPinnedConversePastK.lean` (:33–103 slice defs + constancy, :126–140 zoneMark);
  `ExteriorConverterPastK.lean` (:33–61 dichotomy/readers); `ExteriorBracketAssembleK.lean`
  (:97 range, :170–187 `_sound`); `ExteriorGateAssembleK.lean` (:195–245 D-cases + :233);
  `EndIntervalConsumerK.lean` (:139–164 binders); `KampPrior.lean` (:1605–1645 destructor
  pattern); frozen `ExteriorNegationPast.lean` (:322–354 `kvE2_pastAdmissible` + producer).
- Probe: §3.1 `lean_run_code`, success, empty diagnostics (this dispatch).
- Literature: `~/Projects/Literature/sources/rabinovich_2014/chunk_0015.md` (:44),
  `chunk_0022.md` (:5, :9–13).
- Task artifacts: `handoffs/phase-4-handoff-20260714T050000Z.md`;
  `reports/02_faithful-pinned-converse-repair.md` (§3.3–3.4 slice architecture this repair
  completes).
