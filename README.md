# DataMapper::TwoWaySQL

DataMapper plugin providing support for [TwoWaySQL](https://github.com/twada/twowaysql).

## Installation

Add this line to your application's Gemfile:

    gem 'dm-twowaysql'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dm-twowaysql

## Usage

    class PersonGateway
      include DataMapper::TwoWaySQL

      # define twowaysql select
      twowaysql :select, :person_index_page, <<-EOS
        SELECT * FROM people
        /*BEGIN*/WHERE
          /*IF ctx[:name]*/ name = /*ctx[:name]*/'Bob' /*END*/
          /*IF ctx[:job]*/ job = /*ctx[:job]*/'CLERK' /*END*/
          /*IF ctx[:age]*/ AND age > /*ctx[:age]*/30 /*END*/
        /*END*/
        /*IF ctx[:order_by] */ ORDER BY /*$ctx[:order_by]*/id /*$ctx[:order]*/ASC /*END*/
      EOS

      # define twowaysql execute
      twowaysql :execute, :update_all_name, <<-EOS
        UPDATE people SET name = /*ctx[:name]*/'name'
      EOS
	end

    PersonGateway.template_select_person_index_page # => TwoWaySQL::Template instance
    PersonGateway.template_execute_update_all_name  # => TwoWaySQL::Template instance

    # merged = PersonGateway.template_select_person_index_page.merge({})
    # ::DataMapper.repository(:default).adapter.select(merged.sql, *merged.bound_variables)
    PersonGateway.select_person_index_page(:default, {})

    # merged = PersonGateway.template_execute_update_all_name.merge({:name => 'jobs'})
    # ::DataMapper.repository(:default).adapter.execute(merged.sql, *merged.bound_variables)
	PersonGateway.execute_update_all_name(:default, {:name => 'jobs'})

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
