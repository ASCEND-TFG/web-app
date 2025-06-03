# Stage 1: Build with memory optimizations
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Copy only what's needed for npm install
COPY package.json package-lock.json ./

# Install dependencies with memory limit
RUN npm install --max-old-space-size=512

# Copy remaining files
COPY . .

# Build with production flag and memory limit
# Modified to output directly to dist/ and ensure index.html exists
RUN node --max-old-space-size=512 ./node_modules/@angular/cli/bin/ng build \
    --configuration=production \
    --output-path=dist \
    --base-href=/

# Stage 2: Production server
FROM node:20-alpine

WORKDIR /usr/src/app
RUN npm install -g serve@14

# Copy the built files from the correct path
COPY --from=builder /usr/src/app/dist ./dist

EXPOSE 2222
# Modified to serve index.html for all routes
CMD ["serve", "-s", "dist", "-l", "2222", "--single"]
