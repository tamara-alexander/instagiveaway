class Giveaway
	def initialize(access_token, opts = {})
		@access_token = access_token
		@media_shortcode = opts[:media_shortcode].strip
		@winner_count = opts[:winner_count].to_i
		@follows = opts[:follows].split(',').map{ |f| f.strip }.reject{ |f| f.blank? }
	end

	def winners
		choose_winners tallied_entries
	end

	private

	def choose_winners(entries)
		winners = []
		# returns @winner_count number of winners
		while winners.size < @winner_count && entries.present?
			random_index = Random.rand(entries.size)
			winner = entries[random_index]
			# remove all entries from this winner
			entries -= [winner] # TODO figure this out
			winners << winner
		end
		winners
	end

	def tallied_entries
		# each participate gets one point per friend mentioned
		if @tallied_entries.nil?
			@tallied_entries = []
			comments.each_with_object({}) do |comment, entries|
				username = comment.from.username # TODO
				next if username == media_username
				# skip if user is not following required people
				next unless user_following_requirements?(comment.from.id)
				# tally up this participant's mentions
				entries[username] ||= []
				entries[username] |= get_mentions(username, comment.text)
			end.each do |username, mentions|
				# add an entry for each mention
				# skips if there are no mentions
				@tallied_entries += [username] * mentions.size
			end
		end
		# TODO remove this when out of sandbox mode
		@tallied_entries = %w(username1 username1 username1 username1 username2)
		@tallied_entries
	end

	MENTION_REGEX = /\B@[a-z0-9_.]+/
	def get_mentions(username, content)
		content.scan(MENTION_REGEX).reject do |mention|
			# skip if user mentioned media owner or themselves
			mention == username || mention == media_username
		end
	end

	def media_id
		@media_id || instagram.get_media_id(@media_shortcode)
	end

	def media_username
		@media_username || instagram.get_media_owner(media_id)
	end

	def comments
		@comments ||= instagram.get_comments(media_id)
	end

	def user_following_requirements?(user_id)
		usernames_to_follow = @follows | [media_username]
		usernames_followed = instagram.get_follows(user_id).map{ |follow| follow.username }
		# check that intersection of usernames to follow and usernames followed
		# are the same as usernames to follow
		(usernames_followed & usernames_to_follow).sort == usernames_to_follow.sort
	end

	def instagram
		@instagram ||= InstagramClient.new(@access_token)
	end
end