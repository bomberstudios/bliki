# bliki

bliki is a blog + wiki engine. it is not finished yet, so use it at your own risk. I'm currently using it on <http://bomberstudios.com> without (too much) problems, but as I coded it and know how it works that's hardly an objective benchmark.

If you need to write content in Markdown, store it using Stone, and you think your host will be happy sending heavily cached content quite faster than Rails, then bliki might be worth looking at...


## Features
- Theme support
- Disqus comments
- Markdown content
- Pingomatic ping on post creation
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