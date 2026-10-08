/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.NEquivalence
import FormalSystem.Metalogic.WeakCanonical.MixedSum

/-!
# `k`-type summaries over the `ℤ` time axis — cluster root and step 2

This cluster is **Büchi's complementation chain transposed to monadic `k`-types over the `ℤ`
time axis**. Büchi's proof that ω-regular languages are closed under complement (Thomas 1997,
*Languages, Automata, and Logic*, §5.1, p. 30) colours a pair of positions of an ω-word by the
congruence class of the finite word between them, applies infinite Ramsey for pairs to obtain a
monochromatic monotone cutting sequence, and reads the word off as a member of one family
`[u]·[v]^ω`; saturation — every family lies inside or outside the target language — then makes
the target a finite union of families. The argument, as cslib's own docstring on its
`Cslib.Automata.NA.Buchi.buchiFamily_cover` observes, *"does not depend on any details of the
congruence other than that it is of finite index"*. That is the licence for the transposition
made here: the congruence class of a word is replaced by `kTypeOf sig k (segZ sig c a b)`, the
depth-`k` monadic type of the half-open coloured segment `[a, b)` of a coloured `ℤ`-block, and
the finite-index fact is `kType_finite` below.

The cslib identifiers named in this cluster (`buchiFamily_cover`, `buchiFamily`,
`buchiFamily_saturation`, `IsRegular.fin_cover_saturates_compl`) are cited **as read-only
structural references establishing that the chain is real and which step is which**. Nothing in
this cluster imports, ports, or depends on cslib; the `lakefile.toml` carries no `require` on it.

## The six steps and their owners

Steps are numbered as in Thomas 1997 §5.1; each names Büchi's step, its transposition here, and
the module that owns it.

1. **A finite-index right congruence on finite words** — `KType`, `kTypeOf`, `KEquiv`
   (`NEquivalence.lean`, pre-existing).
2. **The congruence has finite index** — `kType_finite`, this module.
3. **The family `[u]·[v]^ω`**, here bi-infinite as `(τneg)^(ω*) · τzero · (τpos)^ω` —
   `SegmentFactorization`, `InFamily` (`Family.lean`).
3′. **A word *is* the concatenation of its factors** — `kEquiv_zFiber_segSum` (`Segment.lean`).
4. **Ramsey**: colour a pair of positions by the summary of the segment between them and take a
   monochromatic monotone subsequence — `family_cover`, `exists_matching_factorization`
   (`Family.lean`).
5. **Saturation**: each family member is inside or disjoint from the target —
   `kEquiv_zFiber_of_matching_segments`, `kTypeOf_zFiber_eq_of_sameTriple` (`Saturation.lean`)
   and `family_saturation` (`Universal.lean`).
5′. **A finite saturating cover makes the target a finite union of families** —
   `target_eq_union_of_families` (`Universal.lean`).
6. **Conclude decidability** — **out of scope** for this cluster.

The family is bi-infinite because the time axis is `ℤ`: the seam-gluing presentation of a
possible world glues a backward ray to a forward ray at a seam, so the Ramsey step is applied
twice, once per orientation. The Ramsey ingredient itself is `infinite_ramsey_pairs`
(`GroupModel/RamseyFactorization.lean`), an alias of `Nat.exists_strictMono_const_pair_colour`
(`ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`), proved from scratch in this tree because
Mathlib does not carry infinite Ramsey for pairs at pin `v4.33.0-rc1`.

## Why the time axis, and what is not claimed

Summaries live over the **time axis**, with a finite alphabet of per-time segment summaries,
and not over states, because the alternative is refuted:
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`
refutes finite width for the sliced certificate, and the evidence probe
`specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`
(`not_lasso_sufficient_on_chain`) refutes pigeonhole-over-states lasso summaries on the infinite
acyclic fibre `⟨ℤ, b = a - 1⟩`. **No complexity bound is claimed anywhere in this cluster**, and
nothing in it reduces a `⊡` fibre condition to a `k`-type-determined target over the time axis:
that reduction is the MSO-to-ω-regular correspondence, which has no formalization in any proof
assistant, and the consumer-facing seam interface states it as a hypothesis rather than proving
it.

## Main result

* `kType_finite` — step 2: the alphabet of depth-`k` segment summaries is finite.

## References

* [K. Doets, *Monadic $\Pi^1_1$-Theories of $\Pi^1_1$-Properties*][doets1989], Section 1
  (`k`-types and their finiteness)
* [D. M. Gabbay, A. Kurucz, F. Wolter, M. Zakharyaschev, *Many-Dimensional Modal
  Logics*][gabbay2003manyvalued], Theorem 1.28 and Lemma 11.23 (the MSO-over-`⟨ℤ,<⟩`
  quasimodel frame this cluster is the substrate for)
* W. Thomas, *Languages, Automata, and Logic* (Handbook of Formal Languages, vol. 3, 1997),
  §5.1, p. 30 — Büchi's complementation chain, the template transposed here
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

/-! ## Step 2: the summary alphabet is finite -/

/--
**Step 2 of the chain: the alphabet of segment summaries is finite.** A `k`-type is a truth
assignment on the finitely many depth-`k` normal forms (`normalFormFintype`), so there are only
finitely many `k`-types to colour a segment with. This is the one property of the summary that
Büchi's Ramsey step consumes, and it is what licenses replacing his congruence class by
`kTypeOf sig k (segZ sig c a b)`.

Instance search already finds `Finite (KType sig k)` through `KType`'s `abbrev`, so this is
stated as a theorem and carries no `instance` attribute: a second instance would only invite a
diamond. The proof is the one `GroupModel/RamseyFactorization.lean`'s Ramsey cover used inline
before the finite-index fact was given a name of its own. The statement is over
`[Finite sig.preds]`: the `Fintype`/`DecidableEq` instances on `sig.preds` that
`normalFormFintype` is built from are consumed by the proof rather than by the conclusion, so
they are supplied there (`Fintype.ofFinite`, `Classical.decEq`) instead of being demanded by
the binders — the `[Fintype X]` → `[Finite X]` recipe of `docs/development/LEAN_STYLE_GUIDE.md`'s
"Traps" subsection. Every caller in the Ramsey chain carries a `Fintype` instance and finds
`Finite sig.preds` from it by instance search.
-/
theorem kType_finite (sig : MonadicSignature) [Finite sig.preds] (k : ℕ) :
    Finite (KType sig k) := by
  haveI := Fintype.ofFinite sig.preds
  haveI := Classical.decEq sig.preds
  unfold KType
  infer_instance

end FormalSystem.Metalogic.WeakCanonical
