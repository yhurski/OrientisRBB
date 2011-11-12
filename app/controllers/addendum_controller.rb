class AddendumController < ApplicationController
  before_filter :get_user
  before_filter :search_permission, :only => ['search']
  before_filter :search_flood_timeout_check, :only => ['search']
  before_filter :put_search_time, :only => ['search']
  
  def search  
    @optitems = create_forum_groups
    if params[:act] == 'search'
      return  if (check_is_params_hash_empty(params))
      drop_deny_chars params[:find_author]
      get_order_as_string params[:us_orderby]
      get_sort_column_as_string params[:us_sortby]
      @raw_request = assembly_crude_request params
      #zero - show results as skipped messages, one - as  themes
      if params[:us_resultas].to_i == 0                                                                                                                                          #show results as skipped messages
        sq=""
        sort_posts params, @raw_request
        remove_forbidden_posts
        if ((@subpart.nil? && @posts.blank?) || (!@subpart.blank? && @topics.blank?))
          redirect_to_info_page t(:no_results)
        else
          render "sresult"
        end
        return
      else                                                                                                                                                                          #show results as a list of themes
        sort_themes params, @raw_request
        remove_forbidden_posts
        if (@subpartition.nil? && @topics.blank?)
          redirect_to_info_page t(:no_results)
        else
          render "sresult_titles"
        end
        return
      end
    end
  end
  
  def message
    flash.keep
  end

