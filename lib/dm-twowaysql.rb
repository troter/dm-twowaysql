require 'dm-do-adapter'
require 'twowaysql'

module DataMapper
  module TwoWaySQL

    def self.included(base)
      base.extend ClassMethods
      super
    end

    module ClassMethods

      # @api public
      def twowaysql(name, sql_io = nil, opts = {})
        method_name = "twowaysql_#{name}"
        variable_name = "@twowaysql_#{name}"
        raise "#{method_name} is already defined." if self.respond_to? method_name
        instance_variable_set(variable_name, ::TwoWaySQL::Template.parse(sql_io, opts))

        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.#{method_name}
            instance_variable_get "#{variable_name}"
          end
        RUBY

        instance_variable_get variable_name
      end

    end

  end

  module Adapters
    class DataObjectsAdapter

      alias :original_select :select

      # @api public
      def select(statement, *bind_values)
        if statement.instance_of?(::TwoWaySQL::Template)
          # twowaysql select
          template, data = [statement, bind_values[0]]
          merged = template.merge(data)
          original_select(merged.sql, *merged.bound_variables)
        else
          # original select
          original_select(statement, *bind_values)
        end
      end

    end
  end
end
