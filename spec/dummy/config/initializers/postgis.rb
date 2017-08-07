# frozen_string_literal: true

ActiveRecord::SchemaDumper.ignore_tables = %w[geography_columns
                                              geometry_columns
                                              raster_columns
                                              raster_overviews
                                              spatial_ref_sys]
