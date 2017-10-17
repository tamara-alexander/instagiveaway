class InstagramClient

  def initialize(access_token)
  	@access_token = access_token
  end

  def get_media_id(media_shortcode)
  	client.media_shortcode(media_shortcode).id
  end

  def get_media_owner(media_id)
  	client.media_item(media_id).user.username
  end

  def get_comments(media_id)
  	client.media_comments(media_id)
  end

  def get_follows(user_id)
  	client.user_follows(user_id)
  end

  private

  def client
    @client ||= Instagram.client(:access_token => @access_token)
  end
end