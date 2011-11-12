{
 :en =>
 {
   :not_exist => "User with such name doesn't exist.",
   :activerecord =>
   {
      :errors =>
      {
         :models =>
        {
          :ban =>
          {
            :attributes =>
            {
                :username =>
                {
                    :too_long => 'Username value is too long.',
                    :too_short => 'Username value is too short.',
                    :taken => 'User with name is already banned.'
                },
                :message => 
                {
                    :too_long => 'Message value is too long.'
                },
                :ip =>
                {
                    :invalid => 'IP address is invalid.'
                }
            }
          }
        },
         :messages =>
        {
           :invalid_email_address => 'Incorrect e-mail address.',
           :email_address_not_routable => 'Such e-mail address does not exist.',
            :existence => 'Parent user is missing.'
        }
      }
   }
 }
}