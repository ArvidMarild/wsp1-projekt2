class App < Sinatra::Base

    get '/' do
        erb(:"index")
    end

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todo.sqlite")
        @db.results_as_hash = true

        return @db
    end

    get '/task' do
        @tasks = db.execute('SELECT * FROM todo')
        @ongoing_tasks = db.execute('SELECT * FROM todo ')
    end

    post '/todo/' do
        db.execute("INSERT INTO todo (title, beskrivning, subject) VALUES(?,?,?)", 
        [   
            params["title"],
            params["beskrivning"],
            params["subject"]
        ])
        redirect ""
    end
end
