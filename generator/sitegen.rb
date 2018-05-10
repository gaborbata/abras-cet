#!/usr/bin/env ruby

# sitegen.rb - a simple static site generator
#
# Abras Cet, Copyright 2018 Gabor Bata
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# encoding: UTF-8

require "erb"
require "yaml"
require "date"

class Page
  attr_reader :model, :link

  def initialize(id, template, model, folder = nil, extension = "html", layout = "layout.erb")
    @id = id
    @template = template
    @model = model
    @folder = folder
    @layout = layout
    @link = @folder ? "#{@folder}/#{@id}.#{extension}" : "#{@id}.#{extension}"
  end

  def render(template_path = @template)
    template_content = nil
    File.open(File.expand_path("../template/#{template_path}"), "r:UTF-8") do |file|
      template_content = file.read
    end
    template = ERB.new(template_content, trim_mode: "-")
    template.result(binding)
  end

  def absolute_url(domain, link = @link)
    link == "index.html" ? "#{domain}/" : "#{domain}/#{link}"
  end

  def href(href)
    if ["../index.html", "index.html"].include?(href)
      "/"
    elsif href.start_with?("#{@folder}/")
      href.sub("#{@folder}/", "")
    else
      "#{@folder ? "../" : ""}#{href}"
    end
  end

  def decode_html_entities(text)
    text.gsub('&ndash;', "\u2013").gsub('&hellip;', "\u2026")
  end

  def generate(site_model)
    puts "Generating: id:#{@id}, template:#{@template}, link:#{@link}"
    @model = site_model.merge(@model)
    content = render(@layout ? @layout : @template)
    Dir.mkdir("../#{@folder}") if @folder && !Dir.exist?("../#{@folder}")
    File.open(File.expand_path("../#{@link}"), "w:UTF-8") do |file|
      file.write(content)
    end
  end
end

def load_yml(path)
  begin
    YAML.load_file(path, aliases: true, permitted_classes: [Date])
  rescue => error
    # fallback to ruby 3.0 behaviour
    puts "Warning: load_yml(#{path}): #{error.message}"
    YAML.load_file(path)
  end
end

def create_image_pages()
  pages = []
  previous_page = nil
  load_yml("../content/images.yml").each do |key, model|
    current_page = Page.new(key, "image.erb", model, "abra")
    if previous_page
      current_page.model["next"] = previous_page.link
      previous_page.model["prev"] = current_page.link
    end
    previous_page = current_page
    pages.push(current_page)
  end
  pages.each do |page|
    page.model["first"] = pages.last.link if page.link != pages.last.link
    page.model["last"] = pages.first.link if page.link != pages.first.link
    page.model["link"] = page.link
  end
  return pages
end

def create_home_page(image_pages)
  model = load_yml("../content/home.yml")
  model = image_pages.first.model.merge(model)
  # Let Google decide which page to index
  # model["meta"] = {} if model["meta"].nil?
  # model["meta"]["canonical"] = image_pages.first.link
  Page.new("index", "image.erb", model)
end

def create_archive_page(image_pages)
  model = load_yml("../content/archive.yml")
  model["image_pages"] = image_pages
  Page.new("archiv", "archive.erb", model)
end

def create_about_page()
  model = load_yml("../content/about.yml")
  Page.new("a-cetrol", "about.erb", model)
end

def create_sitemap_xml(pages)
  model = { "pages" => pages }
  Page.new("sitemap", "sitemap_xml.erb", model, nil, "xml", nil)
end

def create_robots_xml(sitemap)
  model = { "sitemap" => sitemap }
  Page.new("robots", "robots_txt.erb", model, nil, "txt", nil)
end

# Create page objects
image_pages = create_image_pages()
home_page = create_home_page(image_pages)
archive_page = create_archive_page(image_pages)
about_page = create_about_page()

# Load site model
site_model = load_yml("../content/site.yml")
site_model["pages"] = {
  "home" => home_page,
  "archive" => archive_page,
  "about" => about_page
}

# Generate pages
pages = image_pages + [home_page, archive_page, about_page]
pages.each do |page|
  page.generate(site_model)
end

# Generate sitemap and robots.txt XML
sitemap_xml = create_sitemap_xml(pages)
sitemap_xml.generate(site_model)
robots_txt = create_robots_xml(sitemap_xml)
robots_txt.generate(site_model)
