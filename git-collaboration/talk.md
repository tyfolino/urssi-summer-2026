class: middle, center, title-slide
count: false

# Collaboration with Git and GitHub

.large.blue[Ty Janoski]<br>
.large[(Rutgers University)]
<br>
[tyler.janoski@rutgers.edu](mailto:tyler.janoski@rutgers.edu)
<br>

[URSSI Summer School on Research Software Development](https://github.com/si2-urssi/summerschool-June2026)

June 8th, 2026

---
# Lesson objectives

.large[
* Review the core git commands
* Describe individual and collaborative workflows with git
* Introduce the git/GitHub commands for collaborative workflows
* Demo a collaborative workflow in practice on a real project ([ClimKern](https://github.com/tyfolino/climkern))
* See additional useful git tips & tricks
]

---
# Acknowledgements

This material is adapted from [Madicken Munk](https://munkm.github.io/)'s lesson for the
2024 URSSI Winter School, which was itself heavily influenced by the previous works of
[Karthik Ram](https://inundata.org/talks/git-collaboration/#/) and
[James Howison](https://jameshowison.github.io/peer_production_course/docs/additional_git_exercises.html).

.large[Other resources I have found helpful (and fun) for git:]

* https://git-school.github.io/visualizing-git/
* https://pcottle.github.io/learnGitBranching/?NODEMO
* https://allisonhorst.com/git-github
* https://jvns.ca/blog/2023/11/23/branches-intuition-reality/
* https://git-scm.com/docs
* https://swcarpentry.github.io/git-novice/

---
class: middle, center

# Workflows with git

---
# An individual workflow (without a remote)

.large[commit, commit, commit .....]

```console
$ git init
Initialized empty Git repository in ~/repos/climkern/.git/
$ git branch -M main
$ git add README.md
$ git commit -m 'add readme with package description'
[main (root-commit) 49c9e77] add readme with package description
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 README.md
```

---
# An individual workflow (with a remote)

.large[commit push, commit commit push, commit push .....]

```console
$ git remote add origin git@github.com:tyfolino/climkern.git
$ git push -u origin main
Enumerating objects: 13, done.
Counting objects: 100% (13/13), done.
Writing objects: 100% (13/13), 8.03 KiB | 4.01 MiB/s, done.
To github.com:tyfolino/climkern.git
 * [new branch]      main -> main
$ git add LICENSE
$ git commit -m 'add MIT license for my code'
$ git push
```

.large[
With your code on a remote (GitHub, GitLab, or an internal server for your lab),
your work is easily accessed by peers!
]

---
class: middle, center

# ... but what about working with others?

---
# Centralized workflow

.large[All members work on the **same repository**.]

<br>

`git pull` before starting work

Everyone commits to `main`

`git push`

--

If there is no merge conflict, 🙌

--

Otherwise, fix the merge conflict, then push

---
# Feature branching workflow

.large[
Members work on the same repository but use **individual branches** to do feature development.
]

1. Create and switch to a branch
2. Add commits
3. Push the feature branch to GitHub
4. Open a pull request
5. Discuss, add more commits, merge

---
# Feature branching workflow

Some important commands for this workflow:

```console
$ git switch -c <branchname>     # create + switch to a new branch
$ git branch                     # list branches
$ git push -u origin <branchname>
```

.footnote[
.blue[**2026 note:**] `git switch` / `git restore` (stable since git 2.23) split the
many jobs of the old `git checkout` into two clearer commands.
`git switch -c` replaces `git checkout -b`. You'll still see `checkout` everywhere —
both work.
]

--

... add some more commits

then `git push` and **open a pull request**

---
# Pull requests

.large[
Pull requests are an excellent tool for **fostering code review**. If you're using
GitHub for team projects, *you should be using these extensively*.
]

--

.large[
A good practice is for **someone else** to merge your code, ensuring two people
understand each feature. If a reviewer doesn't have merge rights, the requirement may
instead be an **approving review** before the feature is merged.
]

---
# Pull request tip

.large[
Using the GitHub interface, you can change the **target** of a pull request. The default
is the `main` branch, but it could be another feature branch. Useful when you want to
co-develop a feature branch with a collaborator outside of `main`.
]

--

<br>

⛔️ Never send a pull request from `main` 🙅

--

⛔️ Never send a large pull request without notice 🙅

---
# Forking workflow

.large[
Each collaborator **forks** a copy of the centralized repository. These forks are
individual remote repositories. Collaborators submit pull requests **from their forks**
to the centralized repository.
]

1. Everyone has a fork of a "central" repository
2. Add commits to feature branches
3. Push feature branches to your individual fork
4. Send a pull request from the feature branch on your fork to the central repo

.footnote[
This is the workflow most open-source contributions use — including the ClimKern PR
we'll review in the next session.
]

---
# The `gh` CLI ties it together

.large[
GitHub's [command-line tool](https://cli.github.com/) (`gh`) lets you stay in the
terminal for the GitHub half of the workflow.
]

```console
$ gh repo fork tyfolino/climkern --clone   # fork + clone in one step
$ git switch -c fix-typo
# ... make changes, commit ...
$ git push -u origin fix-typo
$ gh pr create --fill                       # open a PR from the terminal
$ gh pr status                              # see your PRs
$ gh pr checkout 48                         # check out someone else's PR locally
```

---
# Protecting `main`: rulesets

.large[
On a shared repo, you usually don't want anyone pushing straight to `main`.
]

.blue[**2026 note:**] GitHub **rulesets** have largely replaced classic "branch protection
rules." On a branch or tag you can require:

* a pull request + N approving reviews before merge
* status checks (CI, linters) to pass
* the branch to be up to date
* linear history / signed commits

--

**Merge queues** then batch-test and merge approved PRs in order, so `main` never breaks
even when several PRs land at once.

---
class: middle, center

# More useful git commands

---
# Tagging commits

Branches are labels that track a series of commits — but what if you want a special
name for a *particular* commit (like a release)? You can [**tag**](https://git-scm.com/book/en/v2/Git-Basics-Tagging) it.

```console
$ git tag -a v1.2 -m "ClimKern v1.2 release"   # tag the current commit
$ git tag -a v1.1 <hash>                        # tag an older commit
$ git push origin v1.2                          # push one tag
$ git push origin --tags                        # push all tags
```

.footnote[
Tags are how ClimKern's releases map to Zenodo DOIs — each tagged version gets archived.
]

---
# Amending a commit

.large[
Oh no! I made a typo in my commit message!
]

`git commit --amend` is useful for both fixing commit messages and for adding files that
were supposed to be in the last commit but weren't.

--

.footnote[
⚠️ Amending **rewrites history** — only do it on commits you haven't shared yet
(or be ready to `push --force-with-lease` on your own feature branch).
]

---
# Cherry-picking

.large[
What if you have a commit that really belongs on a different branch? Or you fixed a bug
in development that you think should be its own PR?
]

You can **cherry-pick** that commit onto another branch:

```console
$ git switch -c hotfix
$ git cherry-pick <hash>
```

---
# Undoing changes

.large[
**Reverting** vs. **restoring**
]

* `git revert <hash>` — make a **new commit** that undoes an old one (safe; keeps history)
* `git restore <file>` — discard **uncommitted** changes in your working tree
* `git restore --staged <file>` — unstage a file (the modern `git reset HEAD <file>`)

---
# Stashing changes

.large[
Oh no! I started making changes but I'm not on the feature branch I thought I was!
]

`git stash` hides the changes in your working tree so you can bring them back out once
you're on the right branch:

```console
$ git stash            # shelve your changes
$ git switch the-right-branch
$ git stash pop        # bring them back
```

---
# Co-authoring changes

.large[
Have you pair-programmed with a friend and come up with a solution together? How do you
handle attribution?
]

Add one or more trailers to the commit message:

```
Co-authored-by: NAME <EMAIL>
Co-authored-by: OTHER NAME <OTHER_EMAIL>
```

GitHub will show **both** of you as authors of the commit.

---
# Extra tips

.large[
* **Tip #1:** Always `git pull` before you start new work
* **Tip #2:** Keep branch names descriptive
* **Tip #3:** Generously use branches (but delete them when merged or stale)
* **Tip #4:** Use the [`gh`](https://cli.github.com/) CLI to simplify your workflow
]

---
# More resources

.large[
* Need to version-control large files? [git lfs](https://git-lfs.com/) and
  [git annex](https://git-annex.branchable.com/) are built for this
* [How to undo almost anything with git](https://github.blog/2015-06-08-how-to-undo-almost-anything-with-git/)
* [Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
  (like private keys) from a repository
]

---
class: middle, center

# Exercises

---
# Choose one

.large[
**Option A — Review a real PR**

Open an issue on your own project for a beginner-friendly improvement, and describe it
thoroughly. Then, in groups at your table, have a partner **fork** your project and
submit a **pull request** fixing that issue. *Do not merge the pull request today* —
we'll use it in the peer code review session.
]

--

.large[
**Option B — Add a feature on a branch**

Thinking back to the design-patterns or packaging lectures, make a **feature branch** on
your project and add one of those improvements. Open a **pull request** from that branch.
*Do not merge it today.*
]

---
class: middle, center
count: false

# The end.

Adapted from [Madicken Munk](https://munkm.github.io/)'s 2024 URSSI lesson.
