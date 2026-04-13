# Pop Punk Queso v1 is content-file driven.
# Seed command validates content files load successfully and prints summary.

updates = ContentRepository.updates
articles = ContentRepository.articles
home = ContentRepository.homepage

puts "Loaded #{updates.count} updates"
puts "Loaded #{articles.count} articles"
puts "Loaded #{home.fetch(:rotation, []).count} rotation tracks"
puts "Content seed check complete."
