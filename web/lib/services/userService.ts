import 'dotenv/config';
import { headers } from 'next/headers';
import { auth } from '@/lib/auth';

// Keep the default user ID here for single user setups. 
export const DEFAULT_USER = "singleuser";

// Function to return the ID of the current user, regardless of whether the app
// is being used in a single user or multi-user setup. The app just needs to
// check if the user ID is null, otherwise the user should be good to go.
export async function getUserId(): Promise<string | null> {
  
  if (process.env.SV_SINGLE_USER) {
    
    return process.env.SV_SINGLE_USER_ID ?? DEFAULT_USER;
    
  } else {
    const hdr = await headers();
    
    const sess = await auth.api.getSession({ headers: hdr });
    
    if (sess) {
      return sess.user.id;
    } else {
      return null;
    }
  }
}
