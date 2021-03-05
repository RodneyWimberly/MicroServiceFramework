@echo off
echo Commiting changes to GitHub repository

pushd d:\em\Core\shared\dev
.\git-push-origin-master.vbs
.\git-commit-drafts.vbs
popd

echo Changes are now committed
