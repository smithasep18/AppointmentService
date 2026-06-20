# Use an official Node runtime as a parent image
FROM node:18-slim

# Set working directory
WORKDIR /usr/src/app

# Copy package manifest and lockfile first to leverage Docker layer caching
COPY package.json package-lock.json* ./

# Install only production dependencies
RUN npm ci --omit=dev

# Copy application source
COPY . .

# Expose the application port (change if needed)
EXPOSE 3000

# Use a non-root user for runtime security
RUN groupadd -r app && useradd --no-log-init -r -g app app
USER app

# Start the application
CMD ["node", "src/index.js"]
