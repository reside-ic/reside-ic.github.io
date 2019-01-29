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
echo 'Pushing to gh-pages'
git subtree push --prefix public origin gh-pages
