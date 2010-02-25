require 'thread'

class WorkerQueue
  def initialize(&idle_callback)
      @tasks = []
      @cv = ConditionVariable.new
      @idle_callback = idle_callback
      @mutex = Mutex.new
  end

  def << (task)
    @mutex.synchronize do 
      @tasks << task
      @cv.signal
    end
  end

  def run
    loop { next_task.call }
  end

  def next_task
    @mutex.synchronize do 
      @idle_callback.call if @idle_callback and @tasks.empty?
      @cv.wait(@mutex) while @tasks.empty?
      @tasks.shift 
    end
  end
end



