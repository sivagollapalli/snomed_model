class AddDescriptionTable < ActiveRecord::Migration[7.1]
  def change
    create_table :descriptions do |t|
      t.string :effectivetime, null: false
      t.string :active, null: false
      t.string :moduleid, null: false
      t.string :conceptid, null: false
      t.string :languagecode, null: false
      t.string :typeid, null: false
      t.text :term, null: false
      t.string :casesignificanceid, null: false
    end

    add_index :descriptions, [:id, :effectivetime], unique: true
  end
end
