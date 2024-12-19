require 'sinatra'
require 'securerandom'

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

    def db2
        return @db2 if @db2
        @db2 = SQLite3::Database.new("db/loginexample.sqlite")
        @db2.results_as_hash = true
        return @db2
    end

    configure do
        enable :sessions
        set :session_secret, SecureRandom.hex(64)
    end

    get '/' do
        if session[:user_id]
          erb(:"admin")
        else
          erb :index
        end
      end
    
      post '/testpwcreate' do
        plain_password = params[:plainpassword]
        password_hashed = BCrypt::Password.create(plain_password)
        p password_hashed
      end
    
      get '/admin' do
        if session[:user_id]
          erb(:"admin")
        else
          p "/admin : Access denied."
          status 401
          redirect '/unauthorized'
        end
      end
    
      get '/unauthorized' do
        erb(:unauthorized)
      end
    
      post '/login' do
        request_username = params[:username]
        request_plain_password = params[:password]
    
        user = db.execute("SELECT *
                FROM users
                WHERE username = ?",
                request_username).first
    
        unless user
          p "/login : Invalid username."
          status 401
          redirect '/unauthorized'
        end
    
        db_id = user["id"].to_i
        db_password_hashed = user["password"].to_s
    
        # Create a BCrypt object from the hashed password from db
        bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
        # Check if the plain password matches the hashed password from db
        if bcrypt_db_password == request_plain_password
          p "/login : Logged in -> redirecting to admin"
          session[:user_id] = db_id
          redirect '/admin'
        else
          p "/login : Invalid password."
          status 401
          redirect '/unauthorized'
        end
    
      end
    
      get '/logout' do
        p "/logout : Logging out"
        session.clear
        redirect '/'
      end
    
    post '/sign-up' do
      db.execute('INSERT INTO users (username, password) VALUES(?,?)',
    [ params['new_username'],
      params['new_password']
    ])
    current_user=params[:new_username]
    redirect '/'
    end

    get '/tasks' do
        @tasks = db.execute('SELECT * FROM todo')
        @ongoing_tasks = db.execute('SELECT * FROM todo WHERE ongoing = 1 ORDER BY importance')
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

    post '/tasks/:id/complete' do |id|
        db.execute('DELETE FROM todo WHERE id=?', id)
        redirect "/"
    end

    get '/tasks/:id/edit' do | id |
        @task = db.execute('SELECT * FROM todo WHERE id = ?', id).first
        erb(:"edit")
    end

    post '/tasks/:id/update' do |id|
        title=params[:title]
        beskrivning=params[:beskrivning]
        subject=params[:subject]
        importance=params[:importance]
        db.execute('UPDATE todo SET title=?, beskrivning=?, subject=?, importance=? WHERE id=?',
        [title, beskrivning, subject, importance, id])
        redirect "/"
    end
end
