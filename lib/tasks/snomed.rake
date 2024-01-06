require 'pry'
namespace :snomed do 
  task :load_concepts, [:arg] do |_, args|
    file = args[:arg]
    records = []

    File.open(file, "r") do |f|
      f.each_line do |line|
        row = line.split("\t")
        
        next if row[0] == "id"
        
        records << {
          id: row[0],
          effectivetime: row[1],
          active: row[2],
          moduleid: row[3],
          definitionstatusid: row[4].to_i
        }
      end
    end
    SnomedModel::Concept.insert_all(records)
  end

  task :load_descriptions, [:arg] do |_, args|
    file = args[:arg]
    records = []

    File.open(file, "r") do |f|
      f.each_line do |line|
        row = line.split("\t")
        
        next if row[0] == "id"
        
        records << {
          id: row[0],
          effectivetime: row[1],
          active: row[2],
          moduleid: row[3],
          conceptid: row[4],
          languagecode: row[5],
          typeid: row[6],
          term: row[7],
          casesignificanceid: row[8].to_i
        }
      end
    end
    records.each_slice(10000) do |batch|
      p "Inserting batch....."
      SnomedModel::Description.insert_all(batch)
    end
  end
end
