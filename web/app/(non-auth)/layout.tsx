import { headers } from 'next/headers';
import { redirect } from 'next/navigation';
import { auth } from '@/lib/auth';

// This is more just to redirect the user to sign in/up when first visiting
// the app, since it doesn't really do them any good to know about anyone
// else's instruments.
export default async function AuthRedirect({ children }: LayoutProps<"/">) {
  
  const hdr = await headers();
  
  if (!await auth.api.getSession({ headers: hdr })) {
    redirect("/sign-in");
  }
  
  return (
    <>
      { children }
    </>
  );
}
