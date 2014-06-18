class AddLastValue < ActiveRecord::Migration
  def change
  	add_column	:ds_elements,	:last_value,	:text
  end
end
