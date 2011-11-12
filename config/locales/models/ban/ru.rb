{
 :ru =>
 {
   :not_exist => "Пользователь с таким именем не существует.",
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
                    :too_long => 'Значение поля Имя пользователя слишком длинное.',
                    :too_short => 'Значение поля Имя пользователя слишком короткое.',
                    :taken => 'Пользователь с таким именем уже забанен.'
                },
                :message =>
                {
                    :too_long => 'Сообщение слишком длинное.'
                },
                :ip =>
                {
                    :invalid => 'IP адрес введен неправильно.'
                }
            }
          }
        },
         :messages =>
        {
           :invalid_email_address => 'Неправильный адрес электронной почты.',
           :email_address_not_routable => 'Введеный e-mail не существует.',
            :existence => 'Соответствующий пользователь не существует или не найден.'
        }
      }
   }
 }
}