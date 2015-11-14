class ApplicationMailer < ActionMailer::Base
  SENDER_ADDRESS = "noreply@retiqueta.com"
  SENDER_NAME = "Retiqueta"
  
  default from: "#{SENDER_NAME} <#{SENDER_ADDRESS}>"
end
