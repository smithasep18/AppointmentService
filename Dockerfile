# Use an official Node runtime as a parent image
FROM node:18-slim

# Set working directory
WORKDIR /usr/src/app

# Copy package files first to leverage Docker layer caching
COPY package.json package-lock.json* ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy application source
COPY . .

# Expose the application port
EXPOSE 3000

# Use the built-in non-root Node user
USER node

# Start the application
CMD ["node", "src/index.js"]
