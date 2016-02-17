require 'addressable'
require 'nokogiri'

module Goldfinger
  class Client
    include Goldfinger::Utils

    def initialize(uri)
      @uri = uri
    end

    def finger
      _, template   = perform_get(url)
      headers, body = perform_get(url_from_template(template))
      Goldfinger::Result.new(headers, body)
    end

    private

    def url(ssl = true)
      "http#{'s' if ssl}://#{domain}/.well-known/host-meta"
    end

    def url_from_template(template)
      xml   = Nokogiri::XML(template)
      links = xml.xpath('//xmlns:Link[@rel="lrdd"]', xmlns: 'http://docs.oasis-open.org/ns/xri/xrd-1.0')

      raise Goldfinger::Error::NotFound if links.empty?

      url = Addressable::Template.new(links.first.attribute('template').value)
      url.expand({ uri: @uri }).to_s
    end

    def domain
      @uri.split('@').last
    end
  end
end