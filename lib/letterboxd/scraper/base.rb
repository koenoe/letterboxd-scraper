require 'nokogiri'

module Letterboxd
  module Scraper
    module Base
      def base_url
        'http://www.letterboxd.com'
      end

      def fetch(url)
        Nokogiri::HTML(open(base_url + url))
      end

      def strip_slug(slug)
        slug.split('/').reject(&:empty?).last
      end

      def find_last_page_pagination(doc)
        last_page = doc.css('.pagination .paginate-pages .paginate-page').last
        unless last_page.blank?
          return last_page.at_css('a').text.to_i
        end
        false
      end
    end
  end
end