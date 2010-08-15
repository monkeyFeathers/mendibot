module YelpBot
  
  YelpHelp = "usage: !yelp [search term (e.g. 'bars' for multiple words use '+' instead of ' ')] [location (e.g. 'Portland, OR')]"
  YelpCrack = "Ah, man...why you want to waste your life on that stuff?"
  YelpCrackClarify = "did you mean 'crack+cocaine'?"
  
  class Query
    attr_accessor :term, :location, :category, :query
  
    YELP_URI = "http://api.yelp.com/business_review_search?"
    
    ####################################################################################################
    # yelp api key goes here, they made me promise not to share mine :(
    #
    YWSID = "5gerYyIQDNNAMWN10ahp4g" 
    #
    #
    ######################################################################################################
  
    def initialize(match_data)
      process_match_data match_data
    end
  
    def process_match_data match_data
      # get rid of commas from my params
      params = match_data.split(",").join(" ")
      params = params.split(" ")
      # Need error processing here, probably
    
      # ready params for the query
      @term = params.shift
      @location = params.join(" ")
    end
  
    def get
      # make query and url encode
      @query = String.new
      @query << YELP_URI
    
      query = Array.new
      query << "term=#{@term}"
      query << "location=#{CGI::escape(@location)}"
      query << "ywsid=#{YWSID}"
      query << "category=#{category}" unless @category == nil
    
      @query << query.join("&")
    
      # send get request via restclient and capture results in instance variable
      resource = RestClient::Resource.new(@query)
      results = YelpBot::Results.new JSON.parse(resource.get)
    end
  
  end

  class Results
    attr_accessor :results, :refined_results, :output, :message
    def initialize(results)
      @results = results
      @message = @results['message']
    end
  
    def process_output(limit=3)
      # process results to be sent to be put in irc
      @refined_results = Array.new
      @results["businesses"].each do |b|
        h = Hash.new
        h["name"]        = b["name"]
        h["url"]  = b["url"]
        h["avg_rating"]  = b["avg_rating"]
      
        # constrain the number of businesses shown
        unless @refined_results.length >= limit
          @refined_results << h
        else
          break
        end
      end
    
      # convert the refined results to final format for to be put into the irc room
      @output = Array.new
      @refined_results.each do |rr|
        @output << "#{rr["name"]}, #{rr["url"]}, rated: #{rr["avg_rating"]}"
      end
      @output = @output.join(" | ")
    end
  
    def handle_response_codes
      @output = case @message["code"]
      when 0
        process_output
      else
        "Could not complete request: #{@message["text"]}"
      end
    end
  
    def to_irc
      handle_response_codes
    end
  end

end