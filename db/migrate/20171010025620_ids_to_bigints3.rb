require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class IdsToBigints3 < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  INCLUDED_COLUMNS = [
    [:union_domains, :account_id],
    [:union_domains, :id],
  ]

  def migrate_columns(to_type)
    # Print out a warning that this will probably take a while.
    say ''
    say 'WARNING: This migration may take a *long* time for large instances'
    say 'It will *not* lock tables for any significant time, but it may run'
    say 'for a very long time. We will pause for 10 seconds to allow you to'
    say 'interrupt this migration if you are not ready.'
    say ''
    say 'This migration has some sections that can be safely interrupted'
    say 'and restarted later, and will tell you when those are occurring.'
    say ''
    say 'For more information, see https://github.com/tootsuite/mastodon/pull/5088'

    10.downto(1) do |i|
      say "Continuing in #{i} second#{i == 1 ? '' : 's'}...", true
      sleep 1
    end

    tables = INCLUDED_COLUMNS.map(&:first).uniq
    table_sizes = {}

    # Sort tables by their size
    tables.each do |table|
      table_sizes[table] = estimate_rows_in_table(table)
    end

    ordered_columns = INCLUDED_COLUMNS.sort_by do |col_parts|
      [-table_sizes[col_parts.first], col_parts.last]
    end

    ordered_columns.each do |column_parts|
      table, column = column_parts

      # Skip this if we're resuming and already did this one.
      next if column_for(table, column).sql_type == to_type.to_s

      change_column_type_concurrently table, column, to_type
      cleanup_concurrent_column_type_change table, column
    end
  end

  def up
    migrate_columns(:bigint)
  end

  def down
    migrate_columns(:integer)
  end
end
