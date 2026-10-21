import SchemaBuilder from '@pothos/core';
import PrismaPlugin from '@pothos/plugin-prisma';
import ScopeAuthPlugin from '@pothos/plugin-scope-auth';
import prisma from '@/lib/prisma';
import { createYoga } from 'graphql-yoga';
import { getUserId } from '@/lib/services/userService';
import { DateResolver } from 'graphql-scalars';
import * as InsServ from '@/lib/services/instrumentService';
import * as ITServ from '@/lib/services/instrumentTypeService';
import * as FtServ from '@/lib/services/featureService';
import * as PtTServ from '@/lib/services/partTypeService';
import * as PtServ from '@/lib/services/partService';
import * as MtServ from '@/lib/services/maintenanceService';
import * as MtTServ from '@/lib/services/maintenanceTypeService';

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
    Date: {
      Input: Date;
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

builder.addScalarType('Date', DateResolver);

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
    serial: t.exposeString('serial'),
    owner: t.relation("owner"),
    purchased: t.field({
      type: 'Date',
      resolve: (parent) => new Date(parent.purchased),
    }),
    modified: t.field({
      type: 'Date',
      resolve: (parent) => new Date(parent.modified),
    }),
    insType: t.relation("insType"),
    features: t.relation("features"),
    maintenance: t.relation("maintenance"),
  })
});

builder.prismaObject("InstrumentType", {
  fields: (t) => ({
    id: t.exposeID('id'),
    name: t.exposeString('name'),
    instruments: t.relation('instruments'),
    owner: t.relation("owner"),
  }),
});

builder.prismaObject("Feature", {
  fields: (t) => ({
    id: t.exposeID('id'),
    name: t.exposeString('name'),
    description: t.exposeString('description'),
    instruments: t.relation('instruments'),
    instTypes: t.relation('instTypes'),
    owner: t.relation("owner"),
    maintenance: t.relation("maintenance"),
  }),
});

builder.prismaObject("Part", {
  fields: (t) => ({
    id: t.exposeID('id'),
    name: t.exposeString('name'),
    description: t.exposeString('description'),
    partType: t.relation("partType"),
    number: t.exposeInt('number'),
    owner: t.relation("owner"),
  }),
});

builder.prismaObject("PartType", {
  fields: (t) => ({
    id: t.exposeID('id'),
    name: t.exposeString('name'),
    description: t.exposeString('description'),
    owned: t.relation("owned"),
    owner: t.relation("owner"),
    usedBy: t.relation("usedBy"),
  }),
});

builder.prismaObject("Maintenance", {
  fields: (t) => ({
    id: t.exposeID('id'),
    due: t.field({
      type: 'Date',
      resolve: (parent) => parent.due ? new Date(parent.due) : null,
    }),
    done: t.field({
      type: 'Date',
      resolve: (parent) => parent.done ? new Date(parent.done) : null,
    }),
    createdAt: t.field({
      type: 'Date',
      resolve: (parent) => new Date(parent.createdAt),
    }),
    mType: t.relation("mType"),
    on: t.relation("on"),
    consumed: t.relation("consumed"),
    owner: t.relation("owner"),
  }),
});

builder.prismaObject("MaintenanceType", {
  fields: (t) => ({
    id: t.exposeID('id'),
    name: t.exposeString('name'),
    description: t.exposeString('description'),
    schedule: t.field({
      type: 'Date',
      resolve: (parent) => parent.schedule ? new Date(parent.schedule) : null,
    }),
    owner: t.relation("owner"),
    parts: t.relation("parts"),
    instances: t.relation("instances"),
    feature: t.relation("feature"),
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
      features: t.arg.stringList(),
    },
    resolve: async (query, _parent, args, context) => 
      await InsServ.create(
        context.userId, 
        args.serial, 
        args.name, 
        args.type, 
        args.features, 
        query),
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
      id: t.arg.int(),
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
      await ITServ.create(context.userId, args.name, query),
  })
);

builder.mutationField('updateInstrumentType', (t) =>
  t.prismaField({
    type: 'InstrumentType',
    args: {
      id: t.arg.int(),
      name: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) =>
      await ITServ.update(context.userId, args.id, args.name, query),
  })
);

