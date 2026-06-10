import Link from "next/link";
import { signup } from "../actions";

export default async function SignupPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string }>;
}) {
  const params = await searchParams;
  const error = params?.error;

  return (
    <div className="flex flex-col gap-4 text-center">
      <h1 className="text-2xl font-semibold text-foreground">Create an account</h1>
      <p className="text-sm text-muted-foreground">Sign up to get started with FinancialIntelAI</p>
      
      {error && (
        <div className="bg-red-50 text-red-600 p-3 rounded-md text-sm text-left border border-red-200">
          {error}
        </div>
      )}
      
      <form action={signup} className="flex flex-col gap-4 mt-4">
        <div className="flex flex-col gap-2 text-left">
          <label htmlFor="email" className="text-sm font-medium">Email</label>
          <input 
            id="email" 
            name="email" 
            type="email" 
            required
            placeholder="you@company.com" 
            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
          />
        </div>
        <div className="flex flex-col gap-2 text-left">
          <label htmlFor="password" className="text-sm font-medium">Password</label>
          <input 
            id="password" 
            name="password" 
            type="password" 
            required
            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
          />
        </div>
        <button 
          type="submit" 
          className="inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2 mt-2 cursor-pointer"
        >
          Sign Up
        </button>
      </form>
      
      <p className="text-sm text-muted-foreground mt-4">
        Already have an account?{" "}
        <Link href="/login" className="text-primary hover:underline font-medium">
          Sign in
        </Link>
      </p>
    </div>
  );
}
