# Vim Keymap Spec And Plan

## Goals

- Keep the keymap mentally coherent: key names and prefixes should suggest what they do.
- Reduce duplication so changing one action does not require editing several unrelated mappings.
- Preserve dual-modality use:
  - mouse-first on desktop
  - keyboard-first in constrained environments such as Macs and iPads
- Treat mouse and keyboard as peer frontends over the same core actions where possible.

## Current Assessment

### Improved

- Window cycling is now semantically clearer.
  - `<C-j>` and `<C-k>` no longer pretend to be directional movement.
  - `WinCycleNext()` and `WinCyclePrev()` make the behavior explicit and unify tmux edge handoff.
  - Normal and terminal mode now share the same navigation helpers instead of duplicating the tmux condition inline.
- The `yo` family is more consistent.
  - `yoi` now matches `ignorecase` better than the previous `yoc`.

### Still Good Enough For Now

- `m<CR>` and `m<Space>` still overload a strong built-in Vim prefix, but this is now a policy choice rather than an accidental inconsistency.
- `<C-w>z` still uses Vim's window prefix for a custom zoom action. That is acceptable if it is a deliberate house style.

### Remaining Fragility

- The main semantic actions are still duplicated across modalities and contexts.
  - Plumb current thing is defined separately for normal, visual, mouse, and dir buffers.
  - Run command from current thing or selection is defined separately for keyboard, mouse, and dir buffers.
- The mouse-first and keyboard-first paths still share behavior by convention rather than through common helpers.
- Dir buffer actions still duplicate top-level action logic instead of delegating to a shared interface with a dir-specific data source.

## Desired Model

### Core Principle

Define a small set of semantic actions, then let normal mode, visual mode, terminal mode, mouse bindings, and dir-buffer bindings call those actions with different data sources.

### Canonical Actions

- Open or plumb current thing
- Run command from current thing or selection
- Copy current path or current dir entry path
- Close current buffer or window
- Cycle to next or previous window, with tmux edge handoff
- Open current dir entry

### Modality Rule

- Desktop mouse-first use is the ergonomics baseline.
- Constrained keyboard-first use is the completeness baseline.
- If an action matters in both environments, it should exist in both modalities.
- Mouse-only actions should be limited to genuinely pointer-native gestures such as statusline click behaviors.

## Refactor Plan

### Phase 1: Extract Shared Action Helpers

Add small helpers for the duplicated actions:

- `PlumbCursorThing()`
- `PlumbVisualSelection()`
- `PlumbDirEntry()`
- `CmdCursorThing()`
- `CmdVisualSelection()`
- `CmdDirEntry()`
- `CopyCurrentPath()`
- `CopyDirPath()` or `CopyDirEntryPath()` depending on desired behavior

The exact names can change, but the split should be semantic rather than map-specific.

### Phase 2: Rebuild Maps As Thin Frontends

Normal, visual, mouse, and dir-buffer mappings should call helpers instead of embedding `Plumb(...)`, `Cmd(...)`, or register manipulation inline.

Target shape:

- keyboard map selects the right helper
- mouse map selects the same helper where behavior matches
- dir buffer swaps in a dir-entry helper instead of duplicating the action body

### Phase 3: Decide On Two Policy Exceptions

Keep or revisit these intentionally:

- `m` as a custom make prefix
- `<C-w>z` as a custom zoom action

These are no longer the first cleanup target. They should only move if they are actually causing friction.

### Phase 4: Optional Table-Driven Cleanup

If the file still feels repetitive after action extraction:

- generate the `yo` toggle family from a table
- optionally generate the `[]` next or previous family from a table

This is lower priority than fixing cross-modality action duplication.

## Verification

### Desktop Workflow

- Right click opens or plumbs the clicked thing.
- Middle click runs the expected command target.
- Statusline double click and control click preserve window-close and window-zoom behavior.
- Dir buffer mouse actions match the corresponding keyboard actions.

### Constrained Workflow

- Every core action can be completed without mouse input.
- `<C-j>` and `<C-k>` behave consistently in normal and terminal mode.
- Leader bindings and visual bindings cover the same important actions as mouse bindings.

### Consistency Checks

- Changing the implementation of plumb, command execution, or path copy should require editing one helper per semantic action, not several mappings.
- Dir buffer behavior should differ only in data source, not in action meaning.

## Recommended Next Step

Start with the shared action helpers for plumb and command execution. That is the highest-value cleanup because it directly improves both maintainability and dual-modality parity without forcing more key changes.