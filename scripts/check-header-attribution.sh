#!/usr/bin/env bash
# Header-attribution checker for this project's Lean sources.
#
# WHY THIS EXISTS: scripts/check-copyright-headers.sh validates header SHAPE and is
# identity-blind -- it never compares the `Authors:` names against anything, so adding a
# contributor passes and omitting one passes equally. The convention in
# docs/development/LEAN_STYLE_GUIDE.md section 4 ("Copyright-Header Authorship") says the
# `Authors:` line names every contributor whose change to the file meets the stated threshold.
# A convention stated only in prose is instruction-dependent; this script is its backstop.
#
# WHAT IT REPORTS -- CANDIDATES, NEVER VERDICTS. This is a limit of the mechanism, not a gap in
# its scope. git records who AUTHORED a commit; it does not record whether that commit merged
# someone else's pull request or materially edited the file. A `(file, identity)` pair reported
# here therefore means "this identity has commits touching this file and is not named on its
# `Authors:` line" -- a question for a human, answered by the threshold in the style guide.
# Reviewing a candidate and declining it is recorded in scripts/header-attribution-baseline.txt,
# and the exit status gates on UNREVIEWED candidates only: a reviewed-and-waived candidate does
# not keep the gate red.
#
# `%aN`, NEVER `%an` -- THE ONE-CHARACTER DETAIL THIS SCRIPT TURNS ON. The git author string for
# this repository's owner is `benbrastmckie`; the header display name is `Benjamin Brast-McKie`.
# They never match. `.mailmap` at the repository root folds the two, and git applies it
# automatically -- but ONLY to the capital-letter placeholders. On git 2.54.0, `%an` is
# mailmap-blind and `--use-mailmap` was measured not to rescue it; `%aN` is folded. Substituting
# `%an` below flags essentially every headed file in the tree, which is indistinguishable from no
# check at all. (Measured: `git log --no-merges --format='%aN' | sort -u` yields the three display
# names, `%an` still yields `benbrastmckie`.)
#
# EXCLUSION SET, STATED DELIBERATELY. `.mailmap` can rename and merge identities but has no
# "drop" form by construction, so an identity that earns no `Authors:` entry at all cannot be
# expressed there. `Claude <noreply@anthropic.com>` has 46 commits in this repository and is not
# a contributor the headers name; it is excluded here, in code. Grounds for the set being exactly
# that one name: a survey of every distinct `Co-Authored-By` trailer value in the history returns
# 16 values, every one a Claude model variant or `OpenCode`, and no human third party.
# STATED LIMIT: `%aN` does not surface trailers at all, so a future human co-author contributed
# ONLY by a `Co-Authored-By` trailer -- never as a commit author -- would be missed by this check
# entirely. That is a known hole, not an oversight; re-run the trailer survey when it matters:
#   git log --no-merges --format='%(trailers:key=Co-authored-by,valueonly)' | sort -u
#
# IMPORT-ONLY PRE-FILTER. A committer whose entire `+`/`-` footprint on a file -- across every
# one of that committer's commits on it -- consists of `import` lines and blank lines does not
# earn attribution, per the style guide's threshold. This is a RULE, deliberately preferred over
# an enumerated list of exempt filenames: it clears the library's barrel roots without naming
# them, and keeps clearing them as the tree changes. Do NOT replace it with a filename list, and
# do NOT justify a barrel root's exemption by claiming its body is nothing but imports -- that
# claim is measured false (the four barrel roots carry 27 / 73 / 79 / 297 non-import body lines).
#
# PERFORMANCE: the per-file committer sets come from ONE `git log --name-only` pass over the
# roots, not a `git log` per file. A per-file loop was measured at over two minutes against 0.8 s
# for the single pass. Only the handful of pairs that survive to candidacy pay a `git show`.
#
# Usage:
#   check-header-attribution.sh [ROOT ...]        # report candidates + write bucket lists
#   check-header-attribution.sh --strict [ROOT..] # additionally exit 1 on unreviewed candidates
#   check-header-attribution.sh --exclude GLOB    # skip paths matching GLOB (repeatable)
#
# ROOTS defaults to ("FormalSystem"), matching its sibling. HAZARD, same as the sibling's: the
# default covers one of the four headed trees, so a bare invocation is NOT a whole-tree check.
# The CI step and scripts/verify-all.sh name their roots explicitly. Unlike the sibling, this
# script needs no `--exclude '*/Boneyard/*'`: Boneyard/ is a TOP-LEVEL directory outside all four
# roots and matches nothing under them.
#
# Bucket lists are written to $OUTDIR (default: a mktemp dir, path echoed at the end).
set -uo pipefail

