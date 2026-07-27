#!/usr/bin/env python3
"""Phase 5.2: derive ONE target name per declaration, from all three dimensions at once.

Order is fixed and must not be reversed: **semantic substitution first, casing second**.
Deriving names during the rewrite instead of here defeats the whole point of a derive-once
table (postmortem constraint 10).

Two input sets, unioned:

  * the 855 linter-flagged declarations (`target-names/flagged-names.txt`), each carrying a
    result-type category from `target-names/categories.tsv`;
  * the Part C semantic targets, which are NOT linter-flagged -- `ecq`, `raa`, `efq`, `lce`,
    `rce`, `ldi`, `rdi`, `rcp`, `lem`, `dni` contain no underscore, so `defsWithUnderscore`
    never sees them. They still need renaming, for meaning rather than for casing.

Outputs `target-names/target-names.tsv` (machine-readable, consumed by Phase 6) and
`target-names/README.md` (human-reviewable).
"""
import csv
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ilean import REPO, iter_ileans, parse_key  # noqa: E402

DIR = REPO / "specs/402_systematic_mathlib_naming_upgrade/target-names"

# --- Part C semantic word map -------------------------------------------------
# Exact final-component substitutions. Each replacement is itself snake_case and is then
# re-cased by the casing rule below -- that composition is the trap the task description
# names: `ecq` must end up `botOfAndNeg`, NOT `bot_of_and_neg`.
EXACT = {
    "ecq": "bot_of_and_neg",
    "raa": "imp_neg_imp",
    "efq": "neg_imp",
    "efq_neg": "imp_of_neg",
    "lce": "and_left",
    "rce": "and_right",
    "ldi": "or_inl",
    "rdi": "or_inr",
    "rcp": "imp_of_neg_imp_neg",
    "lem": "em",
    "dni": "not_not_intro",
    "dd_countermodel_chronicle_discrete": "countermodel_chronicle_discrete",
    "dd_countermodel_chronicle_mixed_sorry": "countermodel_chronicle_mixed",
}
PREFIX = [("temp_", "temporal_")]

# --- explicit collision resolutions ------------------------------------------
# The plan requires an irreducible collision be resolved IN THE TABLE, before Phase 6, never
# during the rewrite (amending a name mid-rewrite violates the single-snapshot constraint).
# Both entries below were surfaced by the collision audit, not anticipated.
OVERRIDE = {
    # `applyModusPonens` is already taken, in the same namespace, by the forward-search
    # function at Automation/ForwardProofGenerator.lean:234. This one is the
    # `@[aesop safe apply]` rule at Automation/AesopRules.lean:222 -- a different thing.
    "FormalSystem.Automation.apply_modus_ponens": "applyModusPonensRule",
    # `RDefinableGap` is already taken, seven lines below this predicate, by the SUBTYPE that
    # bundles it (EFGames/Defs.lean:333). Mathlib names the predicate `Is…` and reserves the
    # bare name for the bundled structure.
    "FormalSystem.Metalogic.WeakCanonical.r_definable_gap": "IsRDefinableGap",
}

# Declarations to leave alone: established abbreviations with formal definitions (plan
# Non-Goals), plus anything the rewriter structurally cannot reach.
KEEP_WORDS = {"MCS", "FMCS", "BFMCS"}


def semantic(final):
    """Step 1: substitute meaning. Returns (new_final, note)."""
    if final in EXACT:
        return EXACT[final], f"`{final}` -> `{EXACT[final]}`"
    for old, new in PREFIX:
        if final.startswith(old):
            return new + final[len(old):], f"`{old}` -> `{new}`"
    return final, ""


def camel(final, upper):
    """Step 2: Mathlib casing. `upper=True` -> UpperCamelCase, else lowerCamelCase."""
    # a trailing prime is part of the name and survives casing
    primes = ""
    while final.endswith("'"):
        primes = "'" + primes
        final = final[:-1]
    parts = [p for p in final.split("_") if p]
    if not parts:
        return final + primes
    out = []
    for i, p in enumerate(parts):
        if p in KEEP_WORDS:
            out.append(p)
        elif i == 0 and not upper:
            out.append(p[0].lower() + p[1:])
        else:
            out.append(p[0].upper() + p[1:])
    return "".join(out) + primes


def load_categories():
    cats = {}
    with open(DIR / "categories.tsv", encoding="utf-8") as f:
        for row in csv.DictReader(f, delimiter="\t"):
            cats[row["name"]] = (row["category"], row["kind"], row["module"])
    return cats


