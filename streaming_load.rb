require "fileutils"
require "rubella"
require "rubella/input/base"
require "rubella/output/image"
require "rubella/output/ascii"
require "rubella/weighting/per_value"
require "rubella/weighting/per_overall_load"
require "rubella/weighting/exponential"

# Number of cores
cores   = 8
# Number of buckets
buckets = 10
# Number of columns
col     = 25
# Field size
size    = 50
# Time intervall in sec.
time    = 1

# Prepare classes
#weighting = Rubella::Weighting::PerValue.new buckets
weighting = Rubella::Weighting::PerOverallLoad.new buckets
#weighting = Rubella::Weighting::Exponential.new buckets
storage   = Rubella::Storage.new Array.new(1, Array.new(cores, 0)), col

while true
  dataset = Array.new()
  Random.new_seed
  # Generate new dataset
  i = 0
  dataset << Array.new(cores) do
    core_load = 0
    case i
    when 0
      core_load = 100
    when 1..2
      core_load = rand(80..100)
    when 3..5
      core_load = rand(50..80)
    when 7
      core_load = rand(0..15)
    else
      # Generate a value between 0 and 100
      core_load = rand(100)
    end
    i = i + 1
    core_load
  end
  #puts dataset.inspect

  # Push new dataset through input && Weight data && Add new data to storage
  new_storage = weighting.parse(Rubella::Input::Base.new(dataset))
  #puts new_storage.data.inspect
  storage = storage.add new_storage

  # Dump new image
  Rubella::Output::Image.new(storage, size).render.write("cpu_load_new.png")
  FileUtils.cp "cpu_load_new.png", "cpu_load.png"
  #puts Rubella::Output::ASCII.new(storage, size).render

  sleep(time)
end
