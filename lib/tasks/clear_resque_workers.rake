task :clear_resque_workers do
	Resque.workers.each {|w| w.unregister_worker}
end