private

  def redirect_to_info_page message=t(:def_msg)
    flash[:permission_message] = message
    redirect_to :action => 'message'
  end

  def search_permission
    unless @group_permissions.g_search
      redirect_to_info_page
    end
  end
  
  def create_forum_groups
    if Configs.get_config('allow_search').to_bool
      create_forums_optgroup
    else
      create_forums_optgroup 0
    end
  end
  
  def drop_deny_chars digest
    digest.gsub(/[\'\"\`\\\|\/#=<>]/, '')
  end
  
  def check_is_params_hash_empty params
    if params[:keywords].empty? and params[:find_author].empty?
      redirect_to_info_page(t(:no_results)) and return true
    end
  end
  
  def get_order_as_string num_order
    if num_order.to_i == 0
      "ASC"
    else
      "DESC"
    end
  end
  
  def get_sort_column_as_string num_sort 
    case num_sort.to_i
    when 0 then "posted"                                                                                                                                      #time
    when 1 then "poster"                                                                                                                                       #author
    when 2 then "title"                                                                                                                                           #title1
    when 3 then "forum title"                                                                                                                               #subpartition title
    else "posted"                                                                                                                                                     #by default - time
    end
  end
  
  def assembly_crude_request params
    author = drop_deny_chars(params[:find_author])
    raw_sql = ""
    if not params[:keywords].empty?
      keywords =  drop_deny_chars(  params[:keywords].gsub('*', '%').gsub('?', '_') ).downcase()
      search_keywords = keywords.split(/\s+and|not|or\s+|^not/).delete_if{|el| el.strip.empty?}.collect{|el| ((el.to_s.strip << '%').reverse << '%').reverse}
      bool_keywords = []
      keywords.gsub(/\s+and|not|or\s+|^not/){|w| bool_keywords << w.strip}
      bool_keywords.each_index do |index|
        if bool_keywords[index] == 'not'
          raw_sql << "message NOT LIKE ? "
        else
          if index > 0 and bool_keywords[index - 1] == 'not'
            raw_sql << bool_keywords[index] << " message LIKE ? "
          else
            raw_sql << "message LIKE ? " << bool_keywords[index] + " "
          end
        end
      end
      raw_sql << "message LIKE ?" unless bool_keywords.last == 'not'
      if bool_keywords.size > search_keywords.size
        raw_sql = "message like ''"
      end
            
      search_keywords.each{|search_keyword| raw_sql.sub!('?', "\'#{search_keyword}\'")}
      raw_sql.gsub!('?', '')

      #embrace request in brackets
      unless raw_sql.blank?
        raw_sql = ( raw_sql.reverse << '(' ).reverse << ')'
      end

      unless author.empty?
        raw_sql << " and poster_id = (select id from users where name = \'#{author}\')"
      end

      if params[:us_forum_subpart].to_i > 0
        raw_sql << " and topic_id in (select id from topics where subpartition_id = \'#{params[:us_forum_subpart]}\')"
      end
    else
      unless author.empty?
        raw_sql = "poster_id = (select id from users where name = \'#{author}\')"
        if params[:us_forum_subpart].to_i > 0
          raw_sql << " and topic_id in (select id from topics where subpartition_id = \'#{params[:us_forum_subpart]}\')"
        end
      end
    end
    raw_sql
  end
  
  #view as a list of the posts
  def sort_posts params, raw_request
    sort_order = get_order_as_string params[:us_orderby].to_i
    case params[:us_sortby].to_i
    when 0 then
      @posts = Post.find(:all, :conditions => raw_request, :order => "posted #{sort_order}")
    when 1 then
      @posts = Post.find(:all, :conditions => raw_request, :order => "poster #{sort_order}")
    when 2..3 then
      ready_request = "id in ( select topic_id from posts where #{raw_request})"
      if params[:us_sortby].to_i == 3
        @topics = Topic.find(:all, :conditions => ready_request)
        if sort_order == "ASC"
          @topics.sort!{|f,b| f.subpartition.title <=> b.subpartition.title}
        else
          @topics.sort!{|f,b| b.subpartition.title <=> f.subpartition.title}
        end
      else
        @topics = Topic.find(:all, :conditions =>  ready_request, :order => "title #{sort_order}")
      end
    end
  end
  
  def sort_themes params
    sort_order = get_order_as_string params[:us_orderby].to_i
    case params[:us_sortby].to_i
    when 0 then
      ready_request = "select distinct topic_id from posts where #{@raw_request} order by posted #{sort_order}"
      @topics = Post.paginate_by_sql(ready_request, :page => params[:page], :per_page => 20)
      @is_post = true
    when 1 then
      ready_request = "select distinct topic_id from posts where #{@raw_request} order by poster #{sort_order}"
      @topics = Post.paginate_by_sql(qn, :page => params[:page], :per_page => 20)
      @is_post = true
    when 2 then
      ready_request = "select * from topics where id in (select DISTINCT topic_id from posts where #{@raw_request }) order by title #{sort_order}"
      @topics = Topic.paginate_by_sql(qn, :page => params[:page], :per_page => 20)
      @is_post = false
    when 3 then
      ready_request = "select subpartition_id from topics where id in (select DISTINCT topic_id from posts where #{@raw_request })"
      @subpartitions = Subpartition.paginate_by_sql("select * from subpartitions where id in (#{ready_request}) order by title #{sort_order}", :page => params[:page], :per_page => 20)
      @filter_by_parameters = "id in (select DISTINCT topic_id from posts where #{@raw_request })"
    end
  end
  
  def remove_forbidden_posts
    subpartition_permissions = Group.find(Group.get_user_group_id @usr).forum_perms
    if defined? @posts
      @posts.reject! {|post| !subpartition_permissions.find_by_subpartition_id(post.topic.subpartition.id).read_forum}
    end      
    if defined? @topics
      @topics.reject! {|topic| !subpartition_permissions.find_by_subpartition_id(topic.kind_of?(Topic) ? topic.subpartition.id : topic.topic.subpartition.id).read_forum}
    end
    if defined? @subpartitions
      @subpartitions.reject! {|subpartition| !subpartition_permissions.find_by_subpartition_id(subpartition.id).read_forum}
    end
  end
  
  def put_search_time
    if params[:act]
      check_online3 nil, Time.now.utc
    else
      check_online3
    end
  end
  
  def search_flood_timeout_check
    if params[:act]
      if @usr
        if online_user = Online.find_by_user_object(@usr)
          last_search_time = online_user.last_search
        else
          last_search_time = @usr.last_search
        end
      else
        if online_user = Online.find(:first, :conditions => ["user_id = ? and name = ?", User.get_guest.id, request.remote_addr])
          last_search_time = online_user.last_search
        end
      end
      if last_search_time && (last_search_time + @group_permissions.g_search_flood.to_i) > Time.now.utc
        redirect_to_info_page(t(:at_least) + @group_permissions.g_search_flood.to_s + t(:seconds))  and return
      end
    end
  end
end