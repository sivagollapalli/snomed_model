class AddConceptTable < ActiveRecord::Migration[7.1]
  def change
    create_table :concepts do |t|
      t.string :effectivetime, null: false
      t.string :active, null: false
      t.string :moduleid, null: false
      t.string :definitionstatusid, null: false
    end
  end
end
