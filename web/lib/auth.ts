import { betterAuth } from 'better-auth';
import { prismaAdapter } from 'better-auth/adapters/prisma';
import prisma from '@/lib/prisma';
import { redirect } from 'next/navigation';

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

// Creates a thin wrapper around a JSON response to ensure that the message is
// consistent across the API for an unauthenticated request.
export const api401 = () => Response.json({
    error: 'Please log in to make use of this API'
  }, { status: 401 });


