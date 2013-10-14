module Fluent
  class IncrementalOutput < Fluent::Output
    Fluent::Plugin.register_output('incremental', self)

    config_param :unit
    config_param :incremental_file_path
    config_param :add_tag_prefix
    config_param :remove_tag_prefix
    config_param :name_key_pattern, :default => nil

    def initialize
      Encoding.default_internal = "UTF-8"
      super
    end

    def configure(conf)
      super
      if @unit.nil? || @unit.empty?
        raise ConfigError, "incremental configure requires 'unit'"
      else
        if @unit != "hour" and @unit != "day" and @unit != "month" and @unit != "year" and @unit != "min"
          raise ConfigError, "incremental configure unit allow year or month or day or hour or min"
        end
      end
      if @incremental_file_path.nil? || @incremental_file_path.empty?
        raise ConfigError, "incremental configure requires 'incremental_file_path'"
      end
      if @add_tag_prefix.nil? || @add_tag_prefix.empty?
        raise ConfigError, "incremental configure requires 'add_tag_prefix'"
      end
      if @remove_tag_prefix.nil? || @remove_tag_prefix.empty?
        raise ConfigError, "incremental configure requires 'remove_tag_prefix'"
      end
      @time_format = "%Y-%m-%d %H:%M:%S"
      @timestamp_key = "last_updated"
    end

    def emit(tag, es, chain)
      filepath = @incremental_file_path + "." + tag
      result = get_result(filepath)
      es.each do | time, record|
        record.each {|key,value| 
          next if (value =~ /^[+-]?\d+$/) == nil
          unless @name_key_pattern.nil?
            next if key !~ /#{@name_key_pattern}/
          end
          result[key] = (result[key].nil? ? 0 : result[key]) + value.to_i 
        }
      end
      result[@timestamp_key] = Time.now.strftime(@time_format)
      write_file(result,filepath)
      result.delete(@timestamp_key)
      Fluent::Engine.emit(tag.gsub(@remove_tag_prefix,@add_tag_prefix), Fluent::Engine.now, result)
    end

    private

    def write_file(result,filepath)
      dump = Marshal.dump(result)
      File.open(filepath,'w') { |file|
        file.print dump
        file.close
      }
    end

    def get_result(filepath)
      if File.exist?(filepath)
        if File.read(filepath).size == 0
          result = Hash.new
        else
          result = Marshal.load(File.read(filepath))
          if @unit == 'year'
            if Time.now.year != Time.strptime(result[@timestamp_key],@time_format).year
              result = Hash.new
            end
          elsif @unit == 'month'
            if Time.now.month != Time.strptime(result[@timestamp_key],@time_format).month
              result = Hash.new
            end
          elsif @unit == 'day'
            if Time.now.day != Time.strptime(result[@timestamp_key],@time_format).day
              result = Hash.new
            end
          elsif @unit == 'hour'
            if Time.now.hour != Time.strptime(result[@timestamp_key],@time_format).hour
              result = Hash.new
            end
          elsif @unit == 'min'
            if Time.now.min != Time.strptime(result[@timestamp_key],@time_format).min
              result = Hash.new
            end
          end
        end
      else # not exist file
        result = Hash.new
      end
      return result
    end
  end
end
