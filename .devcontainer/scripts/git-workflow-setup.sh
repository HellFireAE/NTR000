#!/bin/bash
# Recommended Git Configuration for Clean Workflow
# Run this script to apply all settings

echo "Applying recommended Git configuration..."

# Rebase workflow (cleaner history)
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global rebase.autoSquash true        # Auto-squash commits marked with fixup!/squash!

# Better merge/rebase conflict resolution
git config --global merge.conflictStyle diff3     # Show common ancestor in conflicts
git config --global rerere.enabled true           # Remember how you resolved conflicts

# Safer operations
git config --global fetch.prune true              # Auto-remove deleted remote branches
git config --global fetch.pruneTagstrue          # Auto-remove deleted remote tags
git config --global push.autoSetupRemote true     # Auto-setup tracking on first push
git config --global push.useForceIfIncludes true  # Extra safety for force-with-lease

# Better output
git config --global branch.sort -committerdate    # Sort branches by recent activity
git config --global log.date relative             # Show "2 days ago" instead of dates
git config --global diff.colorMoved default       # Highlight moved code differently

# Performance
git config --global core.preloadindex true
git config --global core.fscache true
git config --global gc.auto 256

# Default branch name
git config --global init.defaultBranch master     # Match your repo

echo "✓ Git configuration applied!"
echo ""
echo "Key behaviors:"
echo "  • Pull will rebase instead of merge (clean history)"
echo "  • Uncommitted changes auto-stash during rebase"
echo "  • Deleted remote branches auto-pruned on fetch"
echo "  • Force pushes have extra safety checks (useForceIfIncludes)"
echo "  • Conflict resolution gets easier with diff3 style"
