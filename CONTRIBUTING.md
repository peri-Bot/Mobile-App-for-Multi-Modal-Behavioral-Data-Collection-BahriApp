# Welcome to BahriApp contributing guide
Welcome to the BahriApp development team! This guide will help streamline our development process and ensure that our contributions are consistent and effective. Please follow these guidelines for a smooth collaboration.

## Table of Contents

1. [Development Workflow](#development-workflow)
2. [Branching Strategy](#branching-strategy)
3. [Coding Standards](#coding-standards)
4. [Testing](#testing)
5. [Documentation](#documentation)
6. [Code Reviews](#code-reviews)
7. [Issue Tracking](#issue-tracking)
8. [Communication](#communication)

## Development Workflow

1. **Setup:** Clone the repository and install dependencies.
   ```bash
   git clone https://github.com/peri-Bot/Mobile-App-for-Multi-Modal-Behavioral-Data-Collection-BahriApp.git
   cd bahri_app
   # Follow project-specific setup instructions
   ```

2. **Development:** Create a new branch for each feature or bug fix.
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Commit:** Make sure your commits are descriptive and follow the format:
   ```
   [TYPE] Short description of changes

   Detailed description of changes.
   ```
   Where TYPE is one of: `feat` (for new features), `fix` (for bug fixes), `docs` (for documentation), `style` (for formatting), `refactor` (for code refactoring), `test` (for adding tests), `chore` (for maintenance tasks).

4. **Push and Create Pull Request:** Push your changes and open a pull request (PR) on GitHub.
   ```bash
   git push origin feature/your-feature-name
   ```

## Branching Strategy

- **main:** The stable branch containing production-ready code.
- **develop:** The branch for integrating features and bug fixes.
- **feature/***: Branches for new features or improvements.
- **bugfix/***: Branches for fixing bugs.

## Coding Standards

- Follow [Flutter’s coding conventions](https://flutter.dev/docs/development/tools/sdk/releases).
- Use meaningful variable and function names.
- Ensure code is clean, well-organized, and commented where necessary.

## Testing

- Write tests for new features and bug fixes.
- Run all tests before submitting a pull request.
- Use [Flutter’s testing framework](https://flutter.dev/docs/testing) and follow best practices for unit and widget testing.

## Documentation

- Update documentation as part of your PR if changes affect the existing documentation.
- Use clear, concise language and include examples where applicable.

## Code Reviews

- All pull requests must be reviewed by at least one team member before merging.
- Provide constructive feedback and ask clarifying questions if needed.

## Issue Tracking

- Use GitHub issues to track bugs, features, and tasks.
- Assign issues to yourself before starting work and provide regular updates.
- Use labels to categorize issues (e.g., `bug`, `enhancement`, `question`).

## Communication

- Use the project’s preferred communication channels (e.g., Slack, Microsoft Teams) for discussions and updates.
- Be respectful and clear in your communication to maintain a positive working environment.

---

Feel free to adjust any sections as needed based on your team’s specific workflow and preferences!
