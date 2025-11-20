# -----------------------
# Stage 1: Build
# -----------------------
FROM node:22-alpine AS builder

# Create app directory
WORKDIR /usr/src/app

# Enable corepack so pnpm is available
RUN corepack enable

# Copy package metadata
COPY package.json pnpm-lock.yaml ./

# Install all dependencies
RUN pnpm install --frozen-lockfile

# Copy source files
COPY tsconfig.json ./
COPY src ./src

# Build NestJS project
RUN pnpm build


# -----------------------
# Stage 2: Runtime
# -----------------------
FROM node:22-alpine

WORKDIR /usr/src/app

RUN corepack enable

# Copy only what we need for runtime
COPY package.json pnpm-lock.yaml ./

# Install only production deps
RUN pnpm install --prod --frozen-lockfile

# Copy compiled files from builder
COPY --from=builder /usr/src/app/dist ./dist

# Environment
ENV NODE_ENV=production
ENV PORT=3000

# Expose internal port (your container listens here)
EXPOSE 3000

# Start the app
CMD ["node", "dist/main.js"]
