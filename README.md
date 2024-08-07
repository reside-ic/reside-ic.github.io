## Developing

 # **Important!** **_Do not edit the master branch. It is auto-generated by hugo. 
The default branch for this repo is `source`_**

### Get started
1. Install [hugo](https://gohugo.io/)
1. Clone the repo
    ```
     git clone git@github.com:reside-ic/reside-ic.github.io.git
    ```
    You will automatically have checked out the `source` branch, which is the default branch for this repo and contains 
    the source code for the hugo site.
1. Make changes on a branch
1. To view changes locally run `hugo server`
1. To publish merged changes, from the `source` branch run
    ```
     ./scripts/publish.sh
    ```
    
### Editing the theme
We're using [cocoa-eh](https://github.com/mtn/cocoa-eh-hugo-theme), available under the MIT 
license. 

### Adding a blog post
Add a new markdown file in `content/blog`