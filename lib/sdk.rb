require 'rugged'
require 'json'

module Gitlapse
  def self.lapses
    Gitlapse::SDK.new
  end

  class SDK 
    def initialize
      @repo = Rugged::Repository.new '.'
      @port = "443"
      @version = "v1"
      @base_url =  "https://api.gitlapse.com:#{@port}/#{@version}"
      #@port = "8080"
      #@base_url =  "http://127.0.0.1:#{@port}"
    end

    def get_blob requested_path
      # Get the current Git branch of the local repo
      current_branch 	= @repo.head.name.sub(/^refs\/heads\//, '')
      tree 		= @repo.branches[current_branch].target.tree

      tree.walk(:postorder) do |root, entry|
	path	= "#{root}#{entry[:name]}"
	oid	= entry[:oid]


	if entry[:type] == :blob 
	  if requested_path == path
	    blob 	= @repo.lookup(oid)
	    content 	= blob.content 
	    #p "path	: #{path}"
	    #p "oid	: #{oid}"
	    #p "content	: #{content}"
	    return oid, content
	  end
	end
      end
    end

    def send sha, content
      gitlapse_client = JSON.generate({:SHA => sha, :content => content})
      #response = `curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '#{gitlapse_client}' #{@base_url}/git/full_lapse`
      response = `curl -v -H "Origin: https://www.gitlapse.com" -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '#{gitlapse_client}' #{@base_url}/git/full_lapse`
    end

    def full_lapse path
      r = get_blob(path)
      if r.nil? then
	p 'raise error baby'
      else
	send(r[0],r[1])
	p "Visit your lapse at: "
	p "https://www.gitlapse.com/sample.html?SHA=#{r[0]}"
      end
    end

  end
end
