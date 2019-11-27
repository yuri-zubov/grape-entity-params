# frozen_string_literal: true

require 'grape'
require 'grape-entity'
require "grape/entity/params/version"
require 'grape/entity/params/param'
require 'grape/entity/params/dsl'

module Grape
  class Entity
    module Params
      class Error < StandardError; end
      def self.build(entity)
        return lambda {} unless entity.respond_to?(:root_exposures)

        params = entity.root_exposures.map do |sub_entity|
          Grape::Entity::Params::Param.for(sub_entity)
        end
        lambda {|params_scope| params.each{ |param| param.create(params_scope) } }
      end
    end
  end
end