BASELINE="${BASELINE:-scripts/header-attribution-baseline.txt}"
# Identities that never earn an `Authors:` entry. See EXCLUSION SET above.
EXCLUDED_IDENTITIES=("Claude")
# Set AUTHOR_FORMAT=%an to run the mailmap-blind control documented above. Never in a gate.
AUTHOR_FORMAT="${AUTHOR_FORMAT:-%aN}"

STRICT=0
ROOTS=()
EXCLUDES=()
want_exclude=0
for a in "$@"; do
  if [ "$want_exclude" = 1 ]; then EXCLUDES+=("$a"); want_exclude=0; continue; fi
  case "$a" in
    --strict) STRICT=1 ;;
    --exclude) want_exclude=1 ;;
    --exclude=*) EXCLUDES+=("${a#--exclude=}") ;;
    *) ROOTS+=("$a") ;;
  esac
done
if [ "$want_exclude" = 1 ]; then
  echo "error: --exclude requires a PATTERN argument" >&2
  exit 2
fi
[ "${#ROOTS[@]}" -eq 0 ] && ROOTS=("FormalSystem")

FIND_ARGS=()
for pat in ${EXCLUDES+"${EXCLUDES[@]}"}; do
  FIND_ARGS+=(! -path "$pat")
done

OUTDIR="${OUTDIR:-$(mktemp -d)}"
mkdir -p "$OUTDIR"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
: >"$OUTDIR/clean.txt"
: >"$OUTDIR/candidates.txt"
: >"$OUTDIR/waived.txt"
: >"$OUTDIR/unheaded.txt"

# ---------------------------------------------------------------------------------------------
# 1. The file set, and each headed file's `Authors:` name set.
#    A file is "headed" iff line 4 is an `Authors:` line. Everything else is reported as
#    unheaded and is not a candidate -- shape is its sibling script's job, not this one's.
# ---------------------------------------------------------------------------------------------
find "${ROOTS[@]}" ${FIND_ARGS+"${FIND_ARGS[@]}"} -name '*.lean' -type f | sort >"$WORK/files.txt"

