# Meepo
Meepo is a free social networking site where people converse with each other in short messages

<a href="https://meepo-app.onrender.com">Try it now</a>

## Tech stack
- [Ruby on Rails](https://www.typescriptlang.org/) - Full-stack Framework
- [PostgreSQL](https://www.postgresql.org/) - Relational Database
- [Redis](https://redis.io/) - In-memory data structure store, use to cache data

## Installation Guide
> **Note**
> Requirements: [Ruby](https://www.ruby-lang.org/en/) >= 3.0.0

1. **Clone the GitHub repository**
```bash
https://github.com/dauphaihau/meepo-be.git
```

2. **Configure Database**

   set your database url into config/database.yml


3. **Configure Cache store**

   set your redis url into config/cable.yml


4. **Install gems**
```bash
bundle install
```

5. **Runs migrations**
```bash
rails db:migrate
```
6. **Launches a web server**
```bash
rails s
```
