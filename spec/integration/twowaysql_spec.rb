require 'spec_helper'

describe 'DataMapper::TwoWaySQL' do

  class ::Employee
    include DataMapper::TwoWaySQL
    twowaysql :find, <<-EOS
      SELECT * FROM emp
      /*BEGIN*/WHERE
        /*IF ctx[:job]*/ job = /*ctx[:job]*/'CLERK' /*END*/
        /*IF ctx[:deptno_list]*/ AND deptno IN /*ctx[:deptno_list]*/(20, 30) /*END*/
        /*IF ctx[:age]*/ AND age > /*ctx[:age]*/30 /*END*/
      /*END*/
      /*IF ctx[:order_by] */ ORDER BY /*$ctx[:order_by]*/id /*$ctx[:order]*/ASC /*END*/
    EOS
  end

  class ::Mushroom
    include DataMapper::TwoWaySQL
    twowaysql :find, <<-EOS
      SELECT * FROM mushrooms
      /*BEGIN*/WHERE
        /*IF ctx[:name]*/ name = /*ctx[:name]*/'CLERK' /*END*/
      /*END*/
    EOS
  end

  describe "#twowaysql :find" do
    it "should define twowaysql_find method" do
      Employee.respond_to?(:twowaysql_find).should be_true
      Mushroom.respond_to?(:twowaysql_find).should be_true
    end

    it "raise error when passed duplicate name" do
      lambda do
        class ::Mushroom
          include DataMapper::TwoWaySQL
          twowaysql :find, "select * from mashrooms"
        end
      end.should raise_error
    end

    describe "#twowaysql_find" do
      it "should return object instance_of ::TwoWaySQL::Template" do
        Employee.twowaysql_find.should be_instance_of(::TwoWaySQL::Template)
        Mushroom.twowaysql_find.should be_instance_of(::TwoWaySQL::Template)
      end

      it "should return " do
        Employee.twowaysql_find.merge({}).sql.should eql("      SELECT * FROM emp\n      \n      \n")
        Mushroom.twowaysql_find.merge({}).sql.should eql("      SELECT * FROM mushrooms\n      \n")
      end
    end
  end
end
