# SuperDoc MCP Integration

SuperDoc is a read-write MCP server for DOCX documents. Unlike markitdown (read-only conversion to Markdown), SuperDoc provides in-place editing, search-and-replace with tracked changes, and document creation.

## MCP Server Configuration

```json
{
  "mcpServers": {
    "superdoc": {
      "command": "npx",
      "args": ["-y", "@superdoc-dev/mcp"],
      "env": {}
    }
  }
}
```

The server runs via npx and requires Node.js 18+. No additional configuration or environment variables are needed.

## Tool Inventory

### Document Lifecycle

| Tool | Signature | Description |
|------|-----------|-------------|
| `open_document` | `open_document(path)` | Open a DOCX file, returns doc_id handle |
| `close_document` | `close_document(doc_id)` | Close and release document handle |
| `save_document` | `save_document(doc_id, path?)` | Save to disk (optional alternate path) |
| `create_document` | `create_document(path)` | Create a new empty DOCX file |

### Content Reading

| Tool | Signature | Description |
|------|-----------|-------------|
| `get_document_text` | `get_document_text(doc_id)` | Read full document text content |

### Content Editing

| Tool | Signature | Description |
|------|-----------|-------------|
| `search_and_replace` | `search_and_replace(doc_id, find, replace)` | Find and replace text |
| `search_and_replace_with_tracked_changes` | `search_and_replace_with_tracked_changes(doc_id, find, replace, author?)` | Find and replace with revision tracking |
| `add_paragraph` | `add_paragraph(doc_id, text, style?)` | Append a paragraph |
| `add_heading` | `add_heading(doc_id, text, level)` | Append a heading (level 1-9) |
| `add_table` | `add_table(doc_id, rows, cols, data?)` | Append a table with optional data |

## Typical Edit Workflow

```
1. doc_id = open_document("/path/to/file.docx")
2. search_and_replace_with_tracked_changes(doc_id, "Old Text", "New Text", "Claude")
3. save_document(doc_id)
4. close_document(doc_id)
```

For document creation:
```
1. doc_id = create_document("/path/to/new.docx")
2. add_heading(doc_id, "Document Title", 1)
3. add_paragraph(doc_id, "Introduction text here.")
4. add_table(doc_id, 3, 4, [["Header1", "Header2", ...], ...])
5. save_document(doc_id)
6. close_document(doc_id)
```

## Tool Fallback Chain

The docx-edit-agent uses this fallback chain for DOCX editing:

```
1. SuperDoc MCP (preferred)
   - Full read-write support
   - Tracked changes with author attribution
   - Document creation
   - Check: MCP tool "open_document" is available

2. python-docx (fallback)
   - Read-write support via Python
   - No tracked changes support
   - Check: python3 -c "import docx" 2>/dev/null

3. Fail with instructions
   - Neither tool available
   - Provide installation instructions for SuperDoc
```

## Comparison: markitdown vs SuperDoc

| Capability | markitdown | SuperDoc |
|-----------|------------|----------|
| Read DOCX | Yes (converts to Markdown) | Yes (native text extraction) |
| Write DOCX | No | Yes |
| Edit in-place | No | Yes |
| Tracked changes | No | Yes |
| Create documents | No | Yes |
| Format preservation | No (lossy conversion) | Yes (preserves formatting) |
| Tables | Read only | Read and write |
| Use case | Format conversion | In-place editing |

markitdown is used by `/convert` for one-way extraction. SuperDoc is used by `/edit` for bidirectional editing. They serve complementary purposes and both should remain available.

## Error Handling

### SuperDoc Not Available

If the SuperDoc MCP server is not running or not configured:
- Check if `open_document` tool is accessible
- Fall back to python-docx if available
- Return failed status with installation instructions if neither is available

### Document Lock Errors

SuperDoc may fail if the file is locked by another process with mandatory locks (Windows). On macOS, advisory locks do not block SuperDoc access. See `office-edit-patterns.md` for platform-specific behavior.

### Large Document Performance

SuperDoc processes documents in memory. For very large documents (100+ pages), operations may be slower. The agent should warn the user for documents over 50MB.
