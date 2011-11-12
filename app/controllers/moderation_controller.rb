class ModerationController < ApplicationController
  layout 'forum'
  
  before_filter :get_user
  before_filter :allow_user_perform_action, :except => ['message']
  before_filter :fill_board_skin
  before_filter :check_selected_topics, :only => ['index']
  after_filter :set_user_timestamp
  after_filter :remove_online2
  after_filter :check_online3
    
  def index
    self.send(params[:commit].downcase, params) if params[:commit]
  end
    
  def moderate
    if Subpartition.exists?(params[:id])
      @subpart = Subpartition.find_by_id(params[:id])
      @topics = Topic.paginate :conditions => ["subpartition_id = ?", params[:id]], :page => params[:page], :order => 'last_post DESC', :per_page => @usr.pagination_topics_amount
      render :template => 'forum/view_topics' and return
    else
      redirect_to_error_page t(:not_exists)
      return
    end
  end
      
  def posts_moderate
    if Topic.exists?(params[:topic_id])
      @post = Post.paginate :conditions => ["topic_id = ?", params[:topic_id]], :page => params[:page], :order => 'posted asc', :per_page => @usr.pagination_posts_amount
      @postnumber =  Configs.get_config('postsperpage').to_i * (params[:page].to_i - 1)
      @topic = @post.first.topic
      @subpart = @topic.subpartition
      @allow_cens = Configs.get_config('allow_cens').to_bool
      if Configs.get_config('show_views').to_bool
        @post.first.topic.increment!(:num_views)
      end
      render :template => 'moderation/posts_moderate' and return
    else
      redirect_to_error_page t(:not_exists)
    end
  end
    
  def message
    flash.keep
  end

