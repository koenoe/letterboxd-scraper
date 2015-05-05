require 'letterboxd/scraper/version'
require 'letterboxd/scraper/base'

module Letterboxd
  module Scraper
    extend Letterboxd::Scraper::Base

    def self.fetch_seen(username)
      fetch_films("/#{username}/films")
    end

    def self.fetch_watchlist(username)
      fetch_films("/#{username}/watchlist")
    end

    def self.fetch_liked(username)
      fetch_films("/#{username}/likes/films")
    end

    def self.fetch_rated(username, rating = nil)
      if rating.nil?
        fetch_films("/#{username}/films/ratings")
      else
        fetch_films("/#{username}/films/ratings/rated/#{rating}")
      end
    end

    def self.fetch_popular(pages = 400)
      # popular is an AJAX call and has 18 items per page instead of 72
      fetch_films("/films/ajax/popular", pages)
    end

    def self.fetch_film(slug)
      doc = fetch("/film/#{slug}")
      tmdb_id = doc.at_css('body').attribute('data-tmdb-id').value
      title = doc.at_css('#featured-film-header .film-title').text
      director = doc.at_css('#featured-film-header p > a').text

      Letterboxd::Film.new({
        title: title,
        slug: slug,
        tmdb_id: tmdb_id,
        director: director
      })
    end
  end
end