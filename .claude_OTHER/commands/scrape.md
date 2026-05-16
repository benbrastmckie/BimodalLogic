---
description: Extract annotations and comments from PDF files
allowed-tools: Skill, Bash(date:*), Bash(od:*), Bash(tr:*), Bash(test:*), Bash(dirname:*), Bash(basename:*), Read
argument-hint: SOURCE_PDF [OUTPUT_PATH] [--format markdown|json] [--types TYPE,...]
---

# /scrape Command

Extract annotations, highlights, comments, and notes from PDF files by delegating to the scrape skill/agent chain.

## Arguments

- `$1` - Source PDF path (required)
- `$2` - Output file path (optional, defaults to `{basename}_annotations.md`)
- `--format markdown|json` - Output format (optional, default: markdown)
- `--types TYPE,...` - Comma-separated annotation types to extract (optional, default: all)

## Usage Examples

```bash
# Extract all annotations (output inferred)
/scrape document.pdf                              # -> document_annotations.md

# Extract to explicit output path
/scrape paper.pdf notes/paper-highlights.md       # -> notes/paper-highlights.md

# Extract as JSON
/scrape document.pdf --format json                # -> document_annotations.json (inferred)

# Extract only highlights and comments
/scrape document.pdf --types highlights,comments  # -> document_annotations.md

# Full options
/scrape document.pdf output.md --format markdown --types highlights,comments,notes

# Absolute paths
/scrape /path/to/file.pdf /output/dir/annotations.md
```

## Supported Annotation Types

| Type | Description |
|------|-------------|
| highlights | Highlighted text passages |
| comments | Inline comments attached to text |
| notes | Sticky note annotations |
| bookmarks | Named bookmarks and destinations |
| drawings | Ink/drawing annotations |

**Note**: Available types depend on what the PDF contains and the extraction tool available.

## Execution

### CHECKPOINT 1: GATE IN

1. **Generate Session ID**
   ```bash
   session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```

2. **Parse Arguments**
   ```bash
   source_path=""
   output_path=""
   output_format="markdown"
   annotation_types='[]'

   while [[ $# -gt 0 ]]; do
     case "$1" in
       --format) output_format="$2"; shift 2 ;;
       --types)
         IFS=',' read -ra types <<< "$2"
         annotation_types=$(printf '"%s",' "${types[@]}" | sed 's/,$//')
         annotation_types="[$annotation_types]"
         shift 2 ;;
       *) if [ -z "$source_path" ]; then source_path="$1"; else output_path="$1"; fi; shift ;;
     esac
   done

   # Validate source path provided
   if [ -z "$source_path" ]; then
     echo "Error: Source PDF path required"
     echo "Usage: /scrape SOURCE_PDF [OUTPUT_PATH] [--format markdown|json] [--types TYPE,...]"
     exit 1
   fi

   # Convert to absolute path if relative
   if [[ "$source_path" != /* ]]; then
     source_path="$(pwd)/$source_path"
   fi
   ```

3. **Validate Source is a PDF**
   ```bash
   if [[ "${source_path##*.}" != "pdf" ]]; then
     echo "Error: Source must be a .pdf file: $source_path"
     exit 1
   fi
   ```

4. **Validate Source File Exists**
   ```bash
   if [ ! -f "$source_path" ]; then
     echo "Error: PDF file not found: $source_path"
     exit 1
   fi
   ```

5. **Determine Output Path** (if not provided)
   ```bash
   if [ -z "$output_path" ]; then
     source_dir=$(dirname "$source_path")
     source_base=$(basename "$source_path" .pdf)

     case "$output_format" in
       json) output_path="${source_dir}/${source_base}_annotations.json" ;;
       *) output_path="${source_dir}/${source_base}_annotations.md" ;;
     esac
   fi

   # Convert output to absolute path if relative
   if [[ "$output_path" != /* ]]; then
     output_path="$(pwd)/$output_path"
   fi
   ```

**ABORT** if source file does not exist or is not a .pdf file.

**On GATE IN success**: Arguments validated. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Invoke the Skill tool NOW** with:
```
skill: "skill-scrape"
args: "pdf_path={source_path} output_path={output_path} output_format={output_format} annotation_types={annotation_types} session_id={session_id}"
```

The skill will spawn the scrape-agent, which extracts annotations from the PDF and writes structured output.

**On DELEGATE success**: Extraction attempted. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Required fields: status, summary, artifacts

2. **Verify Output File Exists**
   ```bash
   if [ ! -f "$output_path" ]; then
     echo "Warning: Output file not created"
     # Return skill error details
   fi
   ```

3. **Verify Output Non-Empty**
   ```bash
   if [ ! -s "$output_path" ]; then
     echo "Warning: Output file is empty — PDF may contain no annotations"
   fi
   ```

**On GATE OUT success**: Output verified.

### CHECKPOINT 3: COMMIT

Git commit is **optional** for standalone extractions.

Only commit if:
- User explicitly requests it
- Extraction is part of a task workflow

```bash
# Only if commit requested
git add "$output_path"
git commit -m "$(cat <<'EOF'
scrape: extract annotations from {source_filename}

Session: {session_id}

EOF
)"
```

Commit failure is non-blocking (log and continue).

## Output

**Success**:
```
Extraction complete!

Source:      {source_path}
Output:      {output_path}
Annotations: {annotation_count} ({breakdown from metadata})
Format:      {output_format}

Status: scraped
```

**Empty (no annotations)**:
```
Extraction completed — no annotations found.

Source: {source_path}
Output: {output_path}

The PDF may not contain any annotations, or the annotations
may use an unsupported format.

Status: scraped
```

**Partial**:
```
Extraction completed with warnings.

Source:      {source_path}
Output:      {output_path}
Warning:     Some annotation types could not be extracted.

Status: partial
```

**Failed**:
```
Extraction failed.

Source: {source_path}
Error:  {error_message}

Recommendation: {recommendation from error}
```

## Error Handling

### GATE IN Failure

**Source not found**:
```
Error: PDF file not found: {path}

Please verify the file path and try again.
```

**Not a PDF**:
```
Error: Source must be a .pdf file: {path}

The /scrape command only supports PDF files.
For other document types, use /convert.
```

**No source provided**:
```
Error: Source PDF path required.

Usage: /scrape SOURCE_PDF [OUTPUT_PATH] [--format markdown|json] [--types TYPE,...]

Examples:
  /scrape document.pdf
  /scrape paper.pdf notes.md --format markdown
  /scrape report.pdf --types highlights,comments
```

### DELEGATE Failure

**Tool not available**:
```
Error: No PDF annotation extraction tools available.

Required tools (install one):
  - pdfannots: pip install pdfannots
  - PyMuPDF:   pip install pymupdf

Then retry: /scrape {source_path}
```

**Extraction error**:
```
Error: Annotation extraction failed.

Details: {error_message from agent}
Recommendation: {recommendation from agent}
```

### GATE OUT Failure

**Output not created**:
```
Warning: Output file was not created.

The extraction tool may have failed silently.
Check the PDF for issues (encrypted, corrupted, no annotations, etc.)
```

**Output empty**:
```
Warning: Output file is empty.

The PDF contains no annotations of the requested types.
Use --types to specify different annotation types, or verify
the PDF was annotated before scraping.
```
