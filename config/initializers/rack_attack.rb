module Rack
  class Attack
    ### Configure Cache ###

    # If you don't want to use Rails.cache (Rack::Attack's default), then
    # configure it here.
    #
    # Note: The store is only used for throttling (not blacklisting and
    # whitelisting). It must implement .increment and .write like
    # ActiveSupport::Cache::Store

    # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    ### Throttle Spammy Clients ###

    # If any single client IP is making tons of requests, then they're
    # probably malicious or a poorly-configured scraper. Either way, they
    # don't deserve to hog all of the app server's CPU. Cut them off!
    #
    # Note: If you're serving assets through rack, those requests may be
    # counted by rack-attack and this throttle may be activated too
    # quickly. If so, enable the condition to exclude them from tracking.

    # Throttle all requests by IP (60rpm)
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
    throttle('req/ip', limit: 300, period: 5.minutes) do |req|
      req.ip unless req.path.start_with?('/assets')
    end

    ### Prevent Brute-Force Login Attacks ###

    # The most common brute-force login attack is a brute-force password
    # attack where an attacker simply tries a large number of emails and
    # passwords to see if any credentials match.
    #
    # Another common method of attack is to use a swarm of computers with
    # different IPs to try brute-forcing a password for a specific account.
    (1..5).each do |level|
      # Throttle POST requests to /login by IP address
      #
      # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
      throttle("logins/ip/#{level}", limit: (20 * level), period: (8**level).seconds) do |req|
        req.ip if req.path == '/v1/auth' && req.post?
      end

      # Throttle POST requests to /login by email param
      #
      # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
      #
      # Note: This creates a problem where a malicious user could intentionally
      # throttle logins for another user and force their login requests to be
      # denied, but that's not very common and shouldn't happen to you. (Knock
      # on wood!)
      throttle('logins/email', limit: (20 * level), period: (8**level).seconds) do |req|
        req.params['email'].presence if req.path == '/v1/auth' && req.post
      end
    end

    blocklist('block wp login') do |req|
      req&.path == '/wp-login.php'
    end

    blocklist('block netcraft survey agent') do |req|
      req.user_agent.downcase&.include?('netcraftsurveyagent')
    end

    blocklist('block go http client') do |req|
      req&.user_agent&.downcase&.include?('go-http-client')
    end

    blocklist('block java http client') do |req|
      req&.user_agent&.downcase&.include?('unirest-java')
    end

    ### Custom Throttle Response ###

    # By default, Rack::Attack returns an HTTP 429 for throttled responses,
    # which is just fine.
    #
    # If you want to return 503 so that the attacker might be fooled into
    # believing that they've successfully broken your app (or you just want to
    # customize the response), then uncomment these lines.
    # self.throttled_response = lambda do |env|
    #  [ 503,  # status
    #    {},   # headers
    #    ['']] # body
    # end
  end
end
