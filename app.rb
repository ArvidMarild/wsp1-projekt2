class App < Sinatra::Base

    get '/' do
        redirect "/tasks"
    end

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todo.sqlite")
        @db.results_as_hash = true

        return @db
    end

    get '/tasks' do
        @tasks = db.execute('SELECT * FROM todo')
        @ongoing_tasks = db.execute('SELECT * FROM todo WHERE ongoing = 1 ORDER BY importance')
        @completed_tasks = db.execute('SELECT * FROM todo WHERE ongoing = 0 ORDER BY importance')
        erb(:"index")
    end

    post '/todo/' do
        db.execute("INSERT INTO todo (title, beskrivning, subject, ongoing, importance) VALUES(?,?,?,?,?)", 
        [   
            params["title"],
            params["beskrivning"],
            params["subject"],
            1,
            params["importance"]
        ])
        redirect "/"
    end
end
