{
 :en =>
 {
  :double_titie => 'You have already subpartition with such title',
  :double_position => 'You already have subpartition with such position',
   :activerecord =>
   {
      :errors =>
      {
        :models =>
        {
          :subpartition =>
          {
            :attributes =>
            {
                :title =>
                {
                    :too_long => 'Title value is too long.'
                },
                :part_pos =>
                 {
                     :not_a_number => 'Position value is not a number.'
                 }
            }
          }
        },
        :messages =>
        {
           :existence => 'Parent partition is missing.'
        }
      }
   }
 }
}