def load_corpus():
    """All project declarations, plus usage counts, from the `.ilean` snapshot."""
    decls, usages = {}, Counter()
    external = set()
    for _p, data, src in iter_ileans():
        for name, rng in (data.get("decls") or {}).items():
            decls.setdefault(name, (str(src.relative_to(REPO)), rng[0] + 1))
        for key, val in data["references"].items():
            _m, fqn = parse_key(key)
            if not fqn:
                continue
            usages[fqn] += len(val.get("usages") or [])
            if not fqn.startswith(("FormalSystem", "BimodalTest")):
                external.add(fqn)
    return decls, usages, external


def main():
    cats = load_categories()
    decls, usages, external = load_corpus()
    tactic = {l.strip() for l in (DIR / "tactic-declarations.txt").read_text().split("\n") if l.strip()}

    rows = []
    # 1. the linter-flagged set (minus the 18 tactic* declarations, which the rewriter
    #    structurally cannot reach -- they carry no `.ilean` entry at all)
    for name, (cat, kind, mod) in cats.items():
        if name in tactic:
            continue
        rows.append([name, cat, kind, mod, "flagged"])
    # 2. the Part C semantic targets that the linter does NOT flag
    for short in EXACT:
        for n in decls:
            if n.split(".")[-1] == short and n not in cats:
                rows.append([n, "data", "def", "", "partC-only"])

    # Drop auxiliary declarations whose name is DERIVED from a parent that is itself being
    # renamed (`iddfs_search.iterate` is the `where` helper of `iddfs_search`). Lean generates
    # their names from the parent's, so renaming the parent renames them; listing them as
    # independent rows would either be a no-op or corrupt the parent's own span.
    names_in_set = {r[0] for r in rows}
    derived = {n for n in names_in_set
               if any(n.startswith(p + ".") for p in names_in_set if p != n)}
    rows = [r for r in rows if r[0] not in derived]
    print(f"parent-derived rows excluded: {len(derived)}")
    for d in sorted(derived):
        print(f"    {d}")

    out = []
    problems = []
    for name, cat, kind, mod, source in rows:
        ns, final = name.rsplit(".", 1)
        if name in OVERRIDE:
            sem, note, target = final, "collision override", OVERRIDE[name]
        else:
            sem, note = semantic(final)
            upper = cat in ("prop_valued_definition", "sort_or_type")
            target = camel(sem, upper)
        out.append({
            "name": name, "namespace": ns, "old_final": final, "semantic": sem,
            "target": target, "full_target": ns + "." + target, "category": cat,
            "kind": kind, "module": mod, "source": source, "note": note,
            "usages": usages.get(name, 0),
        })
        if "_" in target:
            problems.append(("UNDERSCORE SURVIVED", name, target))

    # --- collision audit ------------------------------------------------------
    renamed_from = {r["name"] for r in out}
    by_target = defaultdict(list)
    for r in out:
        by_target[r["full_target"]].append(r["name"])
    dup = {t: ns for t, ns in by_target.items() if len(ns) > 1}
    # a target that equals an existing declaration NOT itself being renamed away
    survivors = set(decls) - renamed_from
    clash = {r["full_target"]: r["name"] for r in out if r["full_target"] in survivors}
    ext_clash = {r["full_target"]: r["name"] for r in out if r["full_target"] in external}
    # no-op rows: the derivation produced the name it already had
    noop = [r["name"] for r in out if r["target"] == r["old_final"]]

    DIR.joinpath("target-names.tsv").write_text(
        "\n".join(["old_name\ttarget_final\tfull_target\tcategory\tmodule\tusages\tsource"]
                  + [f"{r['name']}\t{r['target']}\t{r['full_target']}\t{r['category']}"
                     f"\t{r['module']}\t{r['usages']}\t{r['source']}" for r in sorted(out, key=lambda r: r["name"])])
        + "\n", encoding="utf-8")
    DIR.joinpath("audit.json").write_text(json.dumps({
        "rows": len(out), "duplicate_targets": dup, "clash_with_survivor": clash,
        "clash_with_external": ext_clash, "noop_rows": noop, "problems": problems,
        "category_counts": dict(Counter(r["category"] for r in out)),
        "source_counts": dict(Counter(r["source"] for r in out)),
    }, indent=1), encoding="utf-8")

    print(f"rows:                    {len(out)}")
    for k, v in Counter(r["source"] for r in out).most_common():
        print(f"  {v:5d}  {k}")
    for k, v in Counter(r["category"] for r in out).most_common():
        print(f"  {v:5d}  {k}")
    print(f"duplicate targets:       {len(dup)}")
    print(f"clash with survivor:     {len(clash)}")
    print(f"clash with external:     {len(ext_clash)}")
    print(f"no-op rows:              {len(noop)}")
    print(f"underscore survived:     {len(problems)}")
    for p in problems[:10]:
        print("   ", p)
    for t, ns in list(dup.items())[:10]:
        print("  DUP:", t, ns)
    for t, n in list(clash.items())[:10]:
        print("  CLASH:", n, "->", t)
    return out


if __name__ == "__main__":
    main()
