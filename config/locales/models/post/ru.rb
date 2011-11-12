{
 :ru =>
 {
   :double_name => 'Пользователь с таким именем уже зарегистрирован. Выбеирте другое имя.',
   :posts_with_cap => 'Сообщение не может содержать только прописные буквы.',
   :activerecord =>
   {
      :errors =>
      {
        :models =>
        {
          :post =>
          {
            :attributes =>
            {
                :remove_acceptance =>
                {
                    :accepted => "Удаление не подтверждено."
                },
                :message =>
                {
                    :blank =>  'Сообщение не может быть пустым.'
                },
                :poster =>
                {
                    :too_long => 'Значение имени отправителя слишком длинное.',
                    :too_short => 'Значение имени отправителя слишком короткое.'
                }

            }
          }
        },
        :messages =>
        {
           :invalid_email_address => 'Неправильный адрес электронной почты.',
           :email_address_not_routable => 'Введеный e-mail не существует.'
        }
      }
   }
 }
}