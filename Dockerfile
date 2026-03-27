# Start from official Node.js image (lightweight Alpine Linux version)
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package files first (this is a performance trick — explained below)
COPY package*.json ./

# Install only production dependencies
RUN npm install --production

# Copy the rest of your app code
COPY . .

# Tell Docker this container listens on port 3000
EXPOSE 3000

# Command to start the app
CMD ["node", "server.js"]