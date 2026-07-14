# Task 358 — G2 supply re-key mapping against task 364's strengthened interface

**Purpose**: The Phase 2 G2 blocker is RESOLVED by task 364 (landed commits
`ca1a40f90..5dbda1905`). This report is the concrete re-key mapping the plan reviser needs — it
is not a re-diagnosis. It maps plan v04 Phase 2 (rows 8–11 / tasks G2-1, G2-2) onto the new
co-realization mate obligation and identifies the byte-stable lemmas that discharge it.

## 1. The new proof obligation (what changed)

`kvE_fiberElemConsistent σ s'` (succ arm, `ExteriorFiberConsistencyK.lean`) now conjoins THREE
things per σ-marked candidate mate `s'`:

```
σ.2 s'                                                    -- (unchanged) s' is σ-marked
&& mergeNF e.atom_assgn ⟨1,_⟩ = s'.atom_assgn            -- (task 363) atom-row match
&& decide (∃ (M : OrderedMonadicStructure sig)           -- (task 364, NEW) joint co-realization
             (env : Fin n → M.carrier) (u : M.carrier),
             nf_eval_nf M (j+2) n env σ ∧
             nf_eval_nf M (j+1) (n+1) (Fin.cons u env) s')
```

The NEW third conjunct is the entire delta. The G2 supply, to prove
`kvE_fiberElemConsistent σ s = true` (and hence `kvE_fiberConsistent σ`, `kvE_futAdmissible σ`),
must now, for each marked mate, exhibit a **joint co-realization witness `⟨M, env, u⟩`** of σ
and the mate in one model. This is a *realizability* obligation, NOT a fresh-projection content
payload. It is precisely what the σ₂ planted mate (`.2 = fun _ => false`, unrealizable) cannot
supply — the plant is now rejected at all three guard levels
(`kvE_probe364_sigma2_{sstar_inconsistent, slice_inconsistent, inadmissible}`).

## 2. Byte-stable discharge lemmas (route through these; never unfold the guard body)

All three have unchanged statements/signatures (task 364 re-proved bodies only):

| Lemma | Location | Statement (discharge shape) |
|-------|----------|-----------------------------|
| `kvE_fiberElemConsistent_of_realized` | `ExteriorFiberConsistencyK.lean:149` | `(M) (env) (xs) (σ) (s) → nf_eval_nf M (k+1) n env σ → nf_eval_nf M k (n+1) (Fin.cons xs env) s → kvE_fiberElemConsistent σ s = true` |
| `kvE_fiberConsistent_of_realized` | `ExteriorFiberConsistencyK.lean:238` | fiber-level analogue: a realizer of σ makes `kvE_fiberConsistent σ = true` |
| `kvE_futRealizer_admissible` | `ExteriorNegationK.lean:131` | `(M) (σ : NF (k+1) 4) (x1 w x t) (hxw:x<w)(hwt:w<t)(htx1:t<x1) → nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _=>t)))) σ → kvE_futAdmissible σ = true` |

**How the discharge works**: `kvE_fiberElemConsistent_of_realized` (succ arm, lines 159–208)
already constructs the joint co-realization witness internally — it feeds
`⟨M, env, u, hσ, nf_characteristic_satisfies M (j+1) (n+1) _⟩` into the new `decide`-conjunct
(lines 174–183). So a G2 supply proof that has a realizer `hnf : nf_eval_nf M (m+1) n env σ` in
hand gets the whole strengthened guard for free by applying this lemma — it never touches the
guard body. `kvE_futRealizer_admissible` is the top-level entry point: hand it the pinned
4-variable realizer `(x1,w,x,t)` with the strict order chain and it returns
`kvE_futAdmissible σ = true` directly, discharging both the zone-marking and the (now
3-conjunct) on-fiber/consistency legs (see lines 141–160).

## 3. Type-shape / depth-offset notes (no gap, one alignment obligation)

- **Arity is aligned, not offset**: the σ₂ refutation lived at `(k n) = (1, 4)` (m=1
  doppelgänger). `kvE_futRealizer_admissible` is fixed at `n = 4` with the pinned env
  `(x1,w,x,t)` — this is exactly the G2 exterior-slice supply population (4-variable pinned
  realizers), so the supply lemmas plug in without a cast. For general m the recursion is on
  `k` (fiber depth); `_of_realized` is stated `∀ {k n}` and inducts on `k`, so it already covers
  every rung the G2 supply reaches.