headed=0; unheaded=0
: >"$WORK/headed.txt"
: >"$WORK/authors.tsv"
: >"$WORK/stamp.tsv"
while IFS= read -r f; do
  line4=$(sed -n 4p "$f")
  case "$line4" in
    "Authors: "*) ;;
    *) unheaded=$((unheaded+1)); echo "$f" >>"$OUTDIR/unheaded.txt"; continue ;;
  esac
  headed=$((headed+1))
  printf '%s\n' "$f" >>"$WORK/headed.txt"
  # The names: line 4 after `Authors: `, plus any continuation lines up to the closing `-/`.
  # The STAMP a baseline row pins must cover exactly the same span the names are read from,
  # or a waiver survives an edit that changed its name set: with the stamp pinned to line 4
  # alone, removing a name from a continuation line left line 4 byte-identical and kept the
  # row grandfathered. Both are accumulated in one pass below so they cannot drift apart.
  # For a single-line header the stamp is line 4 verbatim, so every existing baseline row
  # keeps matching (measured: 1007 headed files, 0 using the continuation form).
  names="${line4#Authors: }"
  stamp="$line4"
  for n in 5 6 7 8 9 10 11 12; do
    ln=$(sed -n "${n}p" "$f")
    [ "$ln" = "-/" ] && break
    names="$names $ln"
    stamp="$stamp $ln"
  done
  printf '%s\t%s\n' "$f" "$stamp" >>"$WORK/stamp.tsv"
  printf '%s\n' "$names" | tr ',' '\n' | while IFS= read -r nm; do
    nm="${nm#"${nm%%[![:space:]]*}"}"
    nm="${nm%"${nm##*[![:space:]]}"}"
    [ -n "$nm" ] && printf '%s\t%s\n' "$f" "$nm"
  done >>"$WORK/authors.tsv"
done <"$WORK/files.txt"

# ---------------------------------------------------------------------------------------------
# 2. One git log pass: every (path, identity, sha) triple touching a `.lean` file under ROOTS.
# ---------------------------------------------------------------------------------------------
git log --no-merges --format="%x01%H%x09${AUTHOR_FORMAT}" --name-only -- "${ROOTS[@]}" \
  | awk -F'\t' -v OFS='\t' '
      /^\001/ { sha = substr($1, 2); who = $2; next }
      /\.lean$/ { print $0, who, sha }
    ' >"$WORK/triples.tsv"

# ---------------------------------------------------------------------------------------------
# 3. Candidate pairs: a (headed file, identity) pair where the identity is not excluded and is
#    not named on the file's `Authors:` line.
# ---------------------------------------------------------------------------------------------
printf '%s\n' ${EXCLUDED_IDENTITIES+"${EXCLUDED_IDENTITIES[@]}"} >"$WORK/excluded.txt"
awk -F'\t' -v OFS='\t' '
    FILENAME == ARGV[1] { excl[$0] = 1; next }
    FILENAME == ARGV[2] { headed[$0] = 1; next }
    FILENAME == ARGV[3] { auth[$1 FS $2] = 1; next }
    {
      if (!($1 in headed)) next
      if ($2 in excl) next
      if (($1 FS $2) in auth) next
      key = $1 FS $2
      if (key in shas) { shas[key] = shas[key] " " $3 } else { shas[key] = $3; order[++k] = key }
    }
    END { for (i = 1; i <= k; i++) { split(order[i], p, FS); print p[1], p[2], shas[order[i]] } }
  ' "$WORK/excluded.txt" "$WORK/headed.txt" "$WORK/authors.tsv" "$WORK/triples.tsv" \
  >"$WORK/raw_pairs.tsv"

# ---------------------------------------------------------------------------------------------
# 4. Import-only pre-filter (see the header note). A pair whose whole footprint is import and
#    blank lines is cleared here and never becomes a candidate.
# ---------------------------------------------------------------------------------------------
: >"$WORK/pairs.tsv"
import_only=0
while IFS=$'\t' read -r f who shas; do
  nonimport=0
  for sha in $shas; do
    while IFS= read -r dl; do
      case "$dl" in +++*|---*) continue ;; esac
      body="${dl:1}"
      [ -z "${body//[[:space:]]/}" ] && continue
      case "$body" in import\ *) continue ;; esac
      nonimport=1
      break
    done < <(git show --format='' --unified=0 "$sha" -- "$f" 2>/dev/null | grep -E '^[+-]')
    [ "$nonimport" = 1 ] && break
  done
  if [ "$nonimport" = 0 ]; then
    import_only=$((import_only+1))
    printf 'import-only  %s  [%s]\n' "$f" "$who" >>"$OUTDIR/clean.txt"
  else
    printf '%s\t%s\n' "$f" "$who" >>"$WORK/pairs.tsv"
  fi
done <"$WORK/raw_pairs.tsv"

