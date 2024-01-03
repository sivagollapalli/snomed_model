require 'dag'
require 'csv'
require 'pry'

snomed_rel_file_path = "/Users/sivagollapalli/work/snomed-database-loader/PostgreSQL/tmp_extracted/sct2_StatedRelationship_Full_INT_20210131.txt"

hash = Hash.new

File.open(snomed_rel_file_path, 'r') do |f|
  f.each_line do |line|
    row = line.split("\t")

    source = row[4].to_s
    destination = row[5].to_s
    relation = row[7].to_s

    if hash[source].nil?
      hash[source] = []
    end

    hash[source] << destination if relation == '116680003'
  end
end

def build_or_find_vertex(dag, code)
  vertex = dag.vertices.select { |c| c[:payload][:code] == code }.first

  return vertex if vertex

  dag.add_vertex(payload: {code: code})
end

def get_path(code, hash)
  dag = DAG.new

  queue = Queue.new 
  queue.push(code)

  loop do 
    source = queue.pop
    break if hash[source].nil?
    destination = hash[source].uniq

    source_vertex = build_or_find_vertex(dag, source)

    if destination.size > 1
      destination.each do |des|
        desti_vertex =  build_or_find_vertex(dag, des)

        dag.add_edge from: source_vertex, to: desti_vertex  

        queue.push(des)

        break if des == '138875005'
      end
    else
      destination = destination.first

      destination_vertex = build_or_find_vertex(dag, destination) # dag.add_vertex(payload: {code: destination})

      dag.add_edge from: source_vertex, to: destination_vertex  
      queue.push(destination)

      break if destination == '138875005'
    end
  end

  dag
end

dag = get_path('155597006', hash)

vertex = build_or_find_vertex(dag, '155597006')

def find_all_paths(dag, start, path=[])
  path += [start]

  paths = [path]

  start.successors.each do |ver|
    newpaths = find_all_paths(dag, ver, path)

    newpaths.each do |newpath|
      paths += [newpath]
    end
  end

  paths 
end

paths = [] 

find_all_paths(dag, vertex).each do |path|
  next if path.size == 1

  vertex_str = path.map do |v| 
    v[:payload][:code]
  end.join('.')

  paths << "INSERT INTO test VALUES ('#{vertex_str}');"
end

pp paths
