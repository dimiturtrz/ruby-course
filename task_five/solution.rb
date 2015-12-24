require 'digest/sha1'
require "date"
class ObjectStore
  def initialize
    @branches = Branches.new
    @state = {}
  end

  def self.init(&init_block)
    repository = ObjectStore.new
    repository.instance_eval &init_block if block_given?
    repository
  end

  def add(name, object)
    @state[name] = object
    Result.new "Added #{name} to stage.", true, object
  end

  def remove(name)
    object = @state.delete name
    if object
      Result.new "Added #{name} for removal", true, object
    else
      Result.new "Object #{name} is not committed.", false
    end
  end

  def commit(commit_message)
    if @state == branch.current_branch.state
      Result.new "Nothing to commit, working directory clean.", false
    else
      branch.current_branch.commit_state @state, commit_message
    end
  end

  def checkout(commit_hash)
    commit = branch.current_branch.checkout(commit_hash)
    if commit
    	Result.new "HEAD is now at #{commit_hash}.", true, commit
    else
        Result.new "Commit #{commit_hash} does not exist.", false
    end
  end

  def head
    head = branch.current_branch.last_commit
    if head
      Result.new head.message, true, head
    else
      branch_name = branch.current_branch_name
      Result.new "Branch #{branch_name} does not have any commits yet.", false
    end
  end

  def get(name)
    object = branch.current_branch.state[name]
    if object
      Result.new "Found object #{name}.", true, object
    else
      Result.new "Object #{name} is not committed.", false
    end
  end

  def branch
    @branches
  end

  def log
    if @branches.current_branch.commits_string
      Result.new @branches.current_branch.commits_string, true
    else
      branch_name = @branches.current_branch_name
      Result.new "Branch #{branch_name} does not have any commits yet.", false
    end
  end

  class Branches
    attr_reader :current_branch
    def initialize()
      @branches = {}
      create "master"
      @current_branch = @branches["master"]
    end

    def create(branch_name)
      if @branches[branch_name]
        Result.new "Branch #{branch_name} already exists.", false
      else
        @branches[branch_name] = Branch.new @current_branch
        Result.new "Created branch #{branch_name}.", true
      end
    end

    def checkout(branch_name)
      if @branches[branch_name]
        @current_branch = @branches[branch_name]
        Result.new "Switched to branch #{branch_name}.", true
      else
        Result.new "Branch #{branch_name} does not exist.", false
      end
    end

    def remove(branch_name)
      if @branches[branch_name]
        if @current_branch == @branches[branch_name]
          Result.new "Cannot remove current branch.", false
        else
          @branches.delete(branch_name)
          Result.new "Removed branch #{branch_name}.", true
         end
      else
        Result.new "Branch #{branch_name} does not exist.", false
      end
    end

    def list
      branch_list = @branches.keys.sort.map do |name|
        (@branches[name] == @current_branch ? "* " : "  ") + name
      end.join("\n")
      Result.new branch_list, true
    end

    def current_branch_name
      @branches.key @current_branch
    end

    class Branch
      attr_reader :state, :commits
      def initialize(parent = nil)
        @commits, @state = parent ? [parent.commits, parent.state] : [[], {}]
      end

      def commit_state(state, message)
        intersection = (@state.to_a | state.to_a) - (@state.to_a & state.to_a)
        count = intersection.to_h.size
        @state = state.dup
        @commits.push(Commit.new state, message)
        Result.new "#{message}\n\t#{count} objects changed", true, last_commit
      end

      def last_commit
        @commits.last
      end

      def commits_string
        @commits.empty? ? nil : @commits.reverse.join("\n\n")
      end

      def checkout(hash)
        commit_index = @commits.index{|commit| commit.hash == hash}
        commit_index ? (@commits = commits[0..commit_index]).last : nil
      end

      class Commit
        attr_reader :hash, :commit_message
        def initialize(state, message)
          @state = state
          @commit_message = message
          @date = Time.now
          @hash = Digest::SHA1.hexdigest "#{@date}#{@message}"
        end

        def date
          @date
        end

        def message
          @commit_message
        end

        def hash
          @hash
        end

        def objects
          @state.values
        end

        def to_s
          format = "%a %b %d %H:%M %Y %z"
          "Commit #{@hash}\nDate: #{@date.strftime format}\n\n\t#{@message}"
        end
      end
    end
  end

  class Result
    def initialize(message, successful, result = nil)
      @message = message
      @successful = successful
      @result = result
    end

    def success?
      @successful
    end

    def error?
      ! @successful
    end

    def result
      @result
    end

    def message
      @message
    end

    def to_s
      message
    end
  end
end
