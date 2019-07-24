class WebhooksController < ActionController::Base

  def new
    @webhook = Webhook.new()
  end

  def create
    @webhook = Webhook.new(webhook_params)

    if @webhook.save
      WebhookWorker.perform_async(@webhook)
      render :new
    else
      flash.alert = @webhook.errors.full_messages
      render :new
    end
  end
end

private

def webhook_params
  params.require(:webhook).permit(:name, :url, :zip_code)
end