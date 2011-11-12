{
 :en =>
 {
  :double_ip => 'A new user was registered with the same IP address as you within the last 1 hour. To prevent registration flooding, at least an hour has to pass between registrations from the same IP',
  :banned_email => 'The e-mail address you entered is banned in this forum. Please choose another e-mail address',
  :double_email => 'User with such e-mail has registered already. Please choose another e-mail address',
  :signature_contain => "Signature should contain less or equal a ",
  :lines => " lines.",
  :too_long => " field is too long",
  :more_posts_format => '"More posts than" field have wrong format (only digits) or length',
  :less_posts_format => '"Less posts than" field have wrong format (only digits) or length',
  :last_post_after => '"Last post is after" field have wrong format',
  :last_post_before => '"Last post is before" field have wrong format',
  :regist_after => '"Registration after" field have wrong format',
  :regist_before => '"Registration before" field have wrong format',
  :activerecord =>
   {
      :errors =>
       {
          :models =>
          {
            :user =>
             {
              :attributes =>
                {
                  :captcha_solution =>
                   {
                    :blank => 'Captcha field is blank.',
                    :invalid => 'Captcha is invalid.'
                   },
                  :name =>
                  {
                    :taken => 'Such name has already been taken. Choice another username.',
                    :blank => 'Name field is blank.',
                    :too_short => 'Name is too short.',
                    :too_long => 'Name is too long.',
                    :invalid => 'Invalid format of user name.'
                   },
                  :passwd =>
                  {
                     :blank => 'Password field is blank.',
                     :too_short => 'Name is too short.',
                     :too_long => 'Name is too long.',
                     :confirmation => "Password doesn't match confirmation."
                  },
		  :email =>
		  {
		    :too_short => 'Name is too short.',
		    :too_long => 'Name is too long.',
		    :confirmation => "E-mail doesn't match confirmation."
		  },
		  :new_email =>
		   {
		     :too_short => 'E-mail is too short.',
		     :too_long => 'E-mail is too long.',
		     :confirmation => "E-mail doesn't match confirmation."
	           },
		  :web =>
		   {
      		     :invalid => 'Web-site field is invalid. Site address must be preceded with protocol http(s)://',
                :too_long => 'Web-site value is too long.'
		   },
		   :howshowemail =>
		   {
		     :inclusion => 'Undefined value of a how show email field.'
		   },
		   :dst =>
		   {
		     :inclusion => 'Undefined value of a daylight saving field'
		   },
		   :timezone =>
		   {
		     :too_short => 'Time zone value is too short.',
		     :too_long => 'Time zone value is too long.'
		   },
		   :jabber =>
		   {
		     :too_long => 'Jabber value is too long.'
		   },
		   :icq =>
		   {
		     :too_long => 'ICQ value is too long.',
          :not_a_number => 'ICQ value is not a number.'
		   },
		   :msn =>
		   {
		     :too_long => 'MSN value is too long.'
		   },
		   :aim =>
		   {
		     :too_long => 'AIM value is too long.'
		   },
		   :yahoo =>
		   {
		     :too_long => 'Yahoo!Messnger value is too long.'
		   },
		   :location =>
		   {
		     :too_long => 'Location value is too long.'
		   },
		   :realname =>
		   {
     		     :too_long => 'Real name value is too long.'
		   },
		   :signature =>
		   {
		      :too_long => 'Signature value is too long.'
		   },
		   :themes_per_page =>
		   {
		      :not_a_number => 'Number of posts is not a number.',
           :too_long => 'Number of posts is too long.'
		   },
		   :posts_per_page =>
		   {
		      :not_a_number => 'Number of topicss is not a number.',
           :too_long => 'Number of topics is too long.'
		   },
		   :last_visit =>
		   {
		      :blank => 'Last visit is blank.'
		   },
		   :title =>
		   {
		      :too_long => 'Title is too long.'
		   }
                }
             }
          },
          :messages =>
          {
           #validates_email_format_of localization
           :invalid_email_address => 'Incorrect e-mail address.',
           :email_address_not_routable => 'Such e-mail address does not exist.'
	  }
       }

   }
 }
}