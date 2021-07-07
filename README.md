git-fish
---
A fish plugin that provides custom commands for git.

# Requirements
- [fzf](https://github.com/junegunn/fzf)
- [ghq](https://github.com/x-motemen/ghq)
- [git](https://git-scm.com/)

# Installation

## With Fisher
```
fisher install miya10kei/git-fish
```

# Usage of custom command

## Change git directory

```fish
git_fish cd
```

Use ghq to display your local git repositories.


## Erase branches

```fish
git_fish erase
```

Use fzf to select branches.


## Select branch

```fish
git_fish select
```

Use fzf to select branch.
