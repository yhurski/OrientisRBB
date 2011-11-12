module ForumHelper
  def get_allowed_bbcodes sign, is_img_tag=false
    if is_img_tag
      sign.bbcode_to_html({}, true, :enable,  :bold, :italics, :underline, :strikeout, :delete, :insert, :code, :color, :quote, :link, :image, :video)
    else
      sign.bbcode_to_html({}, true, :enable,
        :bold, :italics, :underline, :strikeout, :delete, :insert, :code, :color,
        :quote, :link, :video)
    end
  end
    
  def replace_smilies_with_icons message_after_processing
    message_after_processing.gsub! ":)", image_tag("smiles/smile.png")
    message_after_processing.gsub! "=)", image_tag("smiles/smile.png")
    message_after_processing.gsub! ":|", image_tag("smiles/neutral.png")
    message_after_processing.gsub! "=|", image_tag("smiles/neutral.png")
    message_after_processing.gsub! ":(", image_tag("smiles/sad.png")
    message_after_processing.gsub! "=(", image_tag("smiles/sad.png")
    message_after_processing.gsub! ":D", image_tag("smiles/big_smile.png")
    message_after_processing.gsub! "=D", image_tag("smiles/big_smile.png")
    message_after_processing.gsub! ":O", image_tag("smiles/yikes.png")
    message_after_processing.gsub! ":o", image_tag("smiles/yikes.png")
    message_after_processing.gsub! ";)", image_tag("smiles/wink.png")
    message_after_processing.gsub! ":P", image_tag("smiles/tongue.png")
    message_after_processing.gsub! ":lol:", image_tag("smiles/lol.png")
    message_after_processing.gsub! ":mad:", image_tag("smiles/mad.png")
    message_after_processing.gsub! ":rolleyes:", image_tag("smiles/roll.png")
    message_after_processing.gsub ":cool:", image_tag("smiles/cool.png")
  end

  def post_bbcodes_and_iconize user_obj, is_img_tag=false, is_replace_smiles=false
    if is_replace_smiles
      replace_smilies_with_icons(get_allowed_bbcodes(user_obj, is_img_tag))
    else
      get_allowed_bbcodes user_obj, is_img_tag
    end
  end
 
  def make_only_bbcimg message
    user_obj.signature.bbcode_to_html({}, true, :enable, :img)
  end
 
  def make_bbcodes message
    if Configs.get_config('allow_bbc').to_bool
      if Configs.get_config('allow_bbc_img').to_bool
        replace_img_to_link_tag(  check_quote_indent( message,  Configs.get_config('quote_depth').to_i  ) ).bbcode_to_html({},true,:enable,:bold,:underline,:italics,:strikeout,:color,:link,:code,:quote,:image,:video)
      else
        replace_img_to_link_tag(  check_quote_indent( message, Configs.get_config('quote_depth').to_i ) ).bbcode_to_html({},true,:enable,:bold,:underline,:italics,:strikeout,:color,:link,:code,:quote,:video)
      end
    else
      message
    end
  end
  
  def replace_img_to_link_tag msg
    if (! @usr.nil? && ! @usr.show_img_inmess) || (@usr.nil? && ! Configs.get_config('allow_bbc_img').to_bool)
      msg.gsub('[img]', '[url]').gsub('[/img]', '[/url]')
    else
      msg
    end
  end
  
  def signature_bbcodes_allowed?
    Configs.get_config('allow_bbcsignature').to_bool
  end
  
  def signature_bbimg_allowed?
    Configs.get_config('allow_bbcimgsignature').to_bool
  end
  
  def signature_smilestoicon_allowed?
    Configs.get_config('convert_smilestoicon').to_bool
  end

  def check_quote_indent msg, quote_level
    quote_depth = 0
    new_msg = ''
    i = 0
    return msg if msg.size < 8
    while i < msg.size - 6
      if msg[i..i+7] =~ /\[quote\]/
        quote_depth += 1
        if quote_depth > quote_level
          new_msg << '[badquote]'
        else
          new_msg << '[quote]'
        end
        i += 7 and next
      elsif msg[i..i+8] =~ /\[\/quote\]/
        if quote_depth > quote_level
          new_msg << '[/badquote]'
        else
          new_msg << '[/quote]'
        end
        if quote_depth > 0
          quote_depth -= 1
        end
        i += 8 and next
      else
        if i == msg.size - 7        #last iteration
          new_msg << msg[i..msg.size-1]
          return new_msg
        else
          new_msg << msg[i]
          i += 1
        end
      end
    end
    new_msg
  end

private

  def allowed_bbcodes
    [:enable,:bold,:underline,:italics,:strikeout,:color,:link,:code,:quote,:image,:video]
  end
end