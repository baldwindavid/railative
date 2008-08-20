class Time
  def add_railative_interval(railative_interval = '', options = {})   
    options = {
      :prepend_negative => false
    }.merge(options)

    interval_arr = railative_interval.gsub(/\s*/, '').split(',').collect {|h| (options[:prepend_negative] ? '-' : '') + h}.collect {|i| i.split('.')}.collect {|j| [j.first.to_i, j.last]}

    calculated_time = self
    interval_arr.each {|i| calculated_time = calculated_time + i.first.send(i.last)}
    calculated_time
  end
end