## What problem are you solving?
<!-- Write this in your own words. One paragraph. No AI. -->

- [ ] I am using an agent and I take responsibility for this PR

---

## Changes

<!-- Agent/tool-generated summary below this line is fine -->

## Testing

- [ ] `just validate` passes
- [ ] `just boot-test` passes (automated boot smoke test)
- [ ] `just lint` passes on a built image
- [ ] `just boot-fast` or `just boot-vm` — desktop comes up, no regressions

## Checklist

- [ ] New BST elements wired into `deps.bst`
- [ ] Patches in `patches/` regenerated if junction refs changed

## Community verification (bug-fix PRs)

If this PR fixes a bug, add verify-steps to the issue so the community can confirm
the fix works on their hardware after the next nightly ships:

````markdown
```verify
# Steps for users to verify this fix:
systemctl status <affected-service>
# or whatever the user should check
```
````

Users will run `ujust verify <issue-number>` which fetches these steps automatically.
