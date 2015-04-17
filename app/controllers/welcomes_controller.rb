class WelcomesController < ApplicationController
  protect_from_forgery with: :exception

  #Including Gems
  require 'soundcloud'
  require 'whatlanguage'
  require 'twitter'

  # ************************************** INDEX **************************************
  def index
    @home_page = true

    if !session[:genre]
      session[:genre] = "music"
    end

    #List of genres
    @genre_list = list_genres
    @random_number=Random.new.rand(0..(@genre_list.size-1))

    #Twitter REST API credentials
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "c9uC8Nx2rGDvH25J1tenPi23t"
      config.consumer_secret     = "xoKs0lpvvSjawrljRv3vwCFmtk4ZqKXMWxr6eHR35tNY76fiBT"
      config.access_token        = "289016412-ISb7lTpGAKvS5HjzPj5OjwDJcfv3fEDznVlKNzR0"
      config.access_token_secret = "f4HJBzhXiIqjImSfYDWApOKwu08VtXd0PcCbB8QwF15CD"
    end

    #Searches for tweets with the word soundcloud and the genre
    @tweets_bandcamp = []
    client.search("#{@this_is_the_dropdown_value} bandcamp.com/", options = {:lang => "en"}).take(200).each do |tweet|
      @tweets_bandcamp << {:text => "#{tweet.text}", :id => tweet.id}
    end

    while @tweets_bandcamp.size<160 do
      client.search("bandcamp.com/", options = {:lang => "en"}).take(100).each do |tweet|
        @tweets_bandcamp << {:text => tweet.text, :id => tweet.id}
      end
    end

    @tweets_bandcamp.shuffle!
    @tweets_bandcamp.uniq! {|e| e[:text] }
    @tweet_text = []
    @tweet_ids  = []
    @tweets_bandcamp[0..5].each do |tweet|
      @tweet_text << tweet[:text]
      @tweet_ids  << tweet[:id]
    end
  end

  # ************************************** NEW **************************************
  def new

    #List of genres
    @genre_list = list_genres
    @random_number=Random.new.rand(0..(@genre_list.size-1))

    #Get genre from dropdown values
    begin
      if params["dropdown_cases"]
        params["dropdown_cases"].each do |cases|
          @this_is_the_dropdown_value = cases.to_s
        end
      else
        @this_is_the_dropdown_value = session[:genre]
      end
    rescue
      @this_is_the_dropdown_value = "music"
    end

    redirect_to :action => :song, :genre => @this_is_the_dropdown_value

  end


  # ************************************** SONG **************************************
  def song
    begin

      @home_page = false

      @genre_list = list_genres
      @random_number=Random.new.rand(0..(@genre_list.size-1))

      @this_is_the_dropdown_value = params[:genre]

      #Get genre from dropdown values
      begin
        if params[:genre]
          @this_is_the_dropdown_value = params[:genre]
        else
          @this_is_the_dropdown_value = session[:genre]
        end
      rescue
        @this_is_the_dropdown_value = "music"
      end

      #Twitter REST API credentials
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = "c9uC8Nx2rGDvH25J1tenPi23t"
        config.consumer_secret     = "xoKs0lpvvSjawrljRv3vwCFmtk4ZqKXMWxr6eHR35tNY76fiBT"
        config.access_token        = "289016412-ISb7lTpGAKvS5HjzPj5OjwDJcfv3fEDznVlKNzR0"
        config.access_token_secret = "f4HJBzhXiIqjImSfYDWApOKwu08VtXd0PcCbB8QwF15CD"
      end

      #Searches for tweets with the word soundcloud and the genre
      @tweets_bandcamp = []
      client.search("#{@this_is_the_dropdown_value} bandcamp.com/album/", options = {:lang => "en"}).take(200).each do |tweet|
        @tweets_bandcamp << {:text => "#{tweet.text}", :id => tweet.id}
      end

      while @tweets_bandcamp.size<160 do
        client.search("bandcamp.com/album/", options = {:lang => "en"}).take(100).each do |tweet|
          @tweets_bandcamp << {:text => tweet.text, :id => tweet.id}
        end
      end

      @tweets_bandcamp.shuffle!
      @tweets_bandcamp.uniq! {|e| e[:text] }
      @tweet_text = []
      @tweet_ids  = []

      @tweets_bandcamp[0..5].each do |tweet|
        @tweet_text << tweet[:text]
        @tweet_ids  << tweet[:id]
      end


      #Soundcloud API gets songs
      begin

        client = SoundCloud.new(:client_id => '1fc18537f83fe8005530fbac52f2b9f4')
        track = client.get('/resolve', url: "http://api.soundcloud.com/tracks/#{params[:id]}")
        @individual_tune = {id: track.uri, song_list: track.permalink_url, titles: "#{track.title}", final_id: "#{track.id}"}

        if params[:genre]
          session[:genre] = "#{params[:genre]}"
          @this_is_the_dropdown_value = "#{params[:genre]}"
        else
          session[:genre] = "#{track.genre.split(" ").first}"
          @this_is_the_dropdown_value = "#{track.genre.split(" ").first}"

        end
        
      rescue

        client = SoundCloud.new(:client_id => '1fc18537f83fe8005530fbac52f2b9f4')
        tracks = client.get('/tracks', :limit => 200, :order => 'hotness', :genres => @this_is_the_dropdown_value)
        zero_song_hash=[]
        tracks.each do |track|
          if session[:array]
            session[:array].each do |sesh|
              next if sesh.to_s == "#{track.id}"
            end
          end
          zero_song_hash << {id: track.uri, tune: track.permalink_url, 
                  name: "#{track.title}", track_id: "#{track.id}"}
        end

        zero_song_hash.shuffle!
        final_song_hash=[]
        zero_song_hash.first(5).each do |song|
          if (defined?(song[:id])).nil?
            next
          else
            if song[:name].language.to_s.eql? "english"
              final_song_hash.unshift({song_list: song[:tune], 
                titles: song[:name], final_id: song[:track_id]})
            else
              final_song_hash.push({song_list: song[:tune], 
                titles: song[:name], final_id: song[:track_id]})
            end
          end
        end

        @the_song = []
        final_song_hash.each do |piece|
          piece[:song_list].gsub! ':', '%3A'
          piece[:song_list].gsub! '/', '%2F'
          @the_song << piece
        end
        @count = 0
        @individual_tune = @the_song.first

        if !session[:genre]
          session[:genre] = "Music"
        else
          session[:genre] = "#{@this_is_the_dropdown_value}"
        end

      end

      if session[:array]
        if session[:array].size == 30
          session[:array].delete_at(29)
          session[:array].unshift @individual_tune[:final_id]
        else
          session[:array].unshift @individual_tune[:final_id]
        end
      else
        session[:array] = Array.new
      end

      # Next song session
      @number_of_next_sessions = 5

      if session[:next] && session[:next] < @number_of_next_sessions
          session[:next] += 1
        else
          session[:next] = 0
        end
      
      if !params[:genre] || params[:id]
        session[:next] = @number_of_next_sessions
      end

    rescue
      flash[:notice] = "Sorry. Something went wrong with SoundCloud"
      redirect_to(:action => 'index')
    end
  end

  private

    def list_genres
      return ["acapella", "african", "alternative", "ambient", "beats", "bluegrass", "blues", "chill", "choir", "classical", "comedy", "cover", "deep", "delta", "disco", "dub", "dubstep", "easy", "edm", "electro", "electronica", "experimental", "folk", "funk", "future", "gfunk", "gospel", "happy", "hip-hop", "house", "indie", "instrumental", "international", "irish", "jazz", "juke", "jungle", "latin", "lounge", "metal", "newage", "oldie", "opera", "poetry", "pop", "post", "post-hardcore", "prog", "progressive", "progrock", "psychedelic", "punk", "r&b", "rap", "reggae", "rock", "samba", "ska", "swing", "trance", "tribal", "triphop", "worldmusic"]
    end

end