# ---------------------------------------------------------------------------------------------
# 5. Waiver lookup. A baseline row grandfathers a pair only while the file's line-4 `Authors:`
#    string still equals the row's recorded stamp, so any later header change un-grandfathers it.
# ---------------------------------------------------------------------------------------------
: >"$WORK/baseline.tsv"
if [ -f "$BASELINE" ]; then
  grep -v '^[[:space:]]*#' "$BASELINE" | grep -v '^[[:space:]]*$' \
    | awk -F'|' -v OFS='\t' 'NF >= 3 {
        p = $1; i = $2; s = $3
        gsub(/^[ \t]+|[ \t]+$/, "", p); gsub(/^[ \t]+|[ \t]+$/, "", i); gsub(/^[ \t]+|[ \t]+$/, "", s)
        print p, i, s
      }' >"$WORK/baseline.tsv"
fi

unreviewed=0; waived=0; stale_rows=0
while IFS=$'\t' read -r f who; do
  stamp_now=$(awk -F'\t' -v f="$f" '$1 == f { print $2 }' "$WORK/stamp.tsv")
  row_stamp=$(awk -F'\t' -v f="$f" -v w="$who" '$1 == f && $2 == w { print $3 }' "$WORK/baseline.tsv")
  if [ -n "$row_stamp" ] && [ "$row_stamp" = "$stamp_now" ]; then
    waived=$((waived+1))
    printf 'waived       %s  [%s]  stamp matches baseline\n' "$f" "$who" >>"$OUTDIR/waived.txt"
  elif [ -n "$row_stamp" ]; then
    stale_rows=$((stale_rows+1))
    unreviewed=$((unreviewed+1))
    printf 'CANDIDATE    %s  [%s]  (baseline row un-grandfathered: header changed since review)\n' \
      "$f" "$who" >>"$OUTDIR/candidates.txt"
  else
    unreviewed=$((unreviewed+1))
    printf 'CANDIDATE    %s  [%s]\n' "$f" "$who" >>"$OUTDIR/candidates.txt"
  fi
done <"$WORK/pairs.tsv"

# A headed file with no surviving candidate pair is clean.
awk -F'\t' '
    FILENAME == ARGV[1] { flagged[$1] = 1; next }
    { if (!($0 in flagged)) print "clean        " $0 }
  ' "$WORK/pairs.tsv" "$WORK/headed.txt" >>"$OUTDIR/clean.txt"
clean_files=$(grep -c '^clean        ' "$OUTDIR/clean.txt" || true)

printf 'roots         : %s\n' "${ROOTS[*]}"
printf 'excludes      : %s\n' "${EXCLUDES[*]:-(none)}"
printf 'author format : %s%s\n' "$AUTHOR_FORMAT" \
  "$([ "$AUTHOR_FORMAT" = '%aN' ] || printf '  <-- NOT mailmap-folded; control run only')"
printf 'identities not earning attribution: %s\n' "${EXCLUDED_IDENTITIES[*]}"
printf 'headed files  : %d\n' "$headed"
printf 'unheaded      : %d  (shape is check-copyright-headers.sh'"'"'s job, not this one'"'"'s)\n' "$unheaded"
printf 'clean files   : %d\n' "$clean_files"
printf 'import-only cleared pairs : %d\n' "$import_only"
printf 'waived pairs  : %d  (reviewed, recorded in %s)\n' "$waived" "$BASELINE"
printf 'unreviewed candidate pairs: %d\n' "$unreviewed"
[ "$stale_rows" -gt 0 ] && printf '  of which un-grandfathered baseline rows: %d\n' "$stale_rows"
printf 'lists         : %s\n' "$OUTDIR"

if [ "$unreviewed" -gt 0 ]; then
  echo
  echo "Attribution CANDIDATES (not verdicts -- git cannot tell a merger from an editor):"
  cat "$OUTDIR/candidates.txt"
  echo
  echo "Judge each against the threshold in docs/development/LEAN_STYLE_GUIDE.md section 4."
  echo "Either append the name to the file's 'Authors:' line, or record a reviewed waiver row in"
  echo "$BASELINE."
fi

if [ "$STRICT" = 1 ] && [ "$unreviewed" -gt 0 ]; then
  exit 1
fi
exit 0
