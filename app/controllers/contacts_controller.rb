class ContactsController < ApplicationController
  protect_from_forgery with: :exception

  layout "contact_form"

  def new
  	@contact = Contact.new
  end

  def create
  	@contact = Contact.new(contacts_params)

    if simple_captcha_valid?
      @contact.request = request
      if @contact.deliver
        flash[:notice] = 'Thank you for your message. We will contact you soon!'
        redirect_to(:controller => 'welcomes', :action => 'index')
      else
        flash[:error] = 'Cannot send message.'
        render :new
      end
    else
      flash[:error] = "The Captcha was not valid..."
      render :new
    end
  end

  private
  	def contacts_params
	  params.require(:contact).permit(:name, :email, :message)
	end
end
