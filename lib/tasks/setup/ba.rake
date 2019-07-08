namespace :setup do
  namespace :ba do
    desc 'initial setup rake'
    task load: :environment do |task|

      tasks = [
        'setup:admin:load',
        'setup:cities:load',
        'setup:classifications:ba:load',
        'setup:integrations:load',
        'oauth:applications:load'
      ]

      tasks.each { |task| with_feedback(task) { Rake::Task[task].invoke } }
    end

    def with_feedback(task)
      spinner = TTY::Spinner.new("[:spinner] #{task}")
      spinner.auto_spin
      begin
        yield
      rescue => e
        spinner.error("- Erro: #{e.message}")
      end

      spinner.success
    end
  end
end
