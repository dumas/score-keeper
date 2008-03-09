require 'benchmark'

module Benchmark
  remove_method :realtime
  def realtime
    r0 = Time.now
    yield
    r1 = Time.now
    r1.to_f - r0.to_f
  end
  module_function :realtime
end