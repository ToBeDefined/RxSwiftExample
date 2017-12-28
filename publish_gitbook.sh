# install the plugins and build the static site
gitbook install && gitbook build

# add ssh origin 
git remote add origin_ssh git@github.com:ToBeDefined/RxSwiftExample.git

# fetch
git fetch origin_ssh

# checkout to the gh-pages branch
git checkout gh-pages

# pull the latest updates
git pull origin_ssh gh-pages --rebase

# copy the static site files into the current directory.
cp -r _book/* ./

# add all files
git add .

# commit
git commit -a -m "Update docs"

# push to the origin
git push --force --quiet origin_ssh gh-pages:gh-pages

# remove ssh origin
git remote rm origin_ssh

# checkout to the master branch
git checkout master

# clean files
git clean -f

