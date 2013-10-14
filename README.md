# Fluent::Plugin::incremental

numeric incremental output plugin for Fluentd.

## Installation

    $ fluent-gem install fluent-plugin-incremental

## parameter

param    |   value
--------|------
unit|reset cycle unit(year or month or day or hour or min)
incremental_file_path|incremental store file path
remove_tag_prefix|remove tag prefix
add_tag_prefix|add tag prefix
name_key_pattern|incremental column target , regular expression

## result example

	{"status_200_count" => "10","status_404_count" => "10"} # tag -> test.debug 
	#=> {"status_200_count" => "10","status_404_count" => "10"}
	
	{"status_200_count" => "15","status_404_count" => "20"} # tag -> test.debug
	#=> {"status_200_count" => "25","status_404_count" => "30"}

	{"status_200_count" => "15","status_404_count" => "20"} # tag -> test2.debug
	#=> {"status_200_count" => "15","status_404_count" => "20"}

	{"status_200_count" => "20","status_404_count" => "30"} # tag -> test.debug
	#=> {"status_200_count" => "45","status_404_count" => "60"}

	{"status_200_count" => "15","status_404_count" => "20"} # tag -> test2.debug
	#=> {"status_200_count" => "30","status_404_count" => "40"}


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
