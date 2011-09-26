rm ~/Dropbox/Public/wespoints/calc.js
coffee -o ~/Dropbox/Public/wespoints -c calc.coffee
rm ~/Dropbox/Public/wespoints/index.html
haml index.haml ~/Dropbox/Public/wespoints/index.html
rm ~/Dropbox/Public/wespoints/style.css
sass style.sass ~/Dropbox/Public/wespoints/style.css
