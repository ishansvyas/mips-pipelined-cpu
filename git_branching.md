Source: https://www.atlassian.com/git/tutorials/using-branches

# Creation

## Create a branch
git branch <new-branch>
## Create a branch and switch to it
git checkout -b <new-branch>

# Working

## View available branches
git branch
## Rename a branch
git branch -m <branch>
## List remote branches
git branch -a

# Deletion

## Delete a branch
git branch -d <branch>
## Force delete a branch
git branch -D <branch>

# Example
### Start a new feature
git checkout -b new-feature main
### Edit some files
git add <file>
git commit -m "Start a feature"
### Edit some files
git add <file>
git commit -m "Finish a feature"
### Merge in the new-feature branch
git checkout main
git merge new-feature
git branch -d new-feature