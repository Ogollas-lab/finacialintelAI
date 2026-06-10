# Financial Intel AI

Financial Intel AI is a modern, high-performance web application built to provide intelligent financial insights and analytics. It leverages the latest web technologies to deliver a fast, secure, and beautiful user experience.

## Tech Stack

This project is built using a cutting-edge, modern web development stack:

- **Framework**: [Next.js 16](https://nextjs.org/) (App Router)
- **Styling**: [Tailwind CSS v4](https://tailwindcss.com/)
- **UI Components**: [shadcn/ui](https://ui.shadcn.com/) & [Radix UI](https://www.radix-ui.com/)
- **Authentication & Database**: [Supabase](https://supabase.com/) (SSR Auth)
- **Icons**: [Lucide React](https://lucide.dev/)
- **Linting & Formatting**: [Biome](https://biomejs.dev/)
- **Language**: TypeScript

## Project Structure

The project follows a standard Next.js App Router structure with customized areas for authentication and Supabase integration:

```text
financial-intel-ai/
├── src/
│   ├── app/
│   │   ├── (auth)/        # Authentication routes
│   │   │   ├── login/     # Login page and forms
│   │   │   ├── signup/    # Signup page and forms
│   │   │   └── actions.ts # Server actions for auth
│   │   ├── globals.css    # Global styles and Tailwind config
│   │   └── page.tsx       # Landing page
│   ├── components/        # Reusable UI components (shadcn)
│   ├── lib/
│   │   └── supabase/      # Supabase clients & configuration
│   │       ├── middleware.ts # Edge middleware logic for session
│   │       ├── client.ts     # Browser client
│   │       └── server.ts     # Server client
│   └── middleware.ts      # Next.js middleware router
├── .vscode/               # Workspace settings
├── biome.json             # Linter and formatter configuration
└── components.json        # shadcn/ui configuration
```

## Getting Started

Follow these instructions to run the application locally.

### Prerequisites

- Node.js (v20 or higher recommended)
- A Supabase account and project

### Installation

1. **Clone the repository and navigate into it:**
   ```bash
   git clone <repository-url>
   cd financial-intel-ai
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up Environment Variables:**
   Create a `.env.local` file in the root of the project and add your Supabase credentials. You can find these in your Supabase project settings.
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Run the development server:**
   ```bash
   npm run dev
   ```

5. **Open the App:**
   Open [http://localhost:3000](http://localhost:3000) with your browser to see the result. You can test the authentication flow by navigating to `/login` and `/signup`.

## Development Guidelines

- **Linting & Formatting**: We use Biome instead of ESLint and Prettier. It runs significantly faster and handles both formatting and linting.
  ```bash
  npx @biomejs/biome check --write ./src
  ```
- **Component Addition**: Add new UI components using the shadcn CLI:
  ```bash
  npx shadcn@latest add <component-name>
  ```
- **Authentication**: All protected routes are secured via `src/middleware.ts` which runs on the Edge runtime and validates the Supabase session before allowing access.

## License

This project is private and confidential.
