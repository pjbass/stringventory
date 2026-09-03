import SchemaBuilder from '@pothos/core';
import PrismaPlugin from '@pothos/plugin-prisma';
import ScopeAuthPlugin from '@pothos/plugin-scope-auth';
import prisma from '@/lib/prisma';
import { createYoga } from 'graphql-yoga';
import { getUserId } from '@/lib/services/userService';
import { DateTimeResolver } from 'graphql-scalars';
import * as InsServ from '@/lib/services/instrumentService';
import * as ITServ from '@/lib/services/instrumentTypeService';

import type PrismaTypes from '@/generated/pothos-prisma-types';
import { getDatamodel } from '@/generated/pothos-prisma-types';

const builder = new SchemaBuilder<{
  AuthScopes: {
    loggedIn: boolean;
  };
  DefaultInputFieldRequiredness: true;
  Context: { userId: string };
  PrismaTypes: PrismaTypes; // This gives the builder all the type information about your prisma schema
  Scalars: {
    DateTime: {
      Input: Date | string;
      Output: Date;
    };
  };
}>({
  plugins: [ScopeAuthPlugin, PrismaPlugin],
  defaultInputFieldRequiredness: true,
  scopeAuth: {
    treatErrorsAsUnauthorized: true,
    unauthorizedError: () => `Please log in to use this API`,
    authScopes: (context) => ({
      loggedIn: context.userId !== null,
    }),
  },
  prisma: {
    client: prisma,
    // This give pothos information about your tables, relations, and indexes to help it generate optimal queries at runtime.
    // This used to be attached to the prisma client, but has been removed in most runtimes/modes to reduce bundle size.
    dmmf: getDatamodel(),
    // defaults to false, uses /// comments from prisma schema as descriptions
    // for object types, relations and exposed fields.
    // descriptions can be omitted by setting description to false
    // exposeDescriptions: boolean | { models: boolean, fields: boolean },
    // use where clause from prismaRelatedConnection for totalCount (defaults to true)
    filterConnectionTotalCount: true,
    // warn when not using a query parameter correctly
    onUnusedQuery: process.env.NODE_ENV === 'production' ? null : 'warn',
  },
});

// Check if the user is logged in for every request. After all, the user doesn't
// need to know about any one else's instruments.
builder.queryType({
  authScopes: {
    loggedIn: true,
  },
});

builder.mutationType({
  authScopes: {
    loggedIn: true,
  },
});

builder.addScalarType('DateTime', DateTimeResolver);

builder.prismaObject("User", {
  fields: (t) => ({
    id: t.exposeID('id'),
    name: t.exposeString('name'),
    email: t.exposeString('email'),
    instruments: t.relation("instruments"),
  })
});

builder.prismaObject("Instrument", {
  fields: (t) => ({
    id: t.exposeID('id'),
    name: t.exposeString('name'),
    owner: t.relation("owner"),
    purchased: t.field({
      type: 'DateTime',
      resolve: (parent) => new Date(parent.purchased),
    }),
    modified: t.field({
      type: 'DateTime',
      resolve: (parent) => new Date(parent.modified),
    }),
    insType: t.relation("insType"),
    //features: t.relation("features"),
    //maintenance: t.relation("maintenance"),
  })
});

builder.prismaObject("InstrumentType", {
  fields: (t) =>({
    id: t.exposeID('id'),
    name: t.exposeString('name'),
    instruments: t.relation('instruments'),
  }),
});

builder.queryField('instruments', (t) =>
  t.prismaField({
    type: ['Instrument'],
    resolve: async (query, _parent, _args, context) => (
      await InsServ.getAll(context.userId, query)
    )
  })
);

builder.queryField('instrument', (t) =>
  t.prismaField({
    type: 'Instrument',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) => (
      await InsServ.getById(context.userId, args.id, query)
    )
  })
);

builder.queryField('searchInstruments', (t) =>
  t.prismaField({
    type: ['Instrument'],
    args: {
      name: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) => (
      await InsServ.searchByName(context.userId, args.name, query)
    )
  })
);

builder.mutationField('addInstrument', (t) =>
  t.prismaField({
    type: 'Instrument',
    args: {
      serial: t.arg.string(),
      name: t.arg.string(),
      type: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) => 
      await InsServ.create(context.userId, args.serial, args.name, args.type, query),
  })
);

builder.mutationField('updateInstrument', (t) =>
  t.prismaField({
    type: 'Instrument',
    args: {
      id: t.arg.int(),
      name: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) =>
      await InsServ.update(context.userId, args.id, args.name, query),
  })
);

builder.mutationField('deleteInstrument', (t) =>
  t.prismaField({
    type: 'Instrument',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) =>
      await InsServ.rm(context.userId, args.id, query),
  })
);

builder.queryField('instrumentTypes', (t) =>
  t.prismaField({
    type: ['InstrumentType'],
    resolve: async (query, _parent, _args, context) => (
      await ITServ.getAll(context.userId, query)
    )
  })
);

builder.queryField('instrumentType', (t) =>
  t.prismaField({
    type: 'InstrumentType',
    args: {
      id: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) => (
      await ITServ.getById(context.userId, args.id, query)
    )
  })
);

builder.queryField('searchInstrumentTypes', (t) =>
  t.prismaField({
    type: ['InstrumentType'],
    args: {
      name: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) => (
      await ITServ.searchByName(context.userId, args.name, query)
    )
  })
);

builder.mutationField('addInstrumentType', (t) =>
  t.prismaField({
    type: 'InstrumentType',
    args: {
      name: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) => 
      await ITServ.create(args.name, query),
  })
);

const schema = builder.toSchema();

interface NextContext {
  params: Promise<Record<string, string>>
}

const handler = createYoga<NextContext>({
  schema,
  graphqlEndpoint: '/api/graphql',
  fetchAPI: { Response },
  context: async () => ({
    userId: await getUserId(),
  }),
});

export { handler as GET, handler as POST, handler as OPTIONS }
