require 'letterboxd/models/film'

module Letterboxd
  module Scraper
    class People
      extend Letterboxd::Scraper::Base

      def self.fetch_seen(username)
        doc = fetch("/#{username}/films")
        number_of_pages = find_last_page_pagination(doc)
        films = []
        if number_of_pages
          for i in 1..number_of_pages
            doc = fetch("/#{username}/films/page/#{i}")
            films << fetch_seen_page(doc)
          end
        else
          films << fetch_seen_page(doc)
        end
        films.flatten
      end

      private
        def self.fetch_seen_page(doc)
          list = doc.css(".col-main .film-list .poster")
          items = []
          list.each do |node|
            items << {title: node.at_css('img').attribute('alt').value, slug: strip_slug(node.attribute('data-film-slug').value)}
          end
          items
        end
    end
  end
end