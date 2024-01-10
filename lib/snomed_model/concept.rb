module SnomedModel
  class Concept < ActiveRecord::Base
    ROOT_CONCEPT = "138875005".freeze

    has_many :descriptions, -> { active }, foreign_key: :conceptid

    scope :active, -> { where(active: "1") }

    def direct_decedants
      Description
        .active
        .where(conceptid: Relationship.active.direct_decedants(id).pluck(:sourceid))
    end

    def direct_ancestors
      Description
        .active
        .where(conceptid: Relationship.active.direct_ancestors(id).pluck(:destinationid))
    end

    def detail
      Description.active.detail(id)
    end

    def build_or_find_vertex(dag, code)
      vertex = dag.vertices.detect { |c| c[:code] == code }.first
      return vertex if vertex

      dag.add_vertex(code: code)
    end

    def is_a_relationships
      Relationship.active.direct_ancestors(id)
    end
    
    def build_dag
      code = id
      dag = DAG.new
      queue = Queue.new
      queue.push(code)

      loop do
        source = queue.pop
        destinations = Concept.find(source).is_a_relationships.distinct(:destinationid).pluck(:destinationid)
        break unless destinations.any?

        source_vertex = build_or_find_vertex(dag, source)
        destinations.each do |dest|
          add_edge(dag, source_vertex, dest)
          queue.push(dest)
          break if dest == ROOT_CONCEPT
        end
      end
      dag
    end

    def add_edge(dag, source_vertex, destination)
      dest_vertex = build_or_find_vertex(dag, destination)
      dag.add_edge from: source_vertex, to: dest_vertex
    end

    def find_all_paths(dag, start, path = [])
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

    def build_paths
      dag = build_dag
      start = build_or_find_vertex(dag, id)

      find_all_paths(dag, start).each do |path|
        next if path.size == 1

        path_str = path.map do |v|
          v[:code]
        end.join(".")

        Hirerachy.create(path: path_str)
      end
    end

    def decedants
      concepts = Hirerachy.where("path ~ ?", "*.#{id}").each_with_object([]) do |h, array|
        array << h.path.split(".")
      end.flatten

      Concept.active.includes(:descriptions).where(id: concepts)
    end

    def ancestors
      concepts = Hirerachy.where("path ~ ?", "#{id}.*").each_with_object([]) do |h, array|
        array << h.path.split(".")
      end.flatten

      Concept.active.includes(:descriptions).where(id: concepts)
    end
  end
end