# v35 Phase 1 — `mergeNF_succ` attempt 2 (STRIKE 2 of 3; build GREEN preserved)

- **Task**: 305 (lean4, hard mode)
- **Plan**: plans/35_zone-split-gated.md, Phase 1
- **Route**: A (committed in v35-gate-decision.md)
- **Date**: 2026-06-24
- **H6 three-strikes**: this is **strike 2** on the `mergeNF_succ`/`renameNF` leaf.
- **Outcome**: the strike-1 retraction-functor plan was implemented and **proven sorry-free**,
  but it is **structurally insufficient for the merge** — for a precise, now-conclusive reason.
  Stopped cleanly per H6 (no thrash). Build GREEN; 0 `.lean` files changed; baseline unchanged.

## What was attempted (the committed strike-2 plan)

The strike-1 handoff's recommended encoding (1): a **retraction-carrying** `renameNF`
functor on `NormalForm sig k m`, recursing through the contravariant quant layer via
`liftIdx` of *both* a forward map `f : Fin b → Fin a` and a retraction `r : Fin a → Fin b`,
then specialize `f = skipFin j`, `r = unskipFin j` totalized (dropped `j ↦ i`) to derive
`mergeNF_succ` / `merge_forward_succ`.

This was carried out **in full and compiles sorry-free / axiom-free**. The proven artifacts
(preserved verbatim in `handoffs/v35-phase-1-strike-2-renameNF-proven.lean.txt`):

- `liftIdx` (lift an index map fixing position 0 — the `Fin.cons` bound variable),
  `liftIdx_zero`, `liftIdx_succ`, `cons_comp_liftIdx`, `liftIdx_comp`, `liftIdx_id`.
- `renameNF (f : Fin b → Fin a) (r : Fin a → Fin b) : NormalForm sig k a → NormalForm sig k b`,
  with the **key new idea** the strike-1 plan was missing: on order atoms whose `f`-images
  **collide** (`f i = f j`), return `false` (the two positions are forced equal, so order is
  false). This makes precomposition TOTAL along non-injective maps — type-checks at the quant
  layer where strike-1 stalled.
- `renameNF_roundtrip` (`renameNF r f (renameNF f r nf) = nf`) by induction on `k`, under
  BOTH section identities.
- `renameNF_eval_iff` — the full bidirectional semantic congruence, by induction on `k`:
  ```
  nf_eval_nf M k b e (renameNF f r nf) ↔ nf_eval_nf M k a E nf
  ```
  under env-compatibility `e = E ∘ f`, `E = e ∘ r`, and **both** sections `f ∘ r = id`,
  `r ∘ f = id`.

## Precise, conclusive obstacle (sharpens strike-1 Obstacle 2 to a closed verdict)

`renameNF_eval_iff` **requires the two index maps to be mutually inverse (bijective):
both `f ∘ r = id` (`hsec`) AND `r ∘ f = id` (`hsec2`).** This is not an artifact of the proof —
it is forced by the structure:

- The quant layer is **contravariant**, so the induction recurses by **swapping**
  `(f, r) → (liftIdx r, liftIdx f)`. Each direction of the iff therefore consumes one section
  identity at the atom level and the *other* (via `renameNF_roundtrip`) at the quant level.
  Both sections are mandatory at the top level.
- Mathematically: the quant clauses `∀ qnf …` on the two sides range over NF types at
  *different* arities (`b+1` vs `a+1`). Their universal quantifiers correspond **only** if the
  rename map `renameNF (liftIdx r)(liftIdx f) : NormalForm k (b+1) → NormalForm k (a+1)` is a
  **bijection** — i.e. only if the underlying index map is bijective.

**The merge map is not bijective.** `f = skipFin j` is injective-not-surjective: it satisfies
`r ∘ f = id` (`unskipFin_skipFin`, already in NfDepth0Generalized.lean) but **violates
`f ∘ r = id` at the dropped position `j`** (`skipFin j (totalUnskip j i ↦ i₀) = i₀ ≠ j`).
Hence `renameNF_eval_iff` **cannot be instantiated for the merge**, and neither can any
single-direction specialization of it: the direction `merge_forward` needs
(merged-satisfied → original-satisfied = the `mp` direction) is exactly the one whose quant
layer invokes `renameNF_roundtrip`, which needs the missing section `f ∘ r = id`.

