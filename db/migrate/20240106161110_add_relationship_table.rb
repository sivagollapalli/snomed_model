class AddRelationshipTable < ActiveRecord::Migration[7.1]
  def change
    create_table :relationships do |t|
      t.string :effectivetime, null: false
      t.string :active, null: false
      t.string :moduleid, null: false
      t.string :sourceid, null: false
      t.string :destinationid, null: false
      t.string :relationshipgroup, null: false
      t.string :typeid, null: false
      t.text :characteristictypeid, null: false
      t.string :modifierid, null: false
    end

    add_index :relationships, [:id, :effectivetime], unique: true
  end
end
