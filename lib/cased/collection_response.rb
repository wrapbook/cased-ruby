# frozen_string_literal: true

require 'cased/response'

module Cased
  class CollectionResponse < Response
    def results
      return [] unless body

      body['results']
    end

    def total_count
      return unless body

      body['total_count']
    end

    def total_pages
      return unless body

      body['total_pages']
    end

    def next_page_url?
      next_page_url.present?
    end

    def next_page_url
      links[:next]
    end

    def next_page
      page_from(:next)
    end

    def next_page?
      next_page.present?
    end

    def previous_page_url?
      previous_page_url.present?
    end

    def previous_page_url
      links[:prev]
    end

    def previous_page
      page_from(:prev)
    end

    def previous_page?
      previous_page.present?
    end

    def first_page_url?
      first_page_url.present?
    end

    def first_page_url
      links[:first]
    end

    def first_page
      page_from(:first)
    end

    def first_page?
      first_page.present?
    end

    def last_page_url?
      last_page_url.present?
    end

    def last_page_url
      links[:last]
    end

    def last_page
      page_from(:last)
    end

    def last_page?
      last_page.present?
    end

    private

    def page_from(rel)
      rel = links[rel.to_sym]
      return unless rel

      uri = Addressable::URI.parse(rel)
      return unless uri

      page = uri.query_values['page']
      return unless page

      page.to_i
    end

    def links
      link_header = @response.headers['Link']
      return {} unless link_header

      links = link_header.split(', ').map do |link|
        href, name = link.match(/<(.*?)>; rel="(\w+)"/).captures

        [name.to_sym, href]
      end

      Hash[*links.flatten]
    end
  end
end
