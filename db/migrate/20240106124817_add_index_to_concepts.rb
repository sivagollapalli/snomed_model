class AddIndexToConcepts < ActiveRecord::Migration[7.1]
  def change
    add_index :concepts, [:id, :effectivetime], unique: true
  end
end
