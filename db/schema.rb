# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_01_09_131738) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "ltree"
  enable_extension "plpgsql"

  create_table "concepts", force: :cascade do |t|
    t.string "effectivetime", null: false
    t.string "active", null: false
    t.string "moduleid", null: false
    t.string "definitionstatusid", null: false
    t.index ["id", "effectivetime"], name: "index_concepts_on_id_and_effectivetime", unique: true
  end

  create_table "descriptions", force: :cascade do |t|
    t.string "effectivetime", null: false
    t.string "active", null: false
    t.string "moduleid", null: false
    t.string "conceptid", null: false
    t.string "languagecode", null: false
    t.string "typeid", null: false
    t.text "term", null: false
    t.string "casesignificanceid", null: false
    t.index ["id", "effectivetime"], name: "index_descriptions_on_id_and_effectivetime", unique: true
  end

  create_table "hirerachies", force: :cascade do |t|
    t.ltree "path"
  end

  create_table "relationships", force: :cascade do |t|
    t.string "effectivetime", null: false
    t.string "active", null: false
    t.string "moduleid", null: false
    t.string "sourceid", null: false
    t.string "destinationid", null: false
    t.string "relationshipgroup", null: false
    t.string "typeid", null: false
    t.text "characteristictypeid", null: false
    t.string "modifierid", null: false
    t.index ["id", "effectivetime"], name: "index_relationships_on_id_and_effectivetime", unique: true
  end

end
