class HashtagsController < ApplicationController
  def index
    hashtags = Hashtag.group(:text).limit(10).pluck("text, count(text)")
    hashtags = hashtags.map { |h| { name: h[0], count: h[1] } }
    render json: { hashtags: hashtags }
  end
end
