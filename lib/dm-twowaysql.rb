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
        variable_name = "@twowaysql_#{name}"
        raise "#{variable_name} is already defined." if instance_variable_defined? variable_name
        instance_variable_set(variable_name, ::TwoWaySQL::Template.parse(sql_io, opts))

        template_getter = "self.template_#{name}"
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{template_getter}
            instance_variable_get "#{variable_name}"
          end
        RUBY

        select_method = "self.select_#{name}"
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{select_method}(repository_name, data)
            merged = #{template_getter}.merge(data)
            ::DataMapper.repository(repository_name).adapter.select(merged.sql, *merged.bound_variables)
          end
        RUBY

        instance_variable_get variable_name
      end

    end

  end
end