- **The only real obligation the supply must now produce**: a realizer term
  `nf_eval_nf M (m+1) n env σ` for each honest σ in the admissible population. Under the old
  atom-row-only interface the supply could (erroneously) pass a σ with a planted unrealizable
  mate; now it must carry the realizer. For realizer-DERIVED σ's (the actual G2 supply
  population — σ's built from `nf_characteristic`/`kvE_futRealizer_*`), the realizer is already
  in scope, so this is a routing change, not new mathematics.
- **Do NOT unfold `kvE_fiberElemConsistent`**: any proof that `rw [kvE_fiberElemConsistent]` and
  attacks the `decide (∃ …)` conjunct by hand re-opens the plantability surface. Route through
  §2 lemmas exclusively.

## 4. Concrete re-key step list for the plan reviser

Plan v04 Phase 2 rows 8–11 (G2-1 `kvE_{fut,past}SliceId_of_end`, G2-2 `kvE_{fut,past}SliceUnique`):

1. **Unblock the Phase 2 premise.** The v04 blocker note says the premise "every admissible σ is
   fiber-consistent, so `s*`-class fakes are outside the population" is FALSE against the 363
   interface. It is now TRUE against the 364 interface: `kvE_probe364_sigma2_inadmissible`
   proves `kvE_futAdmissible m2sigma = false`, i.e. the `s*`-carrying planted slice is excluded
   from the admissible population at guard level. Restate G2-1 with this as a discharged fact,
   citing `kvE_probe364_sigma2_*` and `kvE_probe364_sstar_honest_unrealizable`.
2. **Re-key G2-1's mate obligation** to route through `kvE_futRealizer_admissible` /
   `kvE_fiberConsistent_of_realized`: the supply constructs the pinned realizer
   `(x1,w,x,t)` for each honest exterior slice and applies the lemma, rather than matching atom
   rows. Add an explicit plan instruction: "never `rw [kvE_fiberElemConsistent]`; the co-realization
   conjunct is discharged only via `_of_realized` / `kvE_futRealizer_admissible`."
3. **G2-2 (`SliceUnique`)** is downstream of G2-1 and was "not attempted"; it re-keys the same
   way — uniqueness now runs against the realizability-anchored population, so the `s*` fake can
   no longer be a second slice witness (it is not admissible). No separate interface obligation.
4. **Fold in the universal engine.** `kvE_probe364_sstar_honest_unrealizable` proves ANY slice
   marking `s*` + one honest fiber is realized in no model. The plan should cite this as the
   closure for the u-class enumeration that the phase-2 handoff left research-scale: no per-class
   mate supply can service any class inside an unrealizable ambient, so the enumeration collapses
   to "σ carries a realizer or it is inadmissible."
5. **Downstream phases 3–6** (four supply theorems, G1 `hexcl`, readback kernel) inherit the
   same routing rule; add a one-line note that they consume the strengthened guard only through
   the §2 lemmas.
6. **Retain the zero-debt / probe-gate contract** from v04 (route R2 machine probe before/after,
   no `sorry`, no vacuous def). The Phase 2 re-probe gate becomes: re-run
   `kvE_probe358_eP_atomMate_present` (still TRUE — atom row present) AND confirm
   `kvE_probe364_sigma2_inadmissible` (guard-level rejection) — the atom row no longer suffices,
   which is the definition of the blocker being closed.

## 5. Frozen-layer confirmation (re-key touches none of them)

The re-key is a routing change in the G2 supply proofs plus lemma citations — it introduces NO
edit to: rung0/rung1 (k≤1 arms), task 360 m=0 supply theorems, `kampPrior_case1_arm_k0`, or the
task 363/364 predicate/guard/probes (all byte-stable). KampPrior's two live sorries (`:519`,
`:522`) stay exactly as-is until the G2/G1 supply lands. Task 364 already verified all five
consumer modules compile against the strengthened guard with zero statement changes, so the
interface surface the re-key builds on is stable.

## Bottom line

The blocker is fully dissolved. The G2 supply's only new obligation is to carry a realizer
`nf_eval_nf M (m+1) n env σ` (free for the realizer-derived supply population) and route the
mate/admissibility discharge through the three byte-stable lemmas in §2 — never unfolding the
guard. Plan v04 needs a revision (→ v05) that (a) marks Phase 2 unblocked citing
`kvE_probe364_sigma2_*`, (b) rewrites G2-1/G2-2 to route through
`kvE_futRealizer_admissible` / `_of_realized`, and (c) propagates the "never unfold the guard"
rule to Phases 3–6. No frozen layer is touched.
