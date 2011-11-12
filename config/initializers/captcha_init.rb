#VALIDATES_CAPTCHA INITIALIZER FOR IMAGE CAPTCHA INCLUDE
# ValidatesCaptcha.provider = ValidatesCaptcha::Provider::DynamicImage.new
 ValidatesCaptcha.provider =  ValidatesCaptcha::Provider::DynamicImage.new#ValidatesCaptcha::ImageGenerator::Simple.new
 ValidatesCaptcha::StringGenerator::Simple.alphabet = '0123456789'
 ValidatesCaptcha::StringGenerator::Simple.length = 4

 # ValidatesCaptcha::SymmetricEncryptor::Simple.secret = 'bd66e2479b5234wrasdfwer234qwer345ertewr3452'