import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterface
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold

/-! # Depth-`k` full-fiber content channel (task 352, Phase 1.1)

The F2-safe content channel for the depth-`k` clause layer: the truth-bearing content of
every rung-(k+1) clause is a finite disjunction of `P.existF 4` applied DIRECTLY to full
fiber elements `s : NormalForm sig k 5` with `σ.2 s = true` — never a Boolean combination
indexed by the collapsed marginal profile `χ : NormalForm sig k 1` (guard G6; task-352
central design ruling, research Conflict 1).

**Rabinovich fidelity (mapping table rows 1-2)**: the clause entries of the rung-(k+1)
bracket are rung-`k` FORMULAS (Def 7.5, chunk 0021:17; Def 3.1 p.4 + Notation 5.2 p.8 —
entries are formulas of the previous round, never rung-`k` brackets, per the E-verified
resolution-(a) reading of Lemma 7.8). Those formulas are the Def 4.1/7.7 canonical-expansion
images of the fiber elements: `P.existF 4 s` is the E[Σ,TL]-atom rendering of the full-arity
sub `s` (idempotent expansion, chunk 0011:5 / chunk 0022:5), supplied by the canonical
`ExistProviders sig atomMap k` bundle (PriorInterface.lean:38-46) consumed VERBATIM
(postmortem rule 11).

**Why full-fiber (F2 immunity)**: the marginal channels (`kvE_subBit`, `kvE_futAnyBit`,
`kvE_projFreshD` — ExteriorBracketK.lean) read a sub only through its zone spec and its
depth-`k` arity-1 fresh shadow; the F2 counterexample pair (`f2sub1`/`f2sub2`,
RefutationF2.lean:335/339) agrees on BOTH channels yet differs at the full fiber element
`e*` (`f2_estar_in_sub1`/`f2_estar_not_in_sub2`), which is why every marginal construction
collapses (`f2_carrier_eq`, RefutationF2.lean:582). The channel below indexes content by the
full fiber element itself, so the pair separates — machine-checked in the companion probe
module `ExteriorFiberProbeK.lean` (Phase 1.2, the GO/NO-GO gate).

List conventions mirror the frozen `kvE2_futGapList` (ExteriorNegation.lean:890, read-only
template) and the landed `kvE_sepPos` (ExteriorBracketK.lean:183): `Finset.univ.toList`
filtered by the quant-layer bit — a stable-order, nodup, Fintype-backed enumeration.

Purely additive NEW leaf module; no frozen file is touched (postmortem rule 5); the landed
determinacy core is consumed unchanged (postmortem rule 6). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (formula_disjList formula_disjList_iff)

/-! ## The positive-sub fiber of a depth-`(k+1)` arity-4 sub -/

/-- **Positive-sub fiber** of `σ : NormalForm sig (k+1) 4`: the finite (Fintype-backed,
    stable-order, nodup) enumeration of the full-arity depth-`k` subs σ prescribes —
    `{s : NormalForm sig k 5 // σ.2 s = true}` as a list. This is the CONTENT index set of
    the depth-`k` clause layer (G6): clause disjuncts range over these `s` directly, never
    over their marginal shadows. Mirrors `kvE2_futGapList` (ExteriorNegation.lean:890) /
    `kvE_sepPos` (ExteriorBracketK.lean:183). -/
noncomputable def kvE_fiber {sig : MonadicSignature} {k : Nat}
    (σ : NormalForm sig (k + 1) 4) : List (NormalForm sig k 5) :=
  (Finset.univ.toList (α := NormalForm sig k 5)).filter fun s => σ.2 s

/-- Membership unfold for `kvE_fiber`: the fiber enumerates exactly the bit-true subs. -/
theorem kvE_fiber_mem {sig : MonadicSignature} {k : Nat}
    (σ : NormalForm sig (k + 1) 4) (s : NormalForm sig k 5) :
    s ∈ kvE_fiber σ ↔ σ.2 s = true := by
  simp only [kvE_fiber, List.mem_filter, Finset.mem_toList, Finset.mem_univ, true_and]

/-! ## The full-fiber content disjunction -/

/-- **Bucketed content disjunction** over a sub-list `l` of the fiber: the finite
    disjunction of the canonical-expansion images `P.existF 4 s` for `s ∈ l` — the form
    every per-zone clause disjunct of the depth-`k` clause layer consumes (the bucket
    sub-lists are produced by the Phase-2 navigation partition; the CONTENT rendering is
    always `P.existF` on the full element, G6). Def 7.5 entries via Def 4.1/7.7 canonical
    expansion (mapping table rows 1-2). Empty bucket gives `⊥`. -/
noncomputable def kvE_fiberPosOn {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (l : List (NormalForm sig k 5)) : Formula :=
  formula_disjList (l.map (P.existF 4))

/-- **Full-fiber positive content form** of `σ : NormalForm sig (k+1) 4`: the disjunction
    of `P.existF 4 s` over ALL fiber elements of σ — the whole-fiber instance of
    `kvE_fiberPosOn` (content position; G6-compliant by construction). -/
noncomputable def kvE_fiberPos {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (σ : NormalForm sig (k + 1) 4) : Formula :=
  kvE_fiberPosOn P (kvE_fiber σ)

/-! ## UZ/SZ-conditional truth characterizations (via `P.correct 4`) -/

/-- **Bucketed correctness**: on Prior (UZ/SZ) structures, the bucketed disjunction holds
    at `t` iff SOME listed fiber element is realized over an anchor environment ending at
    `t` (`insertEnv env t` — the `P.correct` anchor convention, PriorInterface.lean:41-45).
    Statement shape is `P.correct 4` distributed over `formula_disjList_iff`. -/
theorem kvE_fiberPosOn_correct {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (l : List (NormalForm sig k 5))
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t (kvE_fiberPosOn P l) ↔
      ∃ s ∈ l, ∃ env : Fin 4 → M.carrier,
        nf_eval_nf M k 5 (insertEnv env t) s := by
  rw [kvE_fiberPosOn, formula_disjList_iff]
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
theorem kvE_fiberPos_correct {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (σ : NormalForm sig (k + 1) 4)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) :
    temporal_truth M atomMap t (kvE_fiberPos P σ) ↔
      ∃ s : NormalForm sig k 5, σ.2 s = true ∧
        ∃ env : Fin 4 → M.carrier,
          nf_eval_nf M k 5 (insertEnv env t) s := by
  rw [kvE_fiberPos, kvE_fiberPosOn_correct P (kvE_fiber σ) M h_UZ h_SZ t]
  constructor
  · rintro ⟨s, hmem, henv⟩
    exact ⟨s, (kvE_fiber_mem σ s).mp hmem, henv⟩
  · rintro ⟨s, hbit, henv⟩
    exact ⟨s, (kvE_fiber_mem σ s).mpr hbit, henv⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
