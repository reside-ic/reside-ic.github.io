if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]] && echo "*" = "*"; then
    echo "git not clean, commit changes first"
    exit 1
fi

echo "-------------------------------------------"
echo 'Compiling site'
hugo

git add .
git commit -m "publish"

echo "-------------------------------------------"
echo 'Pushing to master'

sed -i 's/public/ /g' .gitignore

git add .
git commit -m "Edit .gitignore to publish"

git push origin `git subtree split --prefix public`:master --force

git reset HEAD~
git checkout .gitignore