builder.mutationField('deleteInstrumentType', (t) =>
  t.prismaField({
    type: 'InstrumentType',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) =>
      await ITServ.rm(context.userId, args.id, query),
  })
);

builder.queryField('features', (t) =>
  t.prismaField({
    type: ['Feature'],
    resolve: async (query, _parent, _args, context) => (
      await FtServ.getAll(context.userId, query)
    )
  })
);

builder.queryField('feature', (t) =>
  t.prismaField({
    type: 'Feature',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) => (
      await FtServ.getById(context.userId, args.id, query)
    )
  })
);

builder.queryField('searchFeatures', (t) =>
  t.prismaField({
    type: ['Feature'],
    args: {
      name: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) => (
      await FtServ.searchByName(context.userId, args.name, query)
    )
  })
);

builder.mutationField('addFeature', (t) =>
  t.prismaField({
    type: 'Feature',
    args: {
      name: t.arg.string(),
      description: t.arg.string({
        //required: false,
        defaultValue: "",
      }),
    },
    resolve: async (query, _parent, args, context) => 
      await FtServ.create(context.userId, args.name, args.description, query),
  })
);

builder.mutationField('updateFeature', (t) =>
  t.prismaField({
    type: 'Feature',
    args: {
      id: t.arg.int(),
      name: t.arg.string({ defaultValue: undefined }),
      description: t.arg.string({ defaultValue: undefined }),
    },
    resolve: async (query, _parent, args, context) =>
      await FtServ.update(context.userId, args.id, args.name, args.description, query),
  })
);

builder.mutationField('deleteFeature', (t) =>
  t.prismaField({
    type: 'Feature',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) =>
      await FtServ.rm(context.userId, args.id, query),
  })
);

builder.queryField('parts', (t) =>
  t.prismaField({
    type: ['Part'],
    resolve: async (query, _parent, _args, context) => (
      await PtServ.getAll(context.userId, query)
    )
  })
);

builder.queryField('part', (t) =>
  t.prismaField({
    type: 'Part',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) => (
      await PtServ.getById(context.userId, args.id, query)
    )
  })
);

builder.queryField('searchParts', (t) =>
  t.prismaField({
    type: ['Part'],
    args: {
      name: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) => (
      await PtServ.searchByName(context.userId, args.name, query)
    )
  })
);

builder.mutationField('addPart', (t) =>
  t.prismaField({
    type: 'Part',
    args: {
      description: t.arg.string({ defaultValue: "" }),
      name: t.arg.string(),
      type: t.arg.string(),
      number: t.arg.int({ defaultValue: 1 }),
    },
    resolve: async (query, _parent, args, context) => 
      await PtServ.create(
        context.userId,
        args.name,
        args.description,
        args.number,
        args.type, 
        query),
  })
);

builder.mutationField('updatePart', (t) =>
  t.prismaField({
    type: 'Part',
    args: {
      id: t.arg.int(),
      name: t.arg.string({ defaultValue: undefined }),
      description: t.arg.string({ defaultValue: undefined }),
      number: t.arg.int({ defaultValue: undefined }),
    },
    resolve: async (query, _parent, args, context) =>
      await PtServ.update(context.userId, args.id, args.name, args.description, args.number, query),
  })
);

builder.mutationField('deletePart', (t) =>
  t.prismaField({
    type: 'Part',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) =>
      await PtServ.rm(context.userId, args.id, query),
  })
);

builder.queryField('partTypes', (t) =>
  t.prismaField({
    type: ['PartType'],
    resolve: async (query, _parent, _args, context) => (
      await PtTServ.getAll(context.userId, query)
    )
  })
);

builder.queryField('partType', (t) =>
  t.prismaField({
    type: 'PartType',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) => (
      await PtTServ.getById(context.userId, args.id, query)
    )
  })
);

builder.queryField('searchPartTypes', (t) =>
  t.prismaField({
    type: ['PartType'],
    args: {
      name: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) => (
      await PtTServ.searchByName(context.userId, args.name, query)
    )
  })
);

builder.mutationField('addPartType', (t) =>
  t.prismaField({
    type: 'PartType',
    args: {
      name: t.arg.string(),
      description: t.arg.string({ defaultValue: undefined }),
    },
    resolve: async (query, _parent, args, context) => 
      await PtTServ.create(context.userId, args.name, args.description, query),
  })
);

