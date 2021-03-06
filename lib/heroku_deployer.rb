class HerokuDeployer

  attr_reader :app
  def initialize(app)
    @app = app
    raise "No app flag configured!" unless @app
  end
 
  def migrations
    push; turn_app_off; migrate; restart; turn_app_on; tag;
  end
 
  def deploy
    push; restart; tag;
  end
 
  def rollback
    turn_app_off; push_previous; restart; turn_app_on;
  end
 
  private
 
  def push
    current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
    branch_to_branch = (current_branch.length > 0) ? "#{current_branch}:master" : ""
    puts "Deploying site to Heroku (#{@app}) ..."
    puts "git push -f git@heroku.com:#{@app}.git #{branch_to_branch}"
    puts `git push -f git@heroku.com:#{@app}.git #{branch_to_branch}`
  end
 
  def restart
    puts 'Restarting app servers ...'
    run_and_log(`heroku restart --app #{@app}`)
  end
 
  def tag
    release_name = "#{@app}_release-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"
    puts "Tagging release as '#{release_name}'"
    puts `git tag -a #{release_name} -m 'Tagged release'`
    puts `git push --tags git@heroku.com:#{@app}.git`
  end
 
  def migrate
    puts 'Running database migrations ...'
    run_and_log(`heroku run 'bundle exec rake db:migrate' --app #{@app}`)
  end
 
  def turn_app_off
    puts 'Putting the app into maintenance mode ...'
    run_and_log(`heroku maintenance:on --app #{@app}`)
  end
 
  def turn_app_on
    puts 'Taking the app out of maintenance mode ...'
    puts `heroku maintenance:off --app #{@app}`
  end
 
  def push_previous
    prefix = "#{@app}_release-"
    releases = `git tag`.split("\n").select { |t| t[0..prefix.length-1] == prefix }.sort
    current_release = releases.last
    previous_release = releases[-2] if releases.length >= 2
    if previous_release
      puts "Rolling back to '#{previous_release}' ..."
 
      puts "Checking out '#{previous_release}' in a new branch on local git repo ..."
      puts `git checkout #{previous_release}`
      puts `git checkout -b #{previous_release}`
 
      puts "Removing tagged version '#{previous_release}' (now transformed in branch) ..."
      puts `git tag -d #{previous_release}`
      puts `git push git@heroku.com:#{@app}.git :refs/tags/#{previous_release}`
 
      puts "Pushing '#{previous_release}' to Heroku master ..."
      puts `git push git@heroku.com:#{@app}.git +#{previous_release}:master --force`
 
      puts "Deleting rollbacked release '#{current_release}' ..."
      puts `git tag -d #{current_release}`
      puts `git push git@heroku.com:#{@app}.git :refs/tags/#{current_release}`
 
      puts "Retagging release '#{previous_release}' in case to repeat this process (other rollbacks)..."
      puts `git tag -a #{previous_release} -m 'Tagged release'`
      puts `git push --tags git@heroku.com:#{@app}.git`
 
      puts "Turning local repo checked out on master ..."
      puts `git checkout master`
      puts 'All done!'
    else
      puts "No release tags found - can't roll back!"
      puts releases
    end
  end

  private

  def run_and_log(command, instance = 1, cap=20)
    response = command
    return (puts "Gave up after #{cap} seconds.") if instance >= cap
    
    if response.include?("Heroku Toolbelt is currently updating")
      puts "Stalling to allow for Heroku Toolbelt update. Attempt \##{instance}..."
      sleep 1
      run_and_log(command, instance + 1)
    else
      puts response
    end
  end
end