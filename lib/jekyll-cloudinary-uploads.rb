require "jekyll"
require "jekyll-cloudinary-uploads/version"
class CloudinaryUpload < Liquid::Tag

  def initialize(tagName, content, tokens)
    super
    @content = content
  end

  def render(context)
    #TODO: make sizes configurable
    sizes = [100, 200, 500, 700, 1000]

    site = context.registers[:site]
    if site.config["cloudinary_uploads"].nil?
      Jekyll.logger.abort_with("[Cloudinary]", "You must set your cloud_name in _config.yml")
    end

    settings = site.config["cloudinary_uploads"]
    if settings["cloud_name"] == ""
      Jekyll.logger.abort_with("[Cloudinary Uploads]", "You must set your cloud_name in _config.yml")
    end

    # Get Markdown converter
    markdown_converter = site.find_converter_instance(::Jekyll::Converters::Markdown)

    # Render any liquid variables in tag arguments and unescape template code
    rendered_markup = Liquid::Template
      .parse(@content)
      .render(context)
      .gsub(%r!\\\{\\\{|\\\{\\%!, '\{\{' => "{{", '\{\%' => "{%")

    # Extract tag segments
    markup =
      %r!^(?:(?<preset>[^\s.:\/]+)\s+)?(?<image_src>[^\s]+\.[a-zA-Z0-9]{3,4})\s*(?<html_attr>[\s\S]+)?$!
        .match(rendered_markup)

    unless markup
      Jekyll.logger.abort_with("[Cloudinary Uploads]", "Can't read this tag: #{@content}")
    end

    image_src = markup[:image_src]

    # Process attributes
    html_attr = if markup[:html_attr]
                  Hash[ *markup[:html_attr].scan(%r!(?<attr>[^\s="]+)(?:="(?<value>[^"]+)")?\s?!).flatten ]
                else
                  {}
                end

    # Deal with the "caption" attribute as a true <figcaption>
    if html_attr["caption"]
      caption = markdown_converter.convert(html_attr["caption"])
      html_attr.delete("caption")
    end

    # alt and title attributes should go only to the <img> even when there is a caption
    img_attr = "".dup
    if html_attr["alt"]
      img_attr << " alt=\"#{html_attr["alt"]}\""
      html_attr.delete("alt")
    end
    if html_attr["title"]
      img_attr << " title=\"#{html_attr["title"]}\""
      html_attr.delete("title")
    end
    if html_attr["loading"]
      img_attr << " loading=\"#{html_attr["loading"]}\""
      html_attr.delete("loading")
    end

    attr_string = html_attr.map { |a, v| "#{a}=\"#{v}\"" }.join(" ")

    fallback_url = "https://res.cloudinary.com/#{settings["cloud_name"]}/image/upload#{image_src}"

    srcset = []

    sizes.each do |size|
      srcset << "https://res.cloudinary.com/#{settings["cloud_name"]}/image/upload/c_limit,w_#{size}/#{image_src} #{size}w"
    end

    srcset_string = srcset.join(",\n")
    #TODO: improve sizes with a max & min
    img_sizes = "100vw"

    # preset['figure'] can be 'never', 'auto' or 'always'
    if caption
      "\n<figure #{attr_string}>\n<img src=\"#{fallback_url}\" srcset=\"#{srcset_string}\" sizes=\"#{img_sizes}\" #{img_attr} />\n<figcaption>#{caption}</figcaption>\n</figure>\n"
    else
      "<img src=\"#{fallback_url}\" srcset=\"#{srcset_string}\" sizes=\"#{img_sizes}\" #{attr_string} #{img_attr} crossorigin=\"anonymous\" />"
    end
  end

  Liquid::Template.register_tag "cloudinary_upload", self
end