**Verdict (closes the question for the syntactic route):** BOTH syntactic NF-precomposition
encodings — strike-1's plain functor AND strike-2's retraction-carrying functor — are
**structurally insufficient** for a (non-bijective) position merge. The functor congruence is
a clean, reusable lemma for **bijective** renamings (permutations) at arbitrary depth, but the
merge is not a bijection.

## What the merge actually needs (concrete strike-3 plan)

The merge's surviving (dropped) position `j` must be handled by the **bespoke value-duplication
argument**, exactly as the sorry-free depth-0 `merge_forward` (NfDepth0Generalized.lean:168)
already does — using the merge-compatibility hypotheses `h_pred` / `h_ord` at `j` — but now
**lifted through the quant layer**, NOT routed through a generic `renameNF` congruence.

Concretely, `merge_forward_succ` (depth `k+1`, arity `n+2 → n+1`, drop `j`, twin `i`):
1. Build the duplicating env `full_val` / `env_new` (value at `j` := value at `i`) — identical
   to depth-0 `merge_forward` (lines 187–293). Atom layer of the conclusion is discharged by
   the **same** `h_transfer_pred` / `h_transfer_order` reasoning (reuse depth-0 verbatim).
2. For the **quant layer**, prove the clause
   `∀ qnf : NormalForm k (n+3), (∃ x, nf_eval_nf M k (n+3) (Fin.cons x (insertEnv env_new t)) qnf)
     ↔ sub_nf.2 qnf`
   from `h_merged`'s clause
   `∀ qnf', (∃ x, nf_eval_nf M k (n+2) (Fin.cons x (insertEnv env' t)) qnf') ↔ sub_nf.2 (renameNF … qnf')`
   by a **value-duplication congruence at depth k**: two consed envs that duplicate `i`'s value
   at `j` induce the same existential-satisfaction on the corresponding NFs. The reusable,
   PROVABLE half of `renameNF_eval_iff` for this is the **backward (`mpr`) direction**, which
   needs only `r ∘ f = id` (`hsec2`, which the merge HAS). The remaining gap is connecting an
   arbitrary `qnf : NormalForm k (n+3)` on the duplicated env to a merged `qnf'` — and on the
   compatible subspace this is where `h_pred`/`h_ord` (lifted to the quant layer) supply
   surjectivity-up-to-compatibility. This is genuine new content (~120–200 lines), the true
   make-or-break leaf — it is NOT a quick close, which is why strike 2 stops here cleanly
   rather than thrash a third encoding inside the same dispatch.

Strike 3 should: (a) recover the proven `renameNF` + `renameNF_eval_iff` block from
`v35-phase-1-strike-2-renameNF-proven.lean.txt` (use its `mpr` direction for the
bijection-free half), (b) build the value-duplication quant congruence using `h_pred`/`h_ord`,
mirroring depth-0 `merge_forward`. If strike 3 also fails: this is the **3rd strike** on the
leaf — STOP and re-run the Phase 0 gate (per plan Rollback/Contingency), do NOT reopen
Approach-5.

## H6 ledger
- Overturns nothing. Converts strike-1's open Obstacle 2 ("needs a retraction") into a
  **closed negative result**: the retraction functor is provably insufficient because the merge
  is non-bijective; the bijectivity requirement is intrinsic to the contravariant quant layer.
- Forbidden paths (Approach-5 pair-formula, mutual char/exist, k+2 NF-disjunction) NOT touched.
- Descend-only invariant respected throughout (all recursion strictly at depth `k`).
- One leaf only (`mergeNF_succ`); no leaf-switching.

## Verification at this boundary
- `lake build`: **GREEN (1700 jobs)** — 0 `.lean` files modified (`git status` shows only
  `specs/state.json`, pre-existing). The proven `renameNF` work lives only in a `.lean.txt`
  reference artifact under `handoffs/`, not in the build path.
- `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete`:
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
  — **unchanged; no new axioms**.
- Baseline sorries: KampPrior.lean:391, :394 both present (unchanged). No new sorries.
- Zero top-level `axiom` declarations in the build path (the 2 `^axiom ` grep hits are comments
  in Boneyard files).
