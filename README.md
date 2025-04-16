# Pretty Todo List App

A beautiful, feminine todo list application built on the Internet Computer platform.

## Features

- ✨ Create tasks with descriptions and due dates
- ✅ Mark tasks as complete
- 🔄 Edit existing tasks
- 🗑️ Delete tasks
- 🔍 Filter tasks (All, Active, Completed, Overdue, By Due Date)
- 💖 Beautiful, girlish UI design with animations and visual feedback

## Screenshots

*[This section would contain screenshots of your application]*

## Technology Stack

- **Backend**: Motoko programming language on the Internet Computer
- **Frontend**: Vue.js with custom CSS styling
- **Deployment**: Internet Computer canister infrastructure

## Running the project locally

To run this project locally, follow these steps:

```bash
# Clone the repository
git clone https://github.com/yourusername/todo_list.git
cd todo_list/

# Install dependencies
npm install

# Start the local Internet Computer replica
dfx start --background

# Deploy the canisters to the local replica
dfx deploy
```

Once deployed, your application will be available at:
- Web UI: `http://localhost:4943?canisterId={frontend_canister_id}`
- API/Candid: `http://localhost:4943?canisterId=__Candid_UI&id={backend_canister_id}`

## Development Workflow

### Backend Changes

If you make changes to the Motoko backend, regenerate the Candid interface:

```bash
dfx generate
```

Then redeploy the backend:

```bash
dfx deploy todo_list_backend
```

### Frontend Changes

For frontend development:

```bash
# Start the development server
npm start
```

This will start a server at `http://localhost:8080`, proxying API requests to the replica.

## Project Structure

- todo_list_backend - Motoko backend code
  - `main.mo` - Main actor containing todo list logic
- todo_list_frontend - Vue.js frontend code
  - `src/App.vue` - Main application component
  - `public/` - Static assets

## API Reference

The backend canister provides the following methods:

- `addTask(description: Text, dueDays: Int)` - Add a new task
- `getTasks()` - Get all tasks
- `getCompletedTasks()` - Get completed tasks
- `getIncompleteTasks()` - Get active (incomplete) tasks
- `getOverdueTasks()` - Get overdue tasks
- `getTasksSortedByDueDate()` - Get tasks sorted by due date
- `completeTask(id: Nat)` - Mark a task as completed
- `editTaskDescription(id: Nat, newDescription: Text)` - Edit task description
- `editTaskDueDate(id: Nat, newDueDays: Int)` - Edit task due date
- `deleteTask(id: Nat)` - Delete a task

## Resources

Learn more about Internet Computer development:

- [Quick Start](https://internetcomputer.org/docs/current/developer-docs/setup/deploy-locally)
- [SDK Developer Tools](https://internetcomputer.org/docs/current/developer-docs/setup/install)
- [Motoko Programming Language Guide](https://internetcomputer.org/docs/current/motoko/main/motoko)
- [Motoko Language Quick Reference](https://internetcomputer.org/docs/current/motoko/main/language-manual)

## Deployment to the Internet Computer Mainnet

To deploy to the IC mainnet:

```bash
dfx deploy --network ic
```

Note: This requires cycles and an identity with cycles to pay for canister creation and computation.
