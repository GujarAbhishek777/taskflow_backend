# TaskFlow Backend API 🚀

[![Ruby Version](https://img.shields.io/badge/Ruby-3.2.0-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/Rails-8.0.1-brightgreen.svg)](https://rubyonrails.org/)
[![Database](https://img.shields.io/badge/MySQL-8.0+-blue.svg)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**TaskFlow Backend** is a high-performance, multi-tenant RESTful API built with **Ruby on Rails 8** and **MySQL**. It provides the core backend services for the TaskFlow project, handling organization management, task creation and assignment, real-time collaboration messaging, role-based access control (RBAC), analytical telemetry, and automated PDF resume/document generation.

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack & Dependencies](#-tech-stack--dependencies)
- [System Architecture & Multi-Tenancy](#-system-architecture--multi-tenancy)
- [Database Schema & Models](#-database-schema--models)
- [API Documentation](#-api-documentation)
- [Environment Variables & Configuration](#-environment-variables--configuration)
- [Getting Started (Local Development)](#-getting-started-local-development)
- [Docker & Production Deployment](#-docker--production-deployment)
- [Project Structure](#-project-structure)
- [Code Quality & Testing](#-code-quality--testing)

---

## ✨ Features

- **Multi-Tenant Workspace Isolation**: Scopes all users, tasks, and messages under tenant organizations (`Client`), keeping organization data secure and separate.
- **JWT Authentication & Authorization**: Stateless JSON Web Token authentication built on Devise with token expiration and security verification.
- **Role-Based Access Control (RBAC)**:
  - **Admin**: Full control over organization users, task visibility, and settings.
  - **Task Creator**: Ability to create tasks and manage assigned/created tasks.
  - **Regular User**: Access restricted to assigned tasks and direct communication.
- **Task Management**: Endpoints to create, assign, update, and filter tasks by status (`Created`, `In Progress`, `On Hold`, `Cancelled`, `Completed`).
- **Dashboard Telemetry & Analytics**: Provides task distribution stats for pie chart visualizers and recent task feeds.
- **Team Messaging**: Real-time communication channels between users within the same tenant client.
- **Dynamic PDF Generation**: Generates formatted PDF resumes and documents on-the-fly using `prawn` and the [`resume_maker`](https://github.com/GujarAbhishek777/resume_maker.git) gem.
- **Rails 8 Solid Stack Integration**: Uses `solid_cache`, `solid_queue`, and `solid_cable` for database-backed caching, asynchronous jobs, and websockets.
- **Production Containerization**: Multi-stage `Dockerfile` coupled with `Thruster` sidecar HTTP caching for maximum Puma web server performance.

---

## 🛠 Tech Stack & Dependencies

| Layer | Technology |
| :--- | :--- |
| **Language** | Ruby 3.2.0 |
| **Framework** | Ruby on Rails 8.0.1 (API mode) |
| **Database** | MySQL (via `mysql2` gem, utf8mb4 encoding) |
| **Web Server** | Puma `>= 5.0` with Thruster proxy acceleration |
| **Authentication** | Devise + `devise-jwt` + `jwt` |
| **CORS Middleware** | `rack-cors` |
| **PDF Processing** | `prawn` + [`resume_maker`](https://github.com/GujarAbhishek777/resume_maker.git) |
| **Caching & Queues** | Rails 8 Solid Stack (`solid_cache`, `solid_queue`, `solid_cable`) |
| **Deployment** | Docker, Kamal |
| **Linting & Security** | RuboCop (`rubocop-rails-omakase`), Brakeman |

---

## 🏛 System Architecture & Multi-Tenancy

TaskFlow uses a **Client-centric Multi-Tenant architecture**:
1. When a user registers (`/api/v1/sign_up`), a new `Client` organization is created using `params[:user][:cname]`.
2. The registering user automatically becomes an `Admin` and `Task Creator` under that `Client`.
3. Subsequent operations (creating users, fetching tasks, fetching messages) scope queries via `client_id: @current_user.client_id`.

```
                  +-----------------------------------+
                  |        Client (Tenant Org)        |
                  +-----------------+-----------------+
                                    |
          +-------------------------+-------------------------+
          |                         |                         |
          v                         v                         v
   +--------------+          +--------------+          +--------------+
   |  User Models |          |  Task Models |          |Message Models|
   +--------------+          +--------------+          +--------------+
```

---

## 🗄 Database Schema & Models

### Core Models & Relationships

- **`Client`**: `has_many :users`
  - Attributes: `name`
- **`User`**: `belongs_to :client`
  - Attributes: `email`, `encrypted_password`, `name`, `last_name`, `designation`, `admin` (boolean), `task_creator` (boolean), `client_name`, `client_id`
- **`Task`**
  - Attributes: `title`, `description`, `user_name`, `user_id` (assigned user), `due_date`, `status` (`Created`, `In Progress`, `On Hold`, `Cancelled`, `Completed`), `status_value`, `client_id`, `creator` (user ID who created task)
- **`Message`**
  - Attributes: `content`, `senderId`, `receiverId`, `client_id`

---

## 🔌 API Documentation

All protected endpoints require an `Authorization` HTTP header with a valid Bearer JWT:
```http
Authorization: Bearer <jwt_token>
```

### 1. Authentication & Session Endpoints

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/sign_up` | Registers new admin user & creates new Client organization | No |
| `POST` | `/api/v1/sign_in` | Authenticates user & returns JWT token | No |
| `GET` | `/api/v1/check_auth` | Validates session token & returns current user data | Yes |

### 2. User Management Endpoints

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/users` | Fetches all users within current client organization | Yes |
| `POST` | `/api/v1/add_user` | Creates & invites a new user under current client organization | Yes |

### 3. Task Management Endpoints

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/tasks` | Lists scoped tasks (Admin sees all, creators/users see allowed) + list of users | Yes |
| `POST` | `/api/v1/add_task` | Creates a new task assigned to a team member | Yes |
| `GET` | `/api/v1/tasks_data` | Dashboard analytics (pie chart counts + recent 5 tasks if `from_dash=true`) | Yes |

### 4. Messaging & PDF Generation Endpoints

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/messages` | Fetches all organization chat messages & user list | Yes |
| `POST` | `/api/v1/add_message` | Sends a message from sender to receiver | Yes |
| `POST` | `/api/v1/pdf_generator` | Accepts JSON form data and streams compiled binary PDF resume | No |

---

## ⚙️ Environment Variables & Configuration

Configure these environment variables in your deployment environment or `.env` setup:

| Variable | Default (Dev) | Description |
| :--- | :--- | :--- |
| `RAILS_ENV` | `development` | Rails runtime mode (`development`, `test`, `production`) |
| `DB_HOST` | `127.0.0.1` | MySQL server hostname |
| `DB_PORT` | `3306` | MySQL server port |
| `DB_USERNAME` | `root` | Database user name |
| `DB_PASSWORD` | `Sumal@777` | Database user password |
| `DB_SOCKET` | `/tmp/mysql.sock` | MySQL socket path (if local connection) |
| `RAILS_MAX_THREADS` | `5` | Maximum database connection pool / Puma threads |
| `RAILS_MASTER_KEY` | — | Master key to decrypt `config/credentials.yml.enc` |

---

## 🚀 Getting Started (Local Development)

### Prerequisites

- **Ruby**: `3.2.0` (Recommended via `rbenv` or `rvm`)
- **MySQL Server**: `8.0+`
- **Bundler**: `gem install bundler`

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/GujarAbhishek777/TaskFlow.git
   cd TaskFlow/taskflow_backend
   ```

2. **Install Ruby dependencies**:
   ```bash
   bundle install
   ```

3. **Configure Database**:
   Ensure your MySQL server is running, then create and migrate the database:
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

4. **Start the Rails Development Server**:
   ```bash
   bin/rails server -p 3000
   ```
   The backend API will now be running at `http://localhost:3000`.

---

## 🐳 Docker & Production Deployment

### Building and Running via Docker

The repository includes an optimized multi-stage `Dockerfile`:

1. **Build the Docker Image**:
   ```bash
   docker build -t taskflow_backend .
   ```

2. **Run Container**:
   ```bash
   docker run -d \
     -p 80:80 \
     -e RAILS_MASTER_KEY=<your_rails_master_key> \
     -e DB_HOST=<mysql_host> \
     -e DB_USERNAME=<mysql_user> \
     -e DB_PASSWORD=<mysql_password> \
     --name taskflow_backend \
     taskflow_backend
   ```

### Kamal Deployment

Deploy with [Kamal](https://kamal-deploy.org/):
```bash
kamal setup
```

---

## 📁 Project Structure

```
taskflow_backend/
├── app/
│   ├── controllers/
│   │   ├── api/v1/            # API Controllers (Sessions, Registrations, Tasks, Users, Messages, PDF)
│   │   └── application_controller.rb  # Authentication & JWT handling
│   ├── models/                # ActiveRecord Models (User, Client, Task, Message)
│   ├── jobs/                  # Background job definitions (Solid Queue)
│   └── views/                 # API View templates (if applicable)
├── config/
│   ├── initializers/          # CORS, Devise, Filter logging configurations
│   ├── database.yml           # Database configuration
│   └── routes.rb              # API Route definitions
├── db/
│   ├── migrate/               # ActiveRecord database migrations
│   └── schema.rb              # Current database schema
├── Dockerfile                 # Production multi-stage Docker build
└── Gemfile                    # Dependency manifest
```

---

## 🧪 Code Quality & Testing

- **Run Test Suite**:
  ```bash
  bin/rails test
  ```
- **Run RuboCop Linter**:
  ```bash
  bundle exec rubocop
  ```
- **Run Security Audit with Brakeman**:
  ```bash
  bundle exec brakeman
  ```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

