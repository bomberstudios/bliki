helpers do
  def link_to txt, url
    "<a href='#{url}'>#{txt}</a>"
  end
  def tag_list tags, where=""
    if tags.is_a? String
      tags = tags.split(",").collect { |t| t.strip }
    end
    return tags.map { |tag|
      tag = link_to tag, "#{where}/tag/#{tag}"
    }.join(", ")
  end
  def pingomatic
    begin
      return if Sinatra::Application.ping == false
      require "erb"
      require "net/http"
      blog_name = ERB::Util.url_encode(Sinatra::Application.name)
      url = ERB::Util.url_encode(Sinatra::Application.base_url)
      feed_url = ERB::Util.url_encode(Sinatra::Application.base_url + "/feed/")
      ping_url = "http://pingomatic.com/ping/?title=#{blog_name}&blogurl=#{url}&rssurl=#{feed_url}&chk_weblogscom=on&chk_blogs=on&chk_technorati=on&chk_feedburner=on&chk_syndic8=on&chk_newsgator=on&chk_myyahoo=on&chk_pubsubcom=on&chk_blogdigger=on&chk_blogrolling=on&chk_blogstreet=on&chk_moreover=on&chk_weblogalot=on&chk_icerocket=on&chk_newsisfree=on&chk_topicexchange=on&chk_google=on&chk_tailrank=on&chk_bloglines=on&chk_aiderss=on"
      Net::HTTP.get(URI.parse(ping_url))
    rescue Exception => e
      "oops"
    end
  end
  def reinvigorate
    return "<script type=\"text/javascript\" src=\"http://include.reinvigorate.net/re_.js\"></script>
    <script type=\"text/javascript\">
    re_(\"#{Sinatra::Application.reinvigorate_code}\");
    </script>"
  end
  def atom_time date
    date.strftime("%Y-%m-%dT%H:%M:%SZ")
  end
  def disqus
    return "<div id=\"disqus_thread\"></div><script type=\"text/javascript\" src=\"http://disqus.com/forums/#{Sinatra::Application.disqus_id}/embed.js\"></script><noscript><a href=\"http://#{Sinatra::Application.disqus_id}.disqus.com/?url=ref\">View the discussion thread.</a></noscript><a href=\"http://disqus.com\" class=\"dsq-brlink\">blog comments powered by <span class=\"logo-disqus\">Disqus</span></a>" unless @post.is_a? Page
  end
  def post_navigation
    html = ""
    if ((@post.is_a? Post) && (@post.next || @post.prev))
      html << "<div id=\"navigation\">"
      if @post.prev
        html <<  "<span class=\"left\">#{link_to '«' + @post.prev_by_created_at.title, @post.prev_by_created_at.link}</span>"
      end
      if @post.next
        html << "<span class=\"right\">#{link_to @post.next_by_created_at.title + '»', @post.next_by_created_at.link}</span>"
      end
      html << "</div>"
    end
    return html.chomp
  end
  def form
    if @post
      @title = @post.title
    else
      @title = params[:slug]
    end

    return <<-HTML
    <form action="" method="post" accept-charset="utf-8">
      <input type="text" name="title" value="#{@title}" id="title" /><br>
      <input type="text" name="tags" value="#{@post.tags unless @post.nil?}" id="tags" /><br>
      <textarea name="body" rows="20" cols="40">#{@post.body unless @post.nil?}</textarea><br>
      <p><input type="submit" value="Continue &rarr;" accesskey="s" /></p>
    </form>
    <script type="text/javascript" charset="utf-8">
      document.forms[0].title.focus();
    </script>
    HTML
  end
end