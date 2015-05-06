require "git"
require "rubella"
require "rubella/output/image"
require "rubella/weighting/per_count"

# Get git history
repository = Git.open("../rubella/")
git_log = repository.log(1000000).since('1 year ago')

# Create an commit per day array
current_date = Time.now
commits_per_day = Array.new(1, 0)
git_log.each do |commit|
  # Insert 0 until the date fits
  until current_date.year == commit.date.year and
       current_date.month == commit.date.month and
         current_date.day == commit.date.day
    commits_per_day.insert(0, 0)
    current_date = current_date - (60*60*24)
  end
  commits_per_day[0] = commits_per_day.first + 1
end

# Give rubella this array
# Prepare classes
weighting = Rubella::Weighting::PerCount.new

storage = weighting.parse commits_per_day

# Get a heatmap of your commits
image = Rubella::Output::Image.new(storage, 15)
#image.background_color = "black"
image.render.write("git_commits.png")

