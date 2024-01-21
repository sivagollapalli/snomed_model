module SnomedModel
  class Concept < ActiveRecord::Base
    attr_accessor :paths

    ROOT_CONCEPT = "138875005".freeze
    DISEASE_CONCEPT = "64572001".freeze
    CLINICAL_FINDING = "404684003".freeze

    has_many :descriptions, -> { active }, foreign_key: :conceptid
    has_many :synonyms, -> { active.synonyms }, foreign_key: :conceptid, class_name: "Description"

    scope :active, -> { where(active: "1") }
    scope :leaf_concepts, lambda {
      concepts = SnomedModel::Relationship
                  .select("destinationid::bigint")
                  .active
                  .where(typeid: SnomedModel::Relationship::IS_A_RELATION)
                  .group(:destinationid)
                  
      SnomedModel::Concept.active.where.not(id: concepts)
    }

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
      vertex = dag.vertices.detect { |c| c[:code] == code }
      return vertex if vertex

      dag.add_vertex(code: code)
    end

    def ancestor_relationships
      Relationship.active.direct_ancestors(id)
    end

    def decedant_relationships
      Relationship.active.direct_decedants(id)
    end
    
    def build_ancestor_dag
      code = id
      dag = DAG.new
      queue = Queue.new
      queue.push(code)

      loop do
        source = queue.pop
        destinations = Concept.find(source).ancestor_relationships.distinct(:destinationid).pluck(:destinationid)
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

    def build_decedants_dag(dag)
      code = id
      queue = Queue.new
      queue.push(code)
      leaf_nodes = []

      loop do
        puts "queue length #{queue.length}"
        break if queue.empty?

        destination = queue.pop
        puts "current code is #{destination}"
        sources = Concept.find(destination).decedant_relationships.distinct(:sourceid).pluck(:sourceid)
        if sources.empty?
          leaf_nodes << destination
        end

        sources.each do |source|
          source_vertex = build_or_find_vertex(dag, source)
          add_edge(dag, source_vertex, destination)
          queue.push(source)
        end
      end
      [dag, leaf_nodes]
    end

    def add_edge(dag, source_vertex, destination)
      dest_vertex = build_or_find_vertex(dag, destination)
      dag.add_edge from: source_vertex, to: dest_vertex
    end

    def find_all_paths(dag, start, path = [])
      path += [start]
      if start[:code] == ROOT_CONCEPT
        @paths = (paths.presence || []) + [path]
        path = []
      end
      start.successors.each do |ver|
        find_all_paths(dag, ver, path)
      end

      paths
    end

    def build_paths
      dag = build_ancestor_dag

      start = build_or_find_vertex(dag, id)

      paths = find_all_paths(dag, start).map do |path|
        path_str = path.map do |v|
          v[:code]
        end.reverse.join(".")

        { path: path_str }
      end

      Hirerachy.insert_all(paths)
    end

    def fetch_concepts(paths)
      concepts = paths.each_with_object([]) do |path, array|
        array << path.subpath.split(".")
      end.flatten.uniq

      Concept.active.includes(:descriptions).where(id: (concepts - [id.to_s]))
    end

    def decedants
      fetch_concepts(Hirerachy.decedants(id))
    end

    def ancestors
      fetch_concepts(Hirerachy.ancestors(id))
    end

    def disease?
      ancestors.exists?(id: DISEASE_CONCEPT)
    end

    def clinical_finding?
      ancestors.exists?(id: CLINICAL_FINDING)
    end
  end
end