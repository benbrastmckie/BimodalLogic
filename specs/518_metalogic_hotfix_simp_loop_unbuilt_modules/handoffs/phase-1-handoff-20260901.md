# Phase 1 handoff — task 518

**Done**: `README.md:167` Dedekind strong-completeness bullet rewritten from "not stated /
unproved" to "**refuted**, like Discrete", naming `strongCompletenessDedekind_refuted` and
`dedekind_consequence_not_compact`, preserving the Reynolds 1992 weak-only remark.
`README.md:240` "(open —" -> "(refuted —".

**Scope hypothesis**: CONFIRMED. `grep -in dedekind README.md` returns 14 hits; only `:167` and
`:239-240` asserted the wrong strong-completeness status.

**Verification note**: the plan's `grep -n -iE 'dedekind.*open|open.*dedekind' README.md` check
still returns `:198` and `:245`. Both are unrelated genuinely-open questions (the paper's BX_c
density-axiom question; closed-form characterizations of `Mod (AxiomSet .Dedekind)`), not
strong-completeness status claims. Left intentionally.

**Next**: Phase 2 (constructor tables in `FormalSystem/README.md`, `FormalSystem/Syntax/README.md`).
