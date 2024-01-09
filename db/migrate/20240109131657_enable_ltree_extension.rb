class EnableLtreeExtension < ActiveRecord::Migration[7.1]
  def change
    enable_extension "ltree"
  end
end
