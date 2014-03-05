class CreateDsElements < ActiveRecord::Migration
  def change
    create_table :ds_elements do |t|
      t.string :fullpath
      t.string :prop
      t.string :datatype
      t.text :description
      t.datetime :lastseen

      t.timestamps
    end
  end
end
