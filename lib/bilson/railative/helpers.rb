module Bilson
  module Railative
    module Helpers
 
 
    
      def railative_interval_to_db(railative_interval = '', options = {})
        options = {
          :prepend_negative => false
        }.merge(options)
        railative_interval = railative_interval.gsub(/\s*/, '').split(',').collect {|i| (options[:prepend_negative] ? '-' : '') + i}.join(", ")
        railative_interval
      end


      def railative_interval_to_pretty(railative_interval = '', options = {})
        options = {
          :strip_negative => false 
        }
        railative_interval = railative_interval.gsub(/\s*/, '').gsub(/\./, ' ').gsub(/\,/, ', ')
        railative_interval = railative_interval.gsub(/\-/, '') if options[:strip_negative]
        railative_interval
      end



      def mirrored_time_options(time_intervals, options = {})
        options = {
          :before_prefix => '',
          :before_suffix => '',

          :before_interval_suffix => '',
          :before_timestamp_prefix => '',
          
          :after_prefix => '',
          :after_suffix => '',
          
          :after_interval_suffix => '',
          :after_timestamp_prefix => '',
          
          :median_time => 0,
          :median_time_label => '-- At the same time --',
          :label_timestamp_format => nil,
          :interval_and_timestamp_label => false,
          :interval_and_timestamp_label_divider => ' => ',
          :value_timestamp_format => nil,
          :display_before_options => true,
          :display_median_time_option => true,
          :display_after_options => true
        }.merge(options)

        times = {
          'before' => {
            :options => time_intervals,
            :operator =>'-'
          },
          'after' => { 
            :options => [], 
            :operator => '+'

          }
        }

        times['before'][:options].reverse.each do |o|
          times['after'][:options] << o
        end

        times.each do |key, side|
          side[:options].collect! do |item|

            if item.is_a?(Array)
              label_override = item[0]          
              item = item[1]
              item_representation = nil
            else
              label_override = nil
              item = item
              item_representation = nil
            end

            if item.is_a?(String)
              raise 'Please enter a :median_time Time object' unless options[:median_time].is_a?(Time)
              item_representation = railative_interval_to_db(item, :prepend_negative => (side[:operator] == '-'))
              item_label = railative_interval_to_pretty(item)          
              calculated_time = options[:median_time].add_railative_interval(item, :prepend_negative => (side[:operator] == '-'))
            end



            if !label_override.blank?
              label = label_override
            else     
              label = options["#{key}_prefix".to_sym]

              if options[:label_timestamp_format].blank? || options[:interval_and_timestamp_label]

                if !item_representation.blank?
                  label = label + item_label
                else
                  if item.seconds < 86400
                    label = label + case item.seconds
                      when 0..59   then "#{item.seconds} seconds"
                      when 60 then "1 minute"
                      when 61..3599   then "#{item.seconds / 60} minutes"
                      when 3600 then "1 hour"
                      when 3601..7199 then "#{item.seconds / 60} minutes"
                      when 7200..86399 then "#{item.seconds / 3600} hours"
                    end
                  else
                    label = label + item.inspect
                  end
                end

                if options[:interval_and_timestamp_label]
                  label = label + options["#{key}_interval_suffix".to_sym]
                end
              end

              if (!options[:label_timestamp_format].blank? || options[:interval_and_timestamp_label]) && options[:median_time].is_a?(Time)
                if options[:interval_and_timestamp_label]
                  label = label + options[:interval_and_timestamp_label_divider]
                  label = label + options["#{key}_timestamp_prefix".to_sym]
                end

                if !item_representation.blank?
                  label = label + calculated_time.to_s(options[:label_timestamp_format])
                else
                  label = label + options[:median_time].send(side[:operator], item).to_s(options[:label_timestamp_format])
                end
              end

              label = label + options["#{key}_suffix".to_sym]

            end



            if !item_representation.blank?
              value = item_representation
            else
              if options[:median_time].is_a?(Time)
                if !options[:value_timestamp_format].blank?
                  value = (options[:median_time].send(side[:operator], item)).to_s(options[:value_timestamp_format])
                else
                  new_time = options[:median_time].send(side[:operator], item)
                  if side[:operator] == '-'
                    seconds_difference = options[:median_time] - new_time
                  else
                    seconds_difference = new_time - options[:median_time]
                  end
                  value = (side[:operator] == '-' ? -seconds_difference : seconds_difference).to_i
                end
              else
                value = (side[:operator] == '-' ? -item : item).to_i
              end
            end


            [label, value]        
          end
        end



        if options[:median_time].is_a?(Time) && !options[:value_timestamp_format].blank?
          median_time_option = [ options[:median_time_label], options[:median_time].to_s(options[:value_timestamp_format]) ]
        else
          median_time_option = [ options[:median_time_label], 0 ]
        end



        final_array = []
        final_array += times['before'][:options] if options[:display_before_options]
        final_array += [median_time_option] if options[:display_median_time_option]
        final_array += times['after'][:options] if options[:display_after_options]
        final_array
      end
    
    end    
  end   
end