builder.mutationField('updatePartType', (t) =>
  t.prismaField({
    type: 'PartType',
    args: {
      id: t.arg.int(),
      name: t.arg.string({ defaultValue: undefined }),
      description: t.arg.string({ defaultValue: undefined }),
    },
    resolve: async (query, _parent, args, context) =>
      await PtTServ.update(context.userId, args.id, args.name, args.description, query),
  })
);

builder.mutationField('deletePartType', (t) =>
  t.prismaField({
    type: 'PartType',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) =>
      await PtTServ.rm(context.userId, args.id, query),
  })
);

builder.queryField('maintenances', (t) =>
  t.prismaField({
    type: ['Maintenance'],
    resolve: async (query, _parent, _args, context) => (
      await MtServ.getAll(context.userId, query)
    )
  })
);

builder.queryField('maintenance', (t) =>
  t.prismaField({
    type: 'Maintenance',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) => (
      await MtServ.getById(context.userId, args.id, query)
    )
  })
);

builder.mutationField('addMaintenance', (t) =>
  t.prismaField({
    type: 'Maintenance',
    args: {
      type: t.arg.string(),
      done: t.arg({ type: 'Date', required: false }),
      due: t.arg({ type: 'Date', required: false }),
      instrument: t.arg.string(),
      parts: t.arg.stringList({ defaultValue: [] }),
    },
    resolve: async (query, _parent, args, context) => 
      await MtServ.create(
        context.userId,
        args.instrument,
        args.type,
        args.done,
        args.due,
        args.parts,
        query),
  })
);

builder.mutationField('updateMaintenance', (t) =>
  t.prismaField({
    type: 'Maintenance',
    args: {
      id: t.arg.int(),
      done: t.arg({ type: 'Date', required: false, defaultValue: undefined }),
      due: t.arg({ type: 'Date', required: false, defaultValue: undefined }),
      parts: t.arg.stringList({ defaultValue: [] }),
    },
    resolve: async (query, _parent, args, context) =>
      await MtServ.update(context.userId, args.id, args.done, args.due, args.parts, query),
  })
);

builder.mutationField('deleteMaintenance', (t) =>
  t.prismaField({
    type: 'Maintenance',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) =>
      await MtServ.rm(context.userId, args.id, query),
  })
);

builder.queryField('maintenanceTypes', (t) =>
  t.prismaField({
    type: ['MaintenanceType'],
    resolve: async (query, _parent, _args, context) => (
      await MtTServ.getAll(context.userId, query)
    )
  })
);

builder.queryField('maintenanceType', (t) =>
  t.prismaField({
    type: 'MaintenanceType',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) => (
      await MtTServ.getById(context.userId, args.id, query)
    )
  })
);

builder.queryField('searchMaintenanceTypes', (t) =>
  t.prismaField({
    type: ['MaintenanceType'],
    args: {
      name: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) => (
      await MtTServ.searchByName(context.userId, args.name, query)
    )
  })
);

builder.mutationField('addMaintenanceType', (t) =>
  t.prismaField({
    type: 'MaintenanceType',
    args: {
      name: t.arg.string(),
      description: t.arg.string({ defaultValue: "" }),
      schedule: t.arg({ type: 'Date', required: false }),
      feature: t.arg.string(),
    },
    resolve: async (query, _parent, args, context) => 
      await MtTServ.create(context.userId, args.name, args.description, args.schedule, args.feature, query),
  })
);

builder.mutationField('updateMaintenanceType', (t) =>
  t.prismaField({
    type: 'MaintenanceType',
    args: {
      id: t.arg.int(),
      name: t.arg.string({ defaultValue: undefined }),
      description: t.arg.string({ defaultValue: undefined }),
      schedule: t.arg({ type: 'Date', required: false, defaultValue: undefined }),
    },
    resolve: async (query, _parent, args, context) =>
      await MtTServ.update(context.userId, args.id, args.name, args.description, args.schedule, query),
  })
);

builder.mutationField('deleteMaintenanceType', (t) =>
  t.prismaField({
    type: 'MaintenanceType',
    args: {
      id: t.arg.int(),
    },
    resolve: async (query, _parent, args, context) =>
      await MtTServ.rm(context.userId, args.id, query),
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
