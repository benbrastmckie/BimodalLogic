# Roadmap

## Completeness Architecture

### Known Dead Ends

- **FMP bridge to full completeness**: The sorry-free `fmp_contrapositive` (if phi in every closure MCS then provable) CANNOT bridge to `valid phi -> provable phi` without a truth lemma connecting validity to closure MCS membership. This truth lemma faces the same branching-vs-linear mismatch as the direct canonical model construction. The FMP module is valuable for decidability but does NOT provide a shortcut to completeness.

- **Combined F-seed chain construction**: The multi-target seed `{psi | F(psi) in w} union g_content(w)` is inconsistent in general. G does not distribute over disjunction. Do not attempt.

- **Constant-history canonical models for G/H**: On a constant history (all times map to same world), G(alpha) is semantically identical to alpha. It is structurally impossible to build a constant-history countermodel that distinguishes formulas containing G/H from their temporal-free flattening.

- **Flatten reduction**: `flatten(chi) in w` does not imply `chi in w` when chi contains G/H, because alpha does not imply G(alpha).

- **Enriched-seed / chain-based approaches**: Blocked under reflexive semantics where x_content(M) = M.

### Active Paths

- **USF fragment completeness** (task 86): Proof-theoretic derivation using BX axioms. The `imp` Case B sorry at CanonicalEmbedding.lean:418 is the single remaining blocker. Direct structural argument using temp_k_dist, BX1, temp_4, and derivation machinery.

- **Decidability / FMP**: Sorry-free. Provides finite model property and decidability of the full logic including Until/Since.

- **Fragment completeness**: Sorry-free for temporal-free fragment {atom, bot, imp, box} via `fragment_completeness`.
