class SearchController < ApplicationController
  def index
    posts = []
    users = []
    posts_trending = []
    select_string = "
      users.username as author_username, users.name as author_name, users.avatar_url as author_avatar,
      posts.*, posts.pin_status as pin_status_int, posts.who_can_comment as who_can_comment_int
    "
    filters = { top: 0, latest: 1, people: 2, media: 3 }.with_indifferent_access

    if params[:q]

      if params[:f]
        current_f = filters[params[:f]]
        case current_f
        when filters[:top]
          users = User.joins(:followers)
                      .select('follows.*, users.*')
                      .where('users.username LIKE ? OR users.name LIKE ?', "%#{params[:q]}%", "%#{params[:q]}%")
                      .group("users.id, follows.id")
                      .order('COUNT(users.id) DESC')
                      .uniq
          # .limit(3)
          users = users.slice(0, 3)

          posts = Post.joins(:likes, :user)
                      .select(select_string)
                      .filter_content_include_user(params[:q])
                      .group("posts.id, likes.id, users.id")
                      .order('likes_count desc')
                      .uniq
          # .page(params[:page]).per(params[:limit])

        when filters[:latest]

          posts = Post.joins(:user)
                      .select(select_string)
                      .order('created_at DESC')
                      .filter_content_include_user(params[:q])
                      .order('created_at DESC')
                      .page(1).per(10)
          # .page(params[:page]).per(params[:limit])
        when filters[:people]
          users = User.filter_by_username_name(params[:q]).page(1).per(10)

        when filters[:media]
          posts = Post.joins(:user)
                      .select(select_string)
                      .filter_content_include_user(params[:q])
                      .where.not(image_url: nil)
                      .page(1).per(10)
          # .page(params[:page]).per(params[:limit])
        else
          p 'else'
        end

        if current_user

          if users.length > 0
            followed_id = Follow.where(follower_id: current_user.id, followed_id: users.map(&:id)).pluck :followed_id
            users = users.map do |user|
              user.attributes.merge({
                                      is_current_user_following: followed_id.include?(user.id),
                                      followed_count: user.followings.size,
                                      followers_count: user.followers.size,
                                    })
            end
          end

          if posts.length > 0
            arr_post_id_liked = Like
                                  .where(post_id: posts.map(&:id), user_id: current_user.id)
                                  .pluck(:post_id)

            posts = posts.map do |p|
              p.attributes.merge({ is_current_user_like: arr_post_id_liked.include?(p.id) })
            end
          end
        end

      else
        # posts = Post.joins(:user).select(select_string).filter_by_content(params[:q]).order(created_at: :desc).limit(5)
        users = User.filter_by_username_name(params[:q]).order(created_at: :desc).limit(10)
      end

    else
      hashtags = Hashtag.select([:text]).group(:text).having("count(text) > 1").all.size
      hashtags_sorted = hashtags.sort_by(&:last).reverse[0, 5]

      hashtags_sorted.each do |p|
        hashtag = p[0]
        posts_trending << Post.filter_by_content(hashtag).order(created_at: :desc).first
      end
    end

    render json: {
      posts: posts,
      users: users,
      # hashtags: hashtags,
      # hashtags_sorted: hashtags_sorted,
      # posts_trending: posts_trending,
    }
  end

end
