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
      def twowaysql(execute_type, name, sql_io, opts = {})
        variable_name = "@twowaysql_template_#{execute_type}_#{name}"
        raise "#{variable_name} is already defined." if instance_variable_defined? variable_name
        raise "#{execute_type} is not :select or :execute" unless [:select, :execute].include?(execute_type)
        instance_variable_set(variable_name, ::TwoWaySQL::Template.parse(sql_io, opts))

        template_getter = "self.template_#{execute_type}_#{name}"
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{template_getter}
            instance_variable_get "#{variable_name}"
          end

          def self.#{execute_type}_#{name}(repository_name, data)
            merged = #{template_getter}.merge(data)
            ::DataMapper.repository(repository_name).adapter.#{execute_type}(merged.sql, *merged.bound_variables)
          end
        RUBY

        instance_variable_get variable_name
      end

    end

  end
end
