class AddHirerachyTable < ActiveRecord::Migration[7.1]
  def change
    create_table :hirerachies do |t|
      t.ltree :path
    end
  end
end
