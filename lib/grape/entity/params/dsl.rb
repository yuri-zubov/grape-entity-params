# frozen_string_literal: true

module Grape
  class Entity
    module Params
      module DSL
        module Validations
          def use(*names)
            options = names.extract_options!
            standard_names = names.select { |name| [String, Symbol].include? name.class }
            non_standard_names = names - standard_names
            standard_names += non_standard_names.map do |entity|
              UseEntity.new(@api, entity).build
            end
            super(*standard_names, **options)
          end
        end

        class UseEntity
          attr_reader :api, :entity
          def initialize(api, entity)
            @api = api
            @entity = entity
          end

          def build
            params = Grape::Entity::Params.build(entity)
            key = entity.class.name.to_sym
            api.helpers do
              params key do
                params.call(self)
              end
            end
            key
          end
        end
      end
    end
  end
end

Grape::Validations::ParamsScope.prepend Grape::Entity::Params::DSL::Validations
