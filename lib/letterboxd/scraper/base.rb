require 'open-uri'
require 'nokogiri'

module Letterboxd
  module Scraper
    module Base

      def base_url
        'http://www.letterboxd.com'
      end

      def fetch(url)
        puts "Fetching #{url} ..."
        Nokogiri::HTML(open(base_url + url, "Host" => "letterboxd.com" ))
      end

      def fetch_films(url, number_of_pages_limit = nil)
        doc = fetch("#{url}")
        number_of_pages = find_last_page_pagination(doc)
        films = []
        if number_of_pages
          number_of_pages = number_of_pages_limit unless number_of_pages_limit.nil?
          for i in 1..number_of_pages
            doc = fetch("#{url}/page/#{i}")
            films << parse_films(doc)
          end
        else
          films << parse_films(doc)
        end
        films.flatten
      end

      def fetch_users(url)
        doc = fetch("#{url}")

        next_page_available = true
        users = []
        i = 1

        while next_page_available do
          doc = fetch("#{url}/page/#{i}")
          new_users = parse_users(doc)
          users << new_users
          i += 1

          next_page_available = false unless new_users.size > 0
        end

        users.flatten
      end

      def strip_slug(slug)
        slug.split('/').reject(&:empty?).last
      end

      def find_last_page_pagination(doc)
        last_page = doc.css('.pagination .paginate-pages .paginate-page').last
        unless last_page.nil?
          return last_page.at_css('a').text.to_i
        end
        false
      end

      def parse_films(doc)
        list = doc.css('.film-list .poster')
        items = []
        list.each do |node|

          node_slug = node.attribute('data-film-slug')
          node_slug = node.attribute('data-film-link') if node_slug.nil?

          node_title = node.attribute('data-film-name')
          node_title = node.at_css('img').attribute('alt') if node_title.nil?

          items << {title: node_title.value, slug: strip_slug(node_slug.value)}
        end
        items
      end

      def parse_users(doc)
        items = []

        list = doc.css('.person-table .table-person h3 > a')
        list.each do |node|
          items << {name: node.text, username: strip_slug(node.attribute('href').value)}
        end
        items.flatten
      end

    end
  end
end