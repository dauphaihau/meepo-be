class SearchController < ApplicationController
  def index
    posts = []
    users = []
    total_users = 0
    total_posts = 0
    select_string = "
      users.username as author_username, users.name as author_name, users.avatar_url as author_avatar_url,
      posts.*, posts.pin_status as pin_status_int, posts.who_can_comment as who_can_comment_int
    "
    filters = { top: 0, latest: 1, people: 2, media: 3 }.with_indifferent_access

    if params[:q]

      if params[:f]
        current_f = filters[params[:f]]
        limit_user = 3

        case current_f
        when filters[:top]
          users = User.joins(:followers)
                      .select('follows.*, users.*')
                      .where('users.username LIKE ? OR users.name LIKE ?', "%#{params[:q]}%", "%#{params[:q]}%")
                      .group('users.id, follows.id')
                      .order('COUNT(users.id) DESC')
                      .uniq
          # .limit(3)
          users = users.slice(0, limit_user)

          total_posts = Post.joins(:user)
                            .filter_content_include_user(params[:q])
                            .count

          posts = Post.joins(:user)
                      .select(select_string)
                      .filter_content_include_user(params[:q])
                      .order('likes_count DESC')
                      .page(params[:page])
                      .per(params[:limit])

        when filters[:latest]
          total_posts = Post.joins(:user)
                            .filter_content_include_user(params[:q])
                            .count

          posts = Post.joins(:user)
                      .select(select_string)
                      .order('created_at DESC')
                      .filter_content_include_user(params[:q])
                      .order('created_at DESC')
                      .page(params[:page])
                      .per(params[:limit])

        when filters[:people]
          total_users = User.filter_by_username_name(params[:q]).count
          users = User.filter_by_username_name(params[:q])
                      .page(params[:page])
                      .per(params[:limit])

        when filters[:media]
          total_posts = Post.joins(:user)
                            .filter_content_include_user(params[:q])
                            .where.not(image_url: nil)
                            .count
          posts = Post.joins(:user)
                      .select(select_string)
                      .filter_content_include_user(params[:q])
                      .where.not(image_url: nil)
                      .page(params[:page]).per(params[:limit])
        else
          p 'else'
        end

        followed_ids = []
        if current_user && users
          followed_ids = Follow
                         .where(follower_id: current_user.id, followed_id: users.map(&:id))
                         .pluck :followed_id
        end

        if users && users.length > 0
          users = users.map do |user|
            hash = {}
            hash['is_current_user_following'] = followed_ids.include?(user.id) if current_user
            user = hash.merge(user.as_json)
            user.delete('by')
            user
          end
        end

        if posts && posts.length > 0
          arr_post_id_liked = []
          if current_user
            arr_post_id_liked = Like
                                .where(post_id: posts.map(&:id), user_id: current_user.id)
                                .pluck(:post_id)
          end

          posts = posts.map do |post|
            user = User.find(post.user_id)
            hash = {}
            # hash = {
            #   author_followed_count: user.followings.size,
            #   author_followers_count: user.followers.size,
            # }

            if current_user
              # is_current_user_following = Follow.where(follower_id: current_user.id, followed_id: post.user_id).first
              hash['is_current_user_like'] = arr_post_id_liked.include?(post.id)
              # hash['is_current_user_following'] = is_current_user_following.present?
            end

            post = post.as_json.merge(hash)
            post.delete('by')
            post.delete('who_can_comment')
            post.delete('pin_status')
            post
          end
        end

      else
        # posts = Post.joins(:user).select(select_string).filter_by_content(params[:q]).order(created_at: :desc).limit(5)
        users = User.filter_by_username_name(params[:q]).order(created_at: :desc).limit(10)
      end

    end

    render json: {
      posts: posts,
      users: users,
      total_users: total_users,
      total_posts: total_posts,
    }
  end

end
