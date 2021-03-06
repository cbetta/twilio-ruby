require 'nokogiri'

##
# This code was generated by
# \ / _    _  _|   _  _
#  | (_)\/(_)(_|\/| |(/_  v1.0.0
#       /       /

module Twilio
  module TwiML
    class TwiMLError < StandardError; end

    class TwiML
        attr_accessor :name

        def initialize(**keyword_args)
          @name = self.class.name.split('::').last
          @value = nil
          @verbs = []
          @attrs = {}

          keyword_args.each do |key, val|
            @attrs[TwiML.to_lower_camel_case(key)] = val unless val.nil?
          end
        end

        def self.to_lower_camel_case(symbol)
          # Symbols don't have the .split method, so convert to string first
          result = symbol.to_s
          if result.include? '_'
            result = result.split('_').map(&:capitalize).join
          end
          result[0].downcase + result[1..result.length]
        end

        def to_s(xml_declaration = true)
          save_opts = Nokogiri::XML::Node::SaveOptions::DEFAULT_XML
          if !xml_declaration
            save_opts = save_opts | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION
          end
          opts = { encoding: 'UTF-8', indent: 0, save_with: save_opts }
          document = Nokogiri::XML::Document.new
          document << self.xml(document)
          document.to_xml(opts)
        end

        def xml(document)
          # create XML element
          value = (@value.is_a?(String) or @value == nil) ? @value : JSON.generate(@value)
          elem = Nokogiri::XML::Node.new(@name, document)
          elem.content = value
          # set element attributes
          keys = @attrs.keys.sort
          keys.each do |key|
            value = @attrs[key]

            value_is_boolean = value.is_a?(TrueClass) || value.is_a?(FalseClass)
            elem[key] = value_is_boolean ? value.to_s.downcase : value.to_s
          end

          @verbs.each do |verb|
            elem << verb.xml(document)
          end

          elem
        end

        def append(verb)
          raise TwiMLError, 'Only appending of TwiML is allowed' unless verb.is_a?(TwiML)

          @verbs << verb
          self
        end

      alias to_xml to_s
    end
  end
end