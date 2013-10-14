# Fluent::Plugin::incremental

number incremental output plugin for Fluentd.

## Installation

    $ fluent-gem install fluent-plugin-incremental

## parameter

param    |   value
--------|------


## Configuration

	<match test.*>
	  type incremental
	  unit hour
	  incremental_file_path /tmp/input
	  remove_tag_prefix    test.
	  add_tag_prefix       debug.
	  name_key_pattern     .+_count$
	</match>
	
	<match debug.*>
	  type file
	  path /tmp/output
	</match>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
