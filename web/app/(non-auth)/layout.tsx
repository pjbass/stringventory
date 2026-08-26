import 'dotenv/config';
import { redirect } from 'next/navigation';
import { getUserId } from '@/lib/services/userService';

// This is more just to redirect the user to sign in/up when first visiting
// the app, since it doesn't really do them any good to know about anyone
// else's instruments.
export default async function AuthRedirect({ children }: LayoutProps<"/">) {
  
  if (!await getUserId()) {
    redirect("/sign-in");
  }
  
  return (
    <>
      { children }
    </>
  );
}
