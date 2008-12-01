# bliki

bliki is a blog + wiki engine. it is not finished yet, so use it at your own risk. I'm currently using it on <http://bomberstudios.com> without (too much) problems, but as I coded it and know how it works that's hardly an objective benchmark.

If you need to write content in Markdown, store it using Stone, and you think your host will be happy sending heavily cached content quite faster than Rails, then bliki might be worth looking at...

Comments are handled by <http://disqus.com>, because a) I'm too bad a programmer to code a decent comment system, b) the habtm system in Stone sucks big time and c) Disqus already did it.

Themes are stored on the 'themes' folder. There's a sample theme (called 'default', in a wicked display of imagination) you can copy to a new folder and tweak to your heart's content.

There's a helper to insert Reinvigorate tracking codes, but it's easy to add your own tracking.

There's also a (crude) importer for WordPress posts. It is only been tested with the latest (i.e: svn) WordPress version, and its only purpose was to import content from *my* own blog. If it works for you that would be great, but don't count on it :)

I have included a config.ru file you can use for Passenger if you use Dreamhost.

Last (but not least), whenever you publish a post Pingomatic will be pinged. Wiki pages do not trigger pings.


## Setup
- clone the repo
- run 'rake install'
- copy 'config.sample.yml' to 'config.yml' and edit it to suit your needs
- run 'ruby bliki.rb' and cross fingers


## Required gems (hopefully installed by 'rake install')
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