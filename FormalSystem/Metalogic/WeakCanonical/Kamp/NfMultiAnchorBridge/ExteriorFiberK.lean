/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterface
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfEFold
import Mathlib.Tactic.FinCases

/-! # Depth-`k` full-fiber content channel

The F2-safe content channel for the depth-`k` clause layer: the truth-bearing content of
every rung-(k+1) clause is a finite disjunction of `P.existF 4` applied DIRECTLY to full
fiber elements `s : NormalForm sig k 5` with `σ.2 s = true` — never a Boolean combination
indexed by the collapsed marginal profile `χ : NormalForm sig k 1` (guard G6; this channel's
central design ruling, research Conflict 1).

**Rabinovich fidelity (mapping table rows 1-2)**: the clause entries of the rung-(k+1)
bracket are rung-`k` FORMULAS (Def 7.5, chunk 0021:17; Def 3.1 p.4 + Notation 5.2 p.8 —
entries are formulas of the previous round, never rung-`k` brackets, per the E-verified
resolution-(a) reading of Lemma 7.8). Those formulas are the Def 4.1/7.7 canonical-expansion
images of the fiber elements: `P.existF 4 s` is the E[Σ,TL]-atom rendering of the full-arity
sub `s` (idempotent expansion, chunk 0011:5 / chunk 0022:5), supplied by the canonical
`ExistProviders sig atomMap k` bundle (PriorInterface.lean:38-46) consumed VERBATIM
(postmortem rule 11).

**Why full-fiber (F2 immunity)**: the marginal channels (`kvESubBit`, `kvEFutAnyBit`,
`kvEProjFreshD` — ExteriorBracketK.lean) read a sub only through its zone spec and its
depth-`k` arity-1 fresh shadow; the F2 counterexample pair (`f2sub1`/`f2sub2`,
RefutationF2.lean:335/339) agrees on BOTH channels yet differs at the full fiber element
`e*` (`f2_estar_in_sub1`/`f2_estar_not_in_sub2`), which is why every marginal construction
collapses (`f2_carrier_eq`, RefutationF2.lean:582). The channel below indexes content by the
full fiber element itself, so the pair separates — machine-checked in the companion probe
module `ExteriorFiberProbeK.lean` (Phase 1.2, the GO/NO-GO gate).

List conventions mirror the frozen `kvE2FutGapList` (ExteriorNegation.lean:890, read-only
template) and the landed `kvESepPos` (ExteriorBracketK.lean:183): `Finset.univ.toList`
filtered by the quant-layer bit — a stable-order, nodup, Fintype-backed enumeration.

Purely additive NEW leaf module; no frozen file is touched (postmortem rule 5); the landed
determinacy core is consumed unchanged (postmortem rule 6). -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (formulaDisjList formula_disjList_iff)

/-! ## The positive-sub fiber of a depth-`(k+1)` arity-4 sub -/

/-- **Positive-sub fiber** of `σ : NormalForm sig (k+1) 4`: the finite (Fintype-backed,
    stable-order, nodup) enumeration of the full-arity depth-`k` subs σ prescribes —
    `{s : NormalForm sig k 5 // σ.2 s = true}` as a list. This is the CONTENT index set of
    the depth-`k` clause layer (G6): clause disjuncts range over these `s` directly, never
    over their marginal shadows. Mirrors `kvE2FutGapList` (ExteriorNegation.lean:890) /
    `kvESepPos` (ExteriorBracketK.lean:183). -/
