require 'open-uri'
require 'net/http'
require 'nokogiri'

module Letterboxd
  module Scraper
    module Base

      def base_url
        'http://letterboxd.com'
      end

      def url_exist?(url_string)
        url_string = base_url + url_string unless url_string.include? 'letterboxd.com'
        url = URI.parse(url_string)
        # puts url
        req = Net::HTTP.new(url.host, url.port)
        req.use_ssl = (url.scheme == 'https')
        path = url.path unless url.path.nil?
        res = req.request_head(path || '/')
        if res.kind_of?(Net::HTTPRedirection)
          url_exist?(res['location']) # Go after any redirect and make sure you can access the redirected URL
        else
          res.code[0] != "4" #false if http code starts with 4 - error on your side.
        end
      rescue Errno::ENOENT
        false #false if can't find the server
      end

      def fetch(url)
        # puts "Fetching #{url} ..."
        sleep(0.05)
        doc = nil
        retries = 0
        begin
          uri = open(base_url + url, "Host" => "letterboxd.com")
          begin
            doc = Nokogiri::HTML(uri)
          rescue Exception => e
            puts "Error parsing document: #{e.message}"
            doc = fetch(url)
          end
        rescue Exception => e
          puts "Error opening url: #{e.message}"
          if e.message != '403 Forbidden' && e.message != '404 Not Found'
            doc = fetch(url)
            retries = retries + 1
          end
        end
        doc
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

      def fetch_users(url, number_of_pages_limit = nil)
        doc = fetch("#{url}")

        next_page_available = true
        users = []
        i = 1

        while next_page_available do

          if number_of_pages_limit.present? && i >= number_of_pages_limit
            next_page_available = false
            break
          end

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
        begin
          list = doc.css('.person-table .table-person h3 > a')
          list.each do |node|
            items << {name: strip_emoji(node.text.to_s.squish), username: strip_slug(node.attribute('href').value)}
          end
          items.flatten
        rescue Exception => e
          puts "Error parsing users: #{e.message}"
        end
      end

      protected
        def strip_emoji ( str )
          str = str.force_encoding('utf-8').encode
          clean_text = ""

          # emoticons  1F601 - 1F64F
          regex = /[\u{1f600}-\u{1f64f}]/
          clean_text = str.gsub regex, ''

          #dingbats 2702 - 27B0
          regex = /[\u{2702}-\u{27b0}]/
          clean_text = clean_text.gsub regex, ''

          # transport/map symbols
          regex = /[\u{1f680}-\u{1f6ff}]/
          clean_text = clean_text.gsub regex, ''

          # enclosed chars  24C2 - 1F251
          regex = /[\u{24C2}-\u{1F251}]/
          clean_text = clean_text.gsub regex, ''

          # symbols & pics
          regex = /[\u{1f300}-\u{1f5ff}]/
          clean_text = clean_text.gsub regex, ''
        end

    end
  end
end