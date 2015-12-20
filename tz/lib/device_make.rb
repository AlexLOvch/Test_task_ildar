class DeviceMake
  def self.pluck(*fields)
    ['Tablet', 'iPhone', 'Cell Phone'].each_with_index.to_a
  end
end