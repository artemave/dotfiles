## GitHub access in this container

GitHub access is limited to this checkout's own repository (its `origin`). Other repositories, account-wide endpoints (search, notifications, gists, org and user listings) and repository administration (settings, secrets, hooks, keys, collaborators, branch protection) are refused.

The GitHub GraphQL API is blocked, so `gh pr …`, `gh issue …` and `gh repo view` fail with `GraphQL: Resource not accessible by personal access token`, and `gh auth status` wrongly reports the token as invalid (`gh api user` shows it works). Use `gh api` REST calls instead; `{owner}/{repo}` is filled in from the current checkout:

```sh
# Open a PR from the pushed current branch
gh api repos/{owner}/{repo}/pulls -f title='Fix the thing' -f head="$(git branch --show-current)" -f base=main -f body='…'

# Find the PR for a branch
gh api "repos/{owner}/{repo}/pulls?head={owner}:my-branch&state=all"

# View a PR, its conversation, review comments and reviews
gh api repos/{owner}/{repo}/pulls/123
gh api repos/{owner}/{repo}/issues/123/comments
gh api repos/{owner}/{repo}/pulls/123/comments
gh api repos/{owner}/{repo}/pulls/123/reviews

# Comment on a PR or issue
gh api repos/{owner}/{repo}/issues/123/comments -f body='…'

# Reply to a review comment
gh api repos/{owner}/{repo}/pulls/123/comments/456/replies -f body='…'

# Update a PR (title, body, state, base)
gh api -X PATCH repos/{owner}/{repo}/pulls/123 -f body='…'

# Merge a PR
gh api -X PUT repos/{owner}/{repo}/pulls/123/merge -f merge_method=squash

# Issues
gh api repos/{owner}/{repo}/issues -f title='…' -f body='…'
gh api repos/{owner}/{repo}/issues/45

# CI status for a commit
gh api repos/{owner}/{repo}/commits/"$(git rev-parse HEAD)"/check-runs --jq '.check_runs[] | {name, status, conclusion}'
```

`git` (clone, fetch, pull, push over HTTPS), `gh pr diff`, `gh run`, `gh workflow` and `gh release` work as usual; any `gh` subcommand that fails with a GraphQL error has a `gh api` REST equivalent. Triggering workflows (`gh workflow run`), draft → ready, auto-merge, resolving review threads, Projects and Discussions are not available.

A `403`, `FORBIDDEN`, `Repository not found` or `Permission … denied` from GitHub means the operation is outside this container's scope. Don't retry it, re-authenticate or look for another route; tell the user what you were trying to do.