noncomputable def kvEFiber {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (σ : NormalForm sig (k + 1) 4) : List (NormalForm sig k 5) :=
  (Finset.univ.toList (α := NormalForm sig k 5)).filter fun s => σ.2 s

/-- Membership unfold for `kvEFiber`: the fiber enumerates exactly the bit-true subs. -/
theorem kvE_fiber_mem {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (s : NormalForm sig k 5) :
    s ∈ kvEFiber σ ↔ σ.2 s = true := by
  simp only [kvEFiber, List.mem_filter, Finset.mem_toList, Finset.mem_univ, true_and]

/-! ## The full-fiber content disjunction -/

/-- **Bucketed content disjunction** over a sub-list `l` of the fiber: the finite
    disjunction of the canonical-expansion images `P.existF 4 s` for `s ∈ l` — the form
    every per-zone clause disjunct of the depth-`k` clause layer consumes (the bucket
    sub-lists are produced by the Phase-2 navigation partition; the CONTENT rendering is
    always `P.existF` on the full element, G6). Def 7.5 entries via Def 4.1/7.7 canonical
    expansion (mapping table rows 1-2). Empty bucket gives `⊥`. -/
noncomputable def kvEFiberPosOn {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (l : List (NormalForm sig k 5)) : Formula :=
  formulaDisjList (l.map (P.existF 4))

/-- **Full-fiber positive content form** of `σ : NormalForm sig (k+1) 4`: the disjunction
    of `P.existF 4 s` over ALL fiber elements of σ — the whole-fiber instance of
    `kvEFiberPosOn` (content position; G6-compliant by construction). -/
noncomputable def kvEFiberPos {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (σ : NormalForm sig (k + 1) 4) : Formula :=
  kvEFiberPosOn P (kvEFiber σ)

/-! ## UZ/SZ-conditional truth characterizations (via `P.correct 4`) -/

/-- **Bucketed correctness**: on Prior (UZ/SZ) structures, the bucketed disjunction holds
    at `t` iff SOME listed fiber element is realized over an anchor environment ending at
    `t` (`insertEnv env t` — the `P.correct` anchor convention, PriorInterface.lean:41-45).
    Statement shape is `P.correct 4` distributed over `formula_disjList_iff`. -/
theorem kvE_fiberPosOn_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (l : List (NormalForm sig k 5))
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (kvEFiberPosOn P l) ↔
      ∃ s ∈ l, ∃ env : Fin 4 → M.carrier,
        NfEvalNf M k 5 (insertEnv env t) s := by
  rw [kvEFiberPosOn, formula_disjList_iff]
  constructor
  · rintro ⟨φ, hφmem, hφ⟩
    obtain ⟨s, hsl, rfl⟩ := List.mem_map.mp hφmem
    exact ⟨s, hsl, (P.correct 4 s M h_UZ h_SZ t).mp hφ⟩
  · rintro ⟨s, hsl, henv⟩
    exact ⟨P.existF 4 s, List.mem_map.mpr ⟨s, hsl, rfl⟩,
      (P.correct 4 s M h_UZ h_SZ t).mpr henv⟩

/-- **Full-fiber correctness** (the Phase-1.1 headline): on Prior (UZ/SZ) structures, the
    full-fiber content form of σ holds at `t` iff σ prescribes SOME full-arity depth-`k`
    sub realized over an anchor environment ending at `t`. The content channel reads
    `σ.2 s` directly on full elements — the exact F2-safe discipline (G6). -/
theorem kvE_fiberPos_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (σ : NormalForm sig (k + 1) 4)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (kvEFiberPos P σ) ↔
      ∃ s : NormalForm sig k 5, σ.2 s = true ∧
        ∃ env : Fin 4 → M.carrier,
          NfEvalNf M k 5 (insertEnv env t) s := by
  rw [kvEFiberPos, kvE_fiberPosOn_correct P (kvEFiber σ) M h_UZ h_SZ t]
  constructor
  · rintro ⟨s, hmem, henv⟩
    exact ⟨s, (kvE_fiber_mem σ s).mp hmem, henv⟩
  · rintro ⟨s, hbit, henv⟩
    exact ⟨s, (kvE_fiber_mem σ s).mpr hbit, henv⟩

/-! ## Phase 2: shared navigation and fiber-partition layer

Side-shared navigation scaffolding both clause layers (Future `ExteriorNegationK`, Past
`ExteriorNegationPastK`) consume. Fiber elements `s : NormalForm sig k 5` are partitioned by
their zone spec (`nfkZoneSpec s`, read off the atom layer via `nf0ZoneSpec` — Q4: atom layer
`s.atomAssgn` only, NfEFold.lean:586-588) and their fresh profile (`nfkProjFresh s`,
CarrierKv.lean:82). Bucket honesty is tied to the landed determinacy core through
`kvESubBit`/`kvE_subBit_iff` (ExteriorBracketK.lean:302/314) — MEMBERSHIP/NAVIGATION facts
only, never content (guard G6): the CONTENT rendering of any bucket is always
`kvEFiberPosOn P bucket` (`P.existF` on the full element), applied downstream in Phases 3-4.

Chain-assembly ordering helpers (`kvEFiberZoneList`) generalize the frozen list-filter shape
`kvE2FutGapList`/`kvE2FutRayList` (ExteriorNegation.lean:890/895) with the element source
swapped from the marginal-profile universe to fiber buckets; the generic min-pick combinator
`kvE_minPick` is a byte-identical replica of the private `kvE2_futMinPick`
(ExteriorNegation.lean:1146-1149) exposed as a shared decl (Lemma 5.3 case-2 discrete
specialization). After this phase `ExteriorFiberK.lean` is FROZEN for waves 3-5 (H7). -/

/-! ### Fiber-drop honesty (realized σ pins every positive sub to σ's atom fiber) -/

/-- Under a realized `σ`, every positive fiber element sits on `σ`'s atom fiber
    (`nfkDropFresh s = σ.1`): the off-fiber clause of `nf_eval_nfk_iff_efold`
    (NfEFold.lean:627) reports `σ.2 s = false` off-fiber, so a bit-true `s` cannot be off it.
    Navigation-only (no content read). -/
theorem kvE_fiber_dropFresh {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin 4 → M.carrier)
    (σ : NormalForm sig (k + 1) 4) (hσ : NfEvalNf M (k + 1) 4 env σ)
    (s : NormalForm sig k 5) (hs : s ∈ kvEFiber σ) :
    nfkDropFresh s = σ.1 := by
  have hbit : σ.2 s = true := (kvE_fiber_mem σ s).mp hs
  obtain ⟨-, hoff⟩ := (nf_eval_nfk_iff_efold M env σ).mp hσ
  by_contra hne
  rw [hoff s hne] at hbit
  exact Bool.noConfusion hbit

/-- The fiber is nodup (Fintype-backed filter of `Finset.univ.toList`). -/
theorem kvE_fiber_nodup {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (σ : NormalForm sig (k + 1) 4) : (kvEFiber σ).Nodup :=
  (Finset.univ.nodup_toList (α := NormalForm sig k 5)).filter _

/-! ### Fiber partition by zone spec and fresh profile -/

/-- **Fiber bucket** of `σ` at zone spec `zs4` and fresh profile `χ`: the fiber elements whose
    zone (`nfkZoneSpec`, atom-layer read) is `zs4` and whose fresh profile (`nfkProjFresh`)
    is `χ`. Navigation-only partition key (G6); the bucket's CONTENT is rendered downstream by
    `kvEFiberPosOn P (kvEFiberBucket σ zs4 χ)`. -/
noncomputable def kvEFiberBucket {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (zs4 : ZoneSpec 4) (χ : NormalForm sig k 1) :
    List (NormalForm sig k 5) :=
  (kvEFiber σ).filter fun s => decide (nfkZoneSpec s = zs4) && decide (nfkProjFresh s = χ)

/-- Membership unfold for `kvEFiberBucket`: bit-true subs with matching zone and profile. -/
theorem kvE_fiberBucket_mem {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (zs4 : ZoneSpec 4) (χ : NormalForm sig k 1)
    (s : NormalForm sig k 5) :
    s ∈ kvEFiberBucket σ zs4 χ ↔
      σ.2 s = true ∧ nfkZoneSpec s = zs4 ∧ nfkProjFresh s = χ := by
  simp only [kvEFiberBucket, List.mem_filter, kvE_fiber_mem, Bool.and_eq_true,
    decide_eq_true_eq]

/-- A fiber bucket is nodup. -/
theorem kvE_fiberBucket_nodup {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (zs4 : ZoneSpec 4) (χ : NormalForm sig k 1) :
    (kvEFiberBucket σ zs4 χ).Nodup :=
  (kvE_fiber_nodup σ).filter _

/-- **Bucket honesty** (via `kvE_subBit_iff`, ExteriorBracketK.lean:314): under a realized
    `σ`, the `(zs4, χ)` bucket is nonempty iff the model actually places a point in zone `zs4`
    of `env` carrying fresh profile `χ`. Purely a MEMBERSHIP/navigation fact — the reduction to
    `kvESubBit` is exact because `kvE_fiber_dropFresh` supplies the atom-fiber label the
    determinacy read requires (G6: no content). -/
theorem kvE_fiberBucket_nonempty_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin 4 → M.carrier)
    (σ : NormalForm sig (k + 1) 4) (hσ : NfEvalNf M (k + 1) 4 env σ)
    (zs4 : ZoneSpec 4) (χ : NormalForm sig k 1) :
    (∃ s, s ∈ kvEFiberBucket σ zs4 χ) ↔
      ∃ v : M.carrier, zoneHolds M env zs4 v ∧ NfEvalNf M k 1 (fun _ => v) χ := by
  rw [← kvE_subBit_iff M env σ hσ zs4 χ]
  constructor
  · rintro ⟨s, hs⟩
    rw [kvE_fiberBucket_mem] at hs
    obtain ⟨hbit, hz, hp⟩ := hs
    have hd : nfkDropFresh s = σ.1 :=
      kvE_fiber_dropFresh M env σ hσ s ((kvE_fiber_mem σ s).mpr hbit)
    refine List.any_eq_true.mpr ⟨s, Finset.mem_toList.mpr (Finset.mem_univ s), ?_⟩
    rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
    exact ⟨⟨⟨decide_eq_true hd, decide_eq_true hz⟩, decide_eq_true hp⟩, hbit⟩
  · intro hbit
    obtain ⟨s, -, hread⟩ := List.any_eq_true.mp hbit
    rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hread
    obtain ⟨⟨⟨_, hz⟩, hp⟩, hsbit⟩ := hread
    refine ⟨s, ?_⟩
    rw [kvE_fiberBucket_mem]
    exact ⟨hsbit, of_decide_eq_true hz, of_decide_eq_true hp⟩

/-! ### Chain-assembly ordering helper (fiber-bucket list-filter, side-generic)

`kvEFiberZoneList σ zs4` is the depth-`k` analog of the frozen `kvE2FutGapList`/
`kvE2FutRayList` (ExteriorNegation.lean:890/895): a nodup list-filter of the fiber, but with
the element source swapped from the marginal-profile universe to the full fiber, keyed by the
zone spec `zs4` alone. Each side (Future/Past) instantiates it with its own gap/ray/self zone
specs in Phase 3/4 — the helper itself is side-agnostic (G6: zone read only). -/

/-- Fiber elements of `σ` sitting in zone `zs4` (any fresh profile). The chain-assembly gap/ray
    list-filter, element source = fiber buckets. -/
noncomputable def kvEFiberZoneList {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (zs4 : ZoneSpec 4) : List (NormalForm sig k 5) :=
  (kvEFiber σ).filter fun s => decide (nfkZoneSpec s = zs4)

/-- Membership unfold for `kvEFiberZoneList`. -/
theorem kvE_fiberZoneList_mem {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (zs4 : ZoneSpec 4) (s : NormalForm sig k 5) :
    s ∈ kvEFiberZoneList σ zs4 ↔ σ.2 s = true ∧ nfkZoneSpec s = zs4 := by
  simp only [kvEFiberZoneList, List.mem_filter, kvE_fiber_mem, decide_eq_true_eq]

/-- A fiber zone list is nodup. -/
theorem kvE_fiberZoneList_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (zs4 : ZoneSpec 4) :
    (kvEFiberZoneList σ zs4).Nodup :=
  (kvE_fiber_nodup σ).filter _

/-! ### Generic min-pick combinator (shared replica of the private `kvE2_futMinPick`)

Byte-identical proof template of `kvE2_futMinPick` (ExteriorNegation.lean:1146-1149, `private`
in the frozen file — replicated here, never imported, per postmortem rule / risk note). Fully
`{α : Type}`-generic, so a single shared decl serves both the Future and Past chain builders
(Lemma 5.3 case-2 discrete specialization per the mapping table). -/

/-- **Generic minimal-witness pick**: from a nonempty list `l` each of whose elements has some
    `M`-witness under `P`, extract one element with a `≤`-minimal witness dominating a witness
    for every element of `l`. -/
theorem kvE_minPick {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {α : Type}
    (M : OrderedMonadicStructure sig) (P : α → M.carrier → Prop) :
    ∀ l : List α, l ≠ [] → (∀ a ∈ l, ∃ r, P a r) →
      ∃ a₀, a₀ ∈ l ∧ ∃ r₀, P a₀ r₀ ∧ ∀ a ∈ l, ∃ r, P a r ∧ r₀ ≤ r := by
  intro l
  induction l with
  | nil => intro h; exact absurd rfl h
  | cons a l ih =>
    intro _ hocc
    obtain ⟨r, hr⟩ := hocc a (by simp)
    by_cases hl : l = []
    · subst hl
      refine ⟨a, by simp, r, hr, fun b hb => ?_⟩
      rw [List.mem_singleton] at hb
      subst hb
      exact ⟨r, hr, le_refl r⟩
    · obtain ⟨a', ha'mem, r', hr', hmin⟩ :=
        ih hl (fun c hc => hocc c (List.mem_cons_of_mem a hc))
      rcases le_or_gt r r' with hle | hlt
      · refine ⟨a, by simp, r, hr, fun c hc => ?_⟩
        rcases List.mem_cons.mp hc with rfl | hc'
        · exact ⟨r, hr, le_refl r⟩
        · obtain ⟨r'', hr'', hge⟩ := hmin c hc'
          exact ⟨r'', hr'', hle.trans hge⟩
      · refine ⟨a', List.mem_cons_of_mem a ha'mem, r', hr', fun c hc => ?_⟩
        rcases List.mem_cons.mp hc with rfl | hc'
        · exact ⟨r, hr, hlt.le⟩
        · exact hmin c hc'

/-! ## Reindex/re-anchor bridge (blocker-resolution) — SHARED, SYMMETRIC

Additive block landing the research-verified (report `02_reindex-bridge-blocker.md`,
Deliverable 2; verdict GO) recursive rung re-anchoring bridge. Both the Future
(`ExteriorNegationK`) and Past (`ExteriorNegationPastK`) `_sound`/`_complete` consume
`kvEFiberPosOnShift`/`kvE_fiberPosOnShift_correct` IDENTICALLY (H7 symmetric contract) — the
fold-slot (index 0, fresh) vs endpoint (index 4=last) convention is temporal-direction-agnostic;
direction is carried by the zone/chain layer, not the anchor index.

**Rabinovich fidelity (Def 7.5 / Lemma 5.3 / Cor 5.4(2), chunk_0013/0014/0015/0021)**: the
index-0 ↔ index-4 shift is NOT a mismatch — it is the literal encoding of the recursive rung step
`(∃r0)[z0<r0<z1] (INF(z0,r0,z1,P1) ∧ On(P2,…,Pn, r0, z1))`, in which the freshly-∃-quantified
interior point `r0` (fold slot-0) BECOMES the left endpoint anchor of the recursive sub-bracket
`On(…, r0, z1)` (existF index-last). The rename IS that re-anchoring. Bijective (variable
permutation) ⇒ lossless (Cor 5.4(2) inductive step; not an F2-style information collapse).

Builds on the pre-existing, fully-proven general-`k` bijective transport
`renameNF`/`renameNF_eval_iff` (`NfDepth0Generalized.lean:373`/`:440`), already in this file's
import graph via `NfEFold`. No new imports beyond `Mathlib.Tactic.FinCases` (for `fin_cases`). -/

/-- Cyclic shift on `Fin 5`: index 0 (fold-fresh) ↦ index 4 (existF endpoint), rest shift by one.
    The syntactic half of Rabinovich Cor 5.4(2) rung re-anchoring. -/
def rot5Fwd : Fin 5 → Fin 5 := fun i => i + 1

/-- Inverse cyclic shift on `Fin 5`: index 4 (existF endpoint) ↦ index 0 (fold-fresh). -/
def rot5Bwd : Fin 5 → Fin 5 := fun i => i - 1

/-- `rot5Fwd` is a section of `rot5Bwd`. -/
theorem rot5_sec : ∀ i, rot5Fwd (rot5Bwd i) = i := by decide

/-- `rot5Bwd` is a section of `rot5Fwd`. -/
theorem rot5_sec2 : ∀ i, rot5Bwd (rot5Fwd i) = i := by decide

/-- Environment compatibility (`renameNF_eval_iff` hypothesis `hcomp`): the anchor environment
    `insertEnv env p` (point `p` at LAST index 4) equals `Fin.cons p env` (point `p` at index 0)
    precomposed with `rot5Fwd`. -/
theorem rot5_comp {α : Type*} (env : Fin 4 → α) (p : α) :
    ∀ i, insertEnv env p i = (Fin.cons p env : Fin 5 → α) (rot5Fwd i) := by
  intro i; fin_cases i <;> rfl

/-- Environment compatibility (`renameNF_eval_iff` hypothesis `hcomp2`): `Fin.cons p env` equals
    the anchor environment `insertEnv env p` precomposed with `rot5Bwd`. -/
theorem rot5_comp2 {α : Type*} (env : Fin 4 → α) (p : α) :
    ∀ i, (Fin.cons p env : Fin 5 → α) i = insertEnv env p (rot5Bwd i) := by
  intro i; fin_cases i <;> rfl

/-- **THE BRIDGE** (Rabinovich Cor 5.4(2) re-anchoring, chunk_0014:35/chunk_0015). Content channel
    evaluating `renameNF rot5Fwd rot5Bwd s` at `insertEnv env p` (point `p` at LAST index 4 —
    `P.existF 4` endpoint convention) holds IFF the original `s` is realized at `Fin.cons p env`
    (point `p` at index 0 — σ's fold-slot convention). Pure instantiation of the proven bijective
    transport `renameNF_eval_iff` (NfDepth0Generalized.lean:440) with the `Fin 5` cyclic shift. -/
theorem kvE_anchorBridge {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    {k : Nat} (env : Fin 4 → M.carrier) (p : M.carrier) (s : NormalForm sig k 5) :
    NfEvalNf M k 5 (insertEnv env p) (renameNF rot5Fwd rot5Bwd s) ↔
      NfEvalNf M k 5 (Fin.cons p env) s :=
  renameNF_eval_iff M rot5Fwd rot5Bwd (Fin.cons p env) (insertEnv env p)
    (rot5_comp env p) (rot5_comp2 env p) rot5_sec rot5_sec2 s

/-- **Shared clause-content primitive** (H7 side-symmetric): render each fiber sub under the anchor
    shift (`renameNF rot5Fwd rot5Bwd`) before the `P.existF 4` endpoint fold. Both Future and Past
    gap/ray content route through this. Rabinovich Def 7.5 recursive rung entry rendering. -/
noncomputable def kvEFiberPosOnShift {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (l : List (NormalForm sig k 5)) : Formula :=
  kvEFiberPosOn P (l.map (renameNF rot5Fwd rot5Bwd))

/-- **Shared correctness contract** (H7 side-symmetric; the exact obligation both
`_sound`/`_complete`
    reduce their content half to): the shifted channel holds at `p` IFF some listed fiber sub is
    realized with `p` as the FRESH (index-0) fold witness — EXACTLY σ's fold-layer shape
    (`NfEvalEfoldK`, NfEFold.lean:608). The existential `env` is the faithful target: Rabinovich
    Lemma 5.3 (chunk_0014) existentially quantifies the deeper rung's interior points `∃x1…∃xn`.
    Proven by rewriting through `kvE_fiberPosOn_correct` then the bridge `kvE_anchorBridge`. -/
theorem kvE_fiberPosOnShift_correct {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (l : List (NormalForm sig k 5))
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (p : M.carrier) :
    TemporalTruth M atomMap p (kvEFiberPosOnShift P l) ↔
      ∃ s ∈ l, ∃ env : Fin 4 → M.carrier, NfEvalNf M k 5 (Fin.cons p env) s := by
  rw [kvEFiberPosOnShift, kvE_fiberPosOn_correct P _ M h_UZ h_SZ p]
  constructor
  · rintro ⟨s', hs'mem, env, hev⟩
    obtain ⟨s, hsl, rfl⟩ := List.mem_map.mp hs'mem
    exact ⟨s, hsl, env, (kvE_anchorBridge M env p s).mp hev⟩
  · rintro ⟨s, hsl, env, hev⟩
    exact ⟨renameNF rot5Fwd rot5Bwd s, List.mem_map.mpr ⟨s, hsl, rfl⟩, env,
      (kvE_anchorBridge M env p s).mpr hev⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
