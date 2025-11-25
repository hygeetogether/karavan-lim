# Builder stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package manifests
COPY package*.json ./
COPY package-lock.json ./
COPY prisma ./prisma/

# Bust cache to force reinstall when needed
ARG CACHEBUST=1

# Install all dependencies (including Prisma 6) deterministically
RUN npm ci --omit=dev

# Copy source code
COPY . .

# Placeholder DATABASE_URL for Prisma generate (runtime will override)
ENV DATABASE_URL="postgresql://placeholder:placeholder@localhost:5432/placeholder"

# Generate Prisma client before building
RUN npx prisma generate

# Build the TypeScript application
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy package manifests
COPY package*.json ./
COPY package-lock.json ./
COPY prisma ./prisma/

# Install only production dependencies
RUN npm ci --omit=dev

# Copy built assets from builder
COPY --from=builder /app/dist ./dist

# Placeholder DATABASE_URL (will be overridden by Render env)
ENV DATABASE_URL="postgresql://placeholder:placeholder@localhost:5432/placeholder"

# Generate Prisma client in production
RUN npx prisma generate

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

# Adjust ownership
RUN chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose application port
EXPOSE 3001

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
    CMD node -e "require('http').get('http://localhost:3000/health', r => {process.exit(r.statusCode===200?0:1)})"

# Start the server
CMD ["npm","run","start:prod"]
