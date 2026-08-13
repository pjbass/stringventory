import 'dotenv/config';
import { betterAuth } from 'better-auth';
import { prismaAdapter } from 'better-auth/adapters/prisma';
import prisma from '@/lib/prisma';
import { redirect } from 'next/navigation';
import { headers } from 'next/headers';

export const auth = betterAuth({
  database: prismaAdapter(prisma, {
    provider: 'sqlite',
  }),
  emailAndPassword: {
    enabled: true,
  },
  signUp: {
    onSuccess: async () => {
      redirect('/');
    },
  },
  signIn: {
    onSuccess: async () => {
      redirect('/');
    },
  },
});

// Keep the default user ID here for single user setups. 
export const DEFAULT_USER = "singleuser";

// Creates a thin wrapper around a JSON response to ensure that the message is
// consistent across the API for an unauthenticated request.
export const api401 = () => Response.json({
    error: 'Please log in to make use of this API'
  }, { status: 401 });

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
