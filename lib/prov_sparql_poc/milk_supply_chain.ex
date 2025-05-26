defmodule ProvSparqlPoc.MilkSupplyChain do
  @moduledoc """
  Proof of concept for modeling milk supply chain using PROV-O ontology.

  Updated to use the correct PROV.ex API which provides RDF vocabulary namespace
  rather than helper functions.
  """

  alias PROV

  @doc """
  Creates a complete milk supply chain trace using PROV-O
  """
  def create_milk_trace(batch_id) do
    timestamp = System.system_time(:millisecond)

    # Create IRIs for all entities, activities, and agents
    milk_batch_iri = RDF.iri("http://example.org/milk/batch/#{batch_id}")
    processed_milk_iri = RDF.iri("http://example.org/milk/processed/#{batch_id}")
    packaged_milk_iri = RDF.iri("http://example.org/milk/package/#{batch_id}")

    collection_activity_iri = RDF.iri("http://example.org/activity/collection/#{batch_id}")
    processing_activity_iri = RDF.iri("http://example.org/activity/processing/#{batch_id}")
    packaging_activity_iri = RDF.iri("http://example.org/activity/packaging/#{batch_id}")

    farmer_iri = RDF.iri("http://example.org/agent/farmer/#{timestamp}")
    processor_iri = RDF.iri("http://example.org/agent/processor/#{timestamp}")
    packager_iri = RDF.iri("http://example.org/agent/packager/#{timestamp}")

    # Create all triples
    entity_triples = create_entity_triples(
      {milk_batch_iri, processed_milk_iri, packaged_milk_iri},
      timestamp
    )

    activity_triples = create_activity_triples(
      {collection_activity_iri, processing_activity_iri, packaging_activity_iri},
      timestamp
    )

    agent_triples = create_agent_triples(
      {farmer_iri, processor_iri, packager_iri}
    )

    relationship_triples = create_relationship_triples(
      {milk_batch_iri, processed_milk_iri, packaged_milk_iri},
      {collection_activity_iri, processing_activity_iri, packaging_activity_iri},
      {farmer_iri, processor_iri, packager_iri}
    )

    # Combine all triples
    entity_triples ++ activity_triples ++ agent_triples ++ relationship_triples
  end

  # Create entity triples using correct PROV.ex API
  defp create_entity_triples({milk_batch_iri, processed_milk_iri, packaged_milk_iri}, timestamp) do
    [
      # Milk batch entity
      {milk_batch_iri, RDF.type(), PROV.Entity},
      {milk_batch_iri, RDF.iri("http://example.org/provType"), RDF.literal("MilkBatch")},
      {milk_batch_iri, RDF.iri("http://example.org/volume"), RDF.literal(1000.5)},
      {milk_batch_iri, RDF.iri("http://example.org/temperature"), RDF.literal(4.2)},
      {milk_batch_iri, RDF.iri("http://example.org/fatContent"), RDF.literal(3.8)},
      {milk_batch_iri, PROV.generatedAtTime(), RDF.literal(DateTime.from_unix!(timestamp, :millisecond))},

      # Processed milk entity
      {processed_milk_iri, RDF.type(), PROV.Entity},
      {processed_milk_iri, RDF.iri("http://example.org/provType"), RDF.literal("ProcessedMilk")},
      {processed_milk_iri, RDF.iri("http://example.org/pasteurizationTemp"), RDF.literal(72.0)},
      {processed_milk_iri, RDF.iri("http://example.org/processType"), RDF.literal("UHT")},
      {processed_milk_iri, PROV.generatedAtTime(), RDF.literal(DateTime.from_unix!(timestamp + 3600, :millisecond))},

      # Packaged milk entity
      {packaged_milk_iri, RDF.type(), PROV.Entity},
      {packaged_milk_iri, RDF.iri("http://example.org/provType"), RDF.literal("PackagedMilk")},
      {packaged_milk_iri, RDF.iri("http://example.org/packageType"), RDF.literal("Tetra Pak")},
      {packaged_milk_iri, RDF.iri("http://example.org/volume"), RDF.literal(1.0)},
      {packaged_milk_iri, RDF.iri("http://example.org/units"), RDF.literal(950)},
      {packaged_milk_iri, PROV.generatedAtTime(), RDF.literal(DateTime.from_unix!(timestamp + 7200, :millisecond))}
    ]
  end

  # Create activity triples using correct PROV.ex API
  defp create_activity_triples({collection_iri, processing_iri, packaging_iri}, timestamp) do
    [
      # Collection activity
      {collection_iri, RDF.type(), PROV.Activity},
      {collection_iri, RDF.iri("http://example.org/provType"), RDF.literal("MilkCollection")},
      {collection_iri, PROV.startedAtTime(), RDF.literal(DateTime.from_unix!(timestamp, :millisecond))},
      {collection_iri, PROV.endedAtTime(), RDF.literal(DateTime.from_unix!(timestamp + 1800, :millisecond))},
      {collection_iri, RDF.iri("http://example.org/location"), RDF.literal("Farm A")},

      # Processing activity
      {processing_iri, RDF.type(), PROV.Activity},
      {processing_iri, RDF.iri("http://example.org/provType"), RDF.literal("MilkProcessing")},
      {processing_iri, PROV.startedAtTime(), RDF.literal(DateTime.from_unix!(timestamp + 1800, :millisecond))},
      {processing_iri, PROV.endedAtTime(), RDF.literal(DateTime.from_unix!(timestamp + 3600, :millisecond))},
      {processing_iri, RDF.iri("http://example.org/equipment"), RDF.literal("UHT Processor 1")},

      # Packaging activity
      {packaging_iri, RDF.type(), PROV.Activity},
      {packaging_iri, RDF.iri("http://example.org/provType"), RDF.literal("Packaging")},
      {packaging_iri, PROV.startedAtTime(), RDF.literal(DateTime.from_unix!(timestamp + 3600, :millisecond))},
      {packaging_iri, PROV.endedAtTime(), RDF.literal(DateTime.from_unix!(timestamp + 7200, :millisecond))},
      {packaging_iri, RDF.iri("http://example.org/line"), RDF.literal("Packaging Line 3")}
    ]
  end

  # Create agent triples using correct PROV.ex API
  defp create_agent_triples({farmer_iri, processor_iri, packager_iri}) do
    [
      # Farmer agent
      {farmer_iri, RDF.type(), PROV.Agent},
      {farmer_iri, RDF.iri("http://example.org/provType"), RDF.literal("DairyFarmer")},
      {farmer_iri, RDF.iri("http://example.org/name"), RDF.literal("John Smith")},
      {farmer_iri, RDF.iri("http://example.org/certification"), RDF.literal("organic-123")},

      # Processor agent
      {processor_iri, RDF.type(), PROV.Agent},
      {processor_iri, RDF.iri("http://example.org/provType"), RDF.literal("DairyProcessor")},
      {processor_iri, RDF.iri("http://example.org/name"), RDF.literal("Acme Dairy Processing")},
      {processor_iri, RDF.iri("http://example.org/certification"), RDF.literal("iso9001-456")},

      # Packager agent
      {packager_iri, RDF.type(), PROV.Agent},
      {packager_iri, RDF.iri("http://example.org/provType"), RDF.literal("Packager")},
      {packager_iri, RDF.iri("http://example.org/name"), RDF.literal("Packaging Corp")},
      {packager_iri, RDF.iri("http://example.org/facility"), RDF.literal("facility-789")}
    ]
  end

  # Create PROV-O relationship triples using correct API
  defp create_relationship_triples(
    {milk_batch_iri, processed_milk_iri, packaged_milk_iri},
    {collection_iri, processing_iri, packaging_iri},
    {farmer_iri, processor_iri, packager_iri}
  ) do
    [
      # Generation relationships (wasGeneratedBy)
      {milk_batch_iri, PROV.wasGeneratedBy(), collection_iri},
      {processed_milk_iri, PROV.wasGeneratedBy(), processing_iri},
      {packaged_milk_iri, PROV.wasGeneratedBy(), packaging_iri},

      # Attribution relationships (wasAttributedTo)
      {milk_batch_iri, PROV.wasAttributedTo(), farmer_iri},
      {processed_milk_iri, PROV.wasAttributedTo(), processor_iri},
      {packaged_milk_iri, PROV.wasAttributedTo(), packager_iri},

      # Association relationships (wasAssociatedWith)
      {collection_iri, PROV.wasAssociatedWith(), farmer_iri},
      {processing_iri, PROV.wasAssociatedWith(), processor_iri},
      {packaging_iri, PROV.wasAssociatedWith(), packager_iri},

      # Usage relationships (used) - supply chain flow
      {processing_iri, PROV.used(), milk_batch_iri},
      {packaging_iri, PROV.used(), processed_milk_iri},

      # Derivation relationships (wasDerivedFrom) - traceability
      {processed_milk_iri, PROV.wasDerivedFrom(), milk_batch_iri},
      {packaged_milk_iri, PROV.wasDerivedFrom(), processed_milk_iri}
    ]
  end
end
