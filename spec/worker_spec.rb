require 'helper'

describe Delayed::Worker do
  describe "#run (called via #start) removal of completed jobs" do
    before do
      @worker = Delayed::Worker.new(:exit_on_complete => true)
      @job = double('job', :id => 123, :name => 'ExampleJob', :invoke_job => true, :destroy => true, :attempts => 42, :attempts= => true, :max_attempts => 2, :hook => nil)
      expect(Delayed::Job).to receive(:reserve).at_least(:once) do
        value = @already_did_one ? nil : @job
        @already_did_one = true
        value
      end
    end

    it "works if the destroy succeeds" do
      @worker.start
    end

    describe "when deadlocks occur" do
      before do
        @activerecord_error = ActiveRecord::StatementInvalid.exception("Mysql2::Error: Lock wait timeout exceeded; try restarting transaction: DELETE FROM delayed_job WHERE id = 42")

        @counter = 0
        @n = -1
        @job.stub(:destroy) do
          @counter += 1
          raise @activerecord_error if @counter <= @n
        end
      end

      it "retries up to 3 times if destroy fails with a deadlock before succeeding" do
        @n = 3
        @worker.start
      end

      it "raises a deadlock exception if destroy raises one more than 3 times" do
        @n = 4
        @job.should_receive(:last_error=)
        @worker.start
      end
    end
  end

  describe "backend=" do
    before do
      @clazz = Class.new
      Delayed::Worker.backend = @clazz
    end

    after do
      Delayed::Worker.backend = :test
    end

    it "sets the Delayed::Job constant to the backend" do
      expect(Delayed::Job).to eq(@clazz)
    end

    it "sets backend with a symbol" do
      Delayed::Worker.backend = :test
      expect(Delayed::Worker.backend).to eq(Delayed::Backend::Test::Job)
    end
  end

  describe "job_say" do
    before do
      @worker = Delayed::Worker.new
      @job = double('job', :id => 123, :name => 'ExampleJob')
    end

    it "logs with job name and id" do
      expect(@worker).to receive(:say).
        with('Job ExampleJob (id=123) message', Delayed::Worker::DEFAULT_LOG_LEVEL)
      @worker.job_say(@job, 'message')
    end
  end

  context "worker read-ahead" do
    before do
      @read_ahead = Delayed::Worker.read_ahead
    end

    after do
      Delayed::Worker.read_ahead = @read_ahead
    end

    it "reads five jobs" do
      expect(Delayed::Job).to receive(:find_available).with(anything, 5, anything).and_return([])
      Delayed::Job.reserve(Delayed::Worker.new)
    end

    it "reads a configurable number of jobs" do
      Delayed::Worker.read_ahead = 15
      expect(Delayed::Job).to receive(:find_available).with(anything, Delayed::Worker.read_ahead, anything).and_return([])
      Delayed::Job.reserve(Delayed::Worker.new)
    end
  end

  context "worker exit on complete" do
    before do
      Delayed::Worker.exit_on_complete = true
    end

    after do
      Delayed::Worker.exit_on_complete = false
    end

    it "exits the loop when no jobs are available" do
      worker = Delayed::Worker.new
      Timeout::timeout(2) do
        worker.start
      end
    end
  end

  context "worker job reservation" do
    before do
      Delayed::Worker.exit_on_complete = true
    end

    after do
      Delayed::Worker.exit_on_complete = false
    end

    it "handles error during job reservation" do
      expect(Delayed::Job).to receive(:reserve).and_raise(Exception)
      Delayed::Worker.new.work_off
    end

    it "gives up after 10 backend failures" do
      expect(Delayed::Job).to receive(:reserve).exactly(10).times.and_raise(Exception)
      worker = Delayed::Worker.new
      9.times { worker.work_off }
      expect(lambda { worker.work_off }).to raise_exception
    end

    it "allows the backend to attempt recovery from reservation errors" do
      expect(Delayed::Job).to receive(:reserve).and_raise(Exception)
      expect(Delayed::Job).to receive(:recover_from).with(instance_of(Exception))
      Delayed::Worker.new.work_off
    end

    it "allows for an injected job_class" do
      test_job_class = double
      worker = Delayed::Worker.new(job_class: test_job_class)
      expect(test_job_class).to receive(:reserve).with(worker).and_return(nil)
      worker.work_off(1)
    end
  end
end
