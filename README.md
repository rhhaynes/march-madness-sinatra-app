# march-madness-sinatra-app

Sinatra MVC web application with CRUD functionality for generating bracket predictions in the
2018 NCAA Division 1 Men's Basketball Tournament.

After creating an account, users have the ability to fill out a bracket. Once complete, users
can view, edit, and delete their bracket.

At any time a user can view the teams in the tournament as well as brackets submitted by other users.

## Usage

To use this application, clone the repository and

(1) run `rake db:migrate db:seed`
> Creates the schema and seeds the database with 64 tournament teams as well as 100 sample users
and their corresponding brackets (randomly generated).

(2) run `shotgun`
> Starts the application.
