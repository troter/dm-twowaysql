require 'spec_helper'

describe 'DataMapper::TwoWaySQL' do

  class ::Employee
    include DataMapper::TwoWaySQL
    twowaysql :select, :emp_index_page, <<-EOS
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
    twowaysql :select, :by_name, <<-EOS
      SELECT * FROM mushrooms
      /*BEGIN*/WHERE
        /*IF ctx[:name]*/ name = /*ctx[:name]*/'CLERK' /*END*/
      /*END*/
    EOS
    twowaysql :execute, :update_all_name, <<-EOS
      UPDATE mushrooms SET
        name = /*ctx[:name]*/''
    EOS
  end

  describe "#twowaysql" do
    it "should define tempalte_\#{execute_type}_\#{name} method" do
      Employee.respond_to?(:template_select_emp_index_page).should be_true
      Mushroom.respond_to?(:template_select_by_name).should be_true
      Mushroom.respond_to?(:template_execute_update_all_name).should be_true
    end

    it "should define select_\#{name} method" do
      Employee.respond_to?(:select_emp_index_page).should be_true
      Mushroom.respond_to?(:select_by_name).should be_true
    end

    it "should define execute_\#{name} method" do
      Mushroom.respond_to?(:execute_update_all_name).should be_true
    end

    it "raise error when passed duplicate name" do
      lambda do
        class ::Mushroom
          include DataMapper::TwoWaySQL
          twowaysql :select, :by_name, "select * from mashrooms"
        end
      end.should raise_error
    end

    it "raise error when passed invalid execute_type" do
      lambda do
        class ::Mushroom
          include DataMapper::TwoWaySQL
          twowaysql :selecta, :all, "select * from mashrooms"
        end
      end.should raise_error
    end

    describe "#template_\#{execute_type}_\#{name}" do
      it "should return object instance_of ::TwoWaySQL::Template" do
        Employee.template_select_emp_index_page.should be_instance_of(::TwoWaySQL::Template)
        Mushroom.template_select_by_name.should be_instance_of(::TwoWaySQL::Template)
        Mushroom.template_execute_update_all_name.should be_instance_of(::TwoWaySQL::Template)
      end

      it "should return " do
        Employee.template_select_emp_index_page.merge({}).sql.should eql("      SELECT * FROM emp\n      \n      \n")
        Mushroom.template_select_by_name.merge({}).sql.should eql("      SELECT * FROM mushrooms\n      \n")
        Mushroom.template_execute_update_all_name.merge({:name => 'shiitake'}).sql.should eql("      UPDATE mushrooms SET\n        name = ?\n")
      end
    end
  end
end
