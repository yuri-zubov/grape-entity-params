# frozen_string_literal: true

module Grape
  class Entity
    module Params
      # I am a factory to create a parameter class
      module Param
        @descendants = []
        class << self
          attr_reader :descendants
          def inherited(subclass)
            @descendants << subclass
          end
        end

        self.attr_reader :descendants
        def self.for(entity)
          smart_entity = EntityFactory.for(entity)

          if smart_entity.children?
            option_class = ParamGroup
          else
            option_class = SingleParam
          end

          children = Grape::Entity::Params.build(smart_entity.type)
          option_class.new(smart_entity, children)
        end
      end

      class EntityFactory
        def self.for(entity)
          klass = if entity.documentation[:type].respond_to?(:root_exposures)
                    Grape::Entity::Params::SmartEntityGroup
                  else
                    Grape::Entity::Params::SmartEntity
                  end
          klass.new(entity)
        end
      end

      class SmartEntityBase < SimpleDelegator
        VALIDATION_METHOD = { nil => :optional, false => :optional, true => :requires }
        
        def type
          documentation[:type]
        end

        def validation_type
          type
        end

        def validation_method
          VALIDATION_METHOD[documentation[:required]]
        end

        def children?
          false
        end
      end
      
      class SmartEntity < SmartEntityBase; end

      class SmartEntityGroup < SmartEntityBase
        VALIDATION_TYPE = { nil => Hash, false => Hash, true => Array }
        def validation_type
          VALIDATION_TYPE[documentation[:is_array]]
        end

        def children?
          true
        end
      end

      class BaseParam < SimpleDelegator
        attr_reader :entity, :children
        def initialize(entity, children)
          @entity = entity
          @children = children
        end

        def create(params_scope)
          params_scope.send(entity.validation_method, entity.key, documentation)
        end

        private

        def documentation
          entity.documentation.slice(:type, :desc).merge(type: entity.validation_type)
        end
      end

      class SingleParam < Grape::Entity::Params::BaseParam; end
      
      class ParamGroup < Grape::Entity::Params::BaseParam
        def create(params_scope)
          descendents = children
          params_scope.send(entity.validation_method, entity.key, documentation) do |new_param_scope|
            descendents.call(new_param_scope)
          end
        end
      end
    end
  end
end