private

  def check_selected_topics
    if params[:selected_topic].blank? && params[:selected_post].blank?
      if params[:selected_topic].nil?
        flash[:forum_message] = t(:sel_topic)
        redirect_to :action => 'message' and return
      elsif params[:selected_post].nil?
        flash[:forum_message] = t(:sel_post)
        redirect_to :action => 'message' and return
      end
    end
    params[:commit] = 'delete_selected_posts' if params.has_key?('delete_selected_posts')
    params[:commit] = 'split_selected_posts' if params.has_key?('split_selected_posts')
    params[:commit] = 'delete_this_topic' if params.has_key?('delete_this_topic')
    @subpartition_id = params[:id]
  end

  def move params
    if Subpartition.count < 2
      redirect_to_error_page t(:not_exists)
      return
    end
    @forums =  create_forums_optgroup([params[:id], 0])
    if params[:moved_to]
      if params[:commit] == 'Move'
        Topic.move_topics params[:selected_topic], params[:moved_to], params[:redirect_allowed]
      end
      redirect_to :action => 'moderate', :id => params[:id], :page => params[:page]
      return
    end
    render :action => "move"
    return
  end
        
  def delete params
    if params[:commit] == 'Delete' && params[:delete_confirmation]
      Subpartition.find(params[:id]).decrease_num_posts(params[:selected_topic].keys)
      Subpartition.find(params[:id]).decrease_num_topics(params[:selected_topic].keys)
      Topic.destroy(params[:selected_topic].keys)
    else
      render :action => 'delete' and return
    end
    #redirect_to :action => 'moderate', :id => params[:id], :page => params[:page]
    if params[:page]
      redirecting t(:r_deleted), "/moderation/moderate/#{params[:id]}?page=#{params[:page]}"
    else
      redirecting t(:r_deleted), "/moderation/moderate/#{params[:id]}"
    end
  end
    
  def merge params
    redirect_to_error_page(t(:more_than_one)) and return if params[:selected_topic].keys.size < 2
    sort_topics = Topic.find(params[:selected_topic].keys).sort{|first,second| first.first_post_object.posted <=> second.first_post_object.posted}
    first_topic = sort_topics.first
    (sort_topics - [first_topic]).each {|topic| topic.posts.each{|post| post.update_attribute(:topic_id, first_topic.id); first_topic.increment!(:num_replies) } }
    Topic.destroy(  (sort_topics - [first_topic]).map(&:id) )
    redirect_to :action => 'moderate', :id => params[:id], :page => params[:page]
  end
    
  def open params
    Topic.find(params[:selected_topic].keys).each {|topic| topic.update_attribute(:closed, false)}
    redirecting t(:redir), session[:last_page]
    return
  end
    
  def close params
    Topic.find(params[:selected_topic].keys).each {|topic| topic.update_attribute(:closed, true)}
    redirecting t(:redir), session[:last_page]
    return
  end
    
  def stick params
    if params[:selected_topic] && Topic.exists?(params[:selected_topic])
      Subpartition.find(params[:id]).topics.find{|topic| topic.id == params[:selected_topic].to_i}.update_attribute(:sticky, true)
    end
    redirecting t(:redir), session[:last_page]
    return
  end
      
  def unstick params
    if params[:selected_topic] && Topic.exists?(params[:selected_topic])
      Subpartition.find(params[:id]).topics.find{|topic| topic.id == params[:selected_topic].to_i}.update_attribute(:sticky, false)
    end
    redirecting t(:redir), session[:last_page]
    return
  end

  def delete_selected_posts params
    if params[:delete_selected_posts].include?('Delete') && params[:delete_post_confirmation]
      if params[:selected_post].keys.include?(Post.find(params[:selected_post].keys.first).topic.first_post_id.to_s)
        redirect_to_error_page t(:r_cannot_del)
        return
      end
      Post.destroy(params[:selected_post].keys)
    else
      render :action => 'delete_selected_posts' and return
    end
    redirecting t(:r_del), session[:last_page]
  end

  def split_selected_posts params
    if params[:split_selected_posts].include?('Split') && params[:split_post_confirmation]
      if params[:title].blank? || params[:title].size > 255
        @subj_missing = t(:subj_miss)
        render :action => 'split_selected_posts' and return
      end
      if params[:selected_post].keys.size < 2
        redirect_to_error_page t(:at_least_two)
        return
      end
      begin
        splitted_size = Post.find(params[:selected_post].keys).size
        sliced_posts = Post.find(params[:selected_post].keys).sort{|f,s| f.posted <=> s.posted}.values_at(0, splitted_size - 1)
        if params[:selected_post].keys.include?(sliced_posts.first.topic.first_post_id.to_s)
          redirect_to_error_page t(:cannot_split)
          return
        end
        splitted_topic = Topic.create(:subpartition_id => params[:id], :poster => sliced_posts.first.poster, :title => params[:title], :first_post_id => sliced_posts.first.id, :last_post => sliced_posts.last.posted,
          :last_post_id => sliced_posts.last.id, :last_poster => sliced_posts.last.poster, :num_views => 0, :num_replies => splitted_size - 1, :poster_id => sliced_posts.first.poster_id,
          :closed => false, :sticky => false, :moved_to => 0)
        sliced_posts.each{|post| post.update_attribute(:topic_id, splitted_topic.id)} if splitted_topic
        Topic.update(sliced_posts.first.topic.id, :num_replies => sliced_posts.first.topic.num_replies - splitted_size)
        redirecting t(:r_post_splitted), session[:last_page]
        return
      rescue Exception
        @posts_missing = t(:posts_miss)
        render :action => 'split_selected_posts' and return
      end
    end
    render :action => 'split_selected_posts' and return
  end

  def delete_this_topic params
    @topic = Topic.find(params[:selected_topic])
    if params[:delete_this_topic] == 'Delete' && Subpartition.find(params[:id]).topics.map(&:id).include?(params[:selected_topic].to_i)
      @topic.destroy
      redirecting t(:r_removed), "/forum/view_topics/#{params[:id]}"
      return
    elsif params[:delete_this_topic] == 'Cancel'
      redirecting t(:r_cancelled), "/forum/view_posts/#{params[:selected_topic]}"
      return
    end
    render 'forum/delete_topic'
  end

  def method_missing meth_name, *args
    redirect_to_error_page t(:undef_act)
  end
    
  def redirect_to_error_page error_message = t(:def_msg)
    flash[:forum_message] = error_message
    redirect_to :action => 'message' and return true
  end
      
  def allow_user_perform_action
    if !@usr.admin? && ! (@usr.is_moderator? && @usr.subpartitions.map(&:id).include?(params[:id].to_i))
      redirect_to_error_page
    end
  end
end