---
name: heic-to-png-cleanup
description: Convert HEIC/HEIF image files to PNG using ImageMagick on Windows, verify each output, and delete the original HEIC/HEIF files only after successful conversion. Use when Codex needs to process iPhone HEIC photos, bulk-convert HEIC images for OCR/reading, or clean up originals after conversion in a safe, repeatable way.
---

# HEIC to PNG Cleanup

Use this skill to convert local `.heic` or `.heif` files to `.png` and remove the originals after confirming conversion succeeded.

## Workflow

1. Locate source files and choose the output directory.
   - Default output directory: `converted` under the source directory.
   - Preserve original base names, changing only the extension to `.png`.
2. Run `scripts/Convert-HeicToPngAndDelete.ps1`.
3. Confirm every expected PNG exists and has nonzero size.
4. Delete HEIC/HEIF originals only for files that converted successfully.
5. Report counts for converted, deleted, skipped, and failed files.

## Safety Rules

- Never delete a source file unless its corresponding PNG exists and has nonzero size.
- Resolve absolute paths before deletion and ensure they are inside the intended source directory.
- Keep output files in a separate directory by default so deletion of originals cannot remove generated PNGs.
- If any conversion fails, leave that original file in place and report it.
- Do not overwrite existing PNG files unless the user explicitly asks for overwrite behavior; by default the script skips files whose output already exists.

## Script

Run from the repository root or any directory:

```powershell
powershell -ExecutionPolicy Bypass -File "skills\heic-to-png-cleanup\scripts\Convert-HeicToPngAndDelete.ps1" `
  -SourceDir "第一次試験\中小企業経営・中小企業政策\参考問題\6年度"
```

Useful options:

```powershell
# Preview actions without writing or deleting.
powershell -ExecutionPolicy Bypass -File "skills\heic-to-png-cleanup\scripts\Convert-HeicToPngAndDelete.ps1" -SourceDir "<dir>" -WhatIf

# Recreate PNGs even if outputs already exist.
powershell -ExecutionPolicy Bypass -File "skills\heic-to-png-cleanup\scripts\Convert-HeicToPngAndDelete.ps1" -SourceDir "<dir>" -Overwrite

# Use a custom output directory.
powershell -ExecutionPolicy Bypass -File "skills\heic-to-png-cleanup\scripts\Convert-HeicToPngAndDelete.ps1" -SourceDir "<dir>" -OutputDir "<dir>\png"
```

The script finds ImageMagick via `magick` on `PATH`, then common Windows install locations such as `C:\Program Files\ImageMagick-*\magick.exe`.
