require 'mechanize'
require 'date'
require 'json'

agent = Mechanize.new
page = agent.get("http://pitchfork.com/reviews/albums/")

review_links = page.links_with(href: %r{^/reviews/albums/\w+})

review_links = review_links.reject do |link|
  parent_classes = link.node.parent['class'].split
  parent_classes.any? { |p| %w[next-container page-number].include?(p) }
end

review_links = review_links[0...10]

reviews = review_links.map do |link|
  review = link.click
  artist = review.search('.artist-links').text
  album = review.search('.single-album-tombstone__review-title').text
  label, year = review.search('.single-album-tombstone__meta').text.split('•').map(&:strip)
  slug = review.search('.genre-list__link').text
  reviewer = review.search('.authors-detail__display-name').text
  review_date = Time.parse(review.search('.pub-date')[0]['title'])
  score = review.search('.score').text.to_f
  {
    artist: artist,
    album: album,
    label: label,
    year: year,
    reviewer: reviewer,
    slug: slug,
    review_date: review_date,
    score: score
  }
end

puts JSON.pretty_generate(reviews)
