# bliki

bliki is a blog + wiki engine. it is not finished yet, so use it at your own risk.


## Features
- Theme support
- Disqus comments
- Markdown content
- A crude importer for WordPress posts.

## Required gems
- sinatra (included as a module)
- stone (included as a module from my fork, as the original Stone contains a nice bug that has not been fixed yet)
- rdiscount
- rack
- haml
- builder

## More required stuff
- sinatra-cache (included as a module)


## TODO

* Customize Pings?
* Meta stuff
* Pagination for posts in home (next 10) and in post view (previous, next)
* Show tags in feed?
* Bookmarklet to post like soup.io
* Support for draft posts
- Sort tag archive by date
- Play with jQuery for